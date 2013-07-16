#---
# http://www.kosmyka.com/
#---

inside('public/javascripts') do
  FileUtils.rm_rf %w(controls.js dragdrop.js effects.js prototype.js rails.js)
end

inside('app/views/layouts') do
  FileUtils.rm 'application.html.erb'
end

inside('config') do
  FileUtils.rm %w(boot.rb environment.rb)
end

# Downloads
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/Capfile", "Capfile"
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/config/deploy.rb", "config/deploy.rb"
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/config/boot.rb", "config/boot.rb"
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/config/initializers/barista_config.rb", "config/initializers/barista_config.rb"
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/app/views/layouts/application.html.haml", "app/views/layouts/application.html.haml"

gsub_file 'Rakefile', /#{app_name.camelize}::Application.load_tasks/, '#fix for ruby 1.8.7'
append_file 'Rakefile', <<-CODE

module ::#{app_name.camelize}
  class Application
    include Rake::DSL
  end
end

module ::RakeFileUtils
  extend Rake::FileUtilsExt
end

#{app_name.camelize}::Application.load_tasks
CODE

file "config/environment.rb", <<-CODE
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ':/usr/lib/ruby/gems/1.8'

require File.expand_path('../application', __FILE__)

# Initialize the rails application
#{app_name.camelize}::Application.initialize!
CODE

# Update Gemfile
gsub_file 'Gemfile', /gem 'mysql2'/, 'gem "mysql2", "~> 0.2.7"'
gsub_file 'Gemfile', /# gem 'capistrano'/, 'gem "capistrano"'
append_file "Gemfile", <<-CODE
group :development do
  gem 'barista'
  gem 'yui-compressor', :require => 'yui/compressor'
  gem 'sass'
  gem 'json' # sprocket dependency for Ruby 1.8 only
  gem 'sprockets', :git => 'git://github.com/sstephenson/sprockets.git'
  gem 'compass', '>= 0.13.alpha.0'
  gem 'compass-rails', '>= 1.0.2'
  gem 'susy'
end

gem "nokogiri", "< 1.6"
gem "haml"
gem "haml-rails"
gem "paperclip", "~>2.0"
gem "will_paginate"
gem "inherited_resources"
gem "jquery-rails"
gem "metamagic"
gem "friendly_id", "~>4.0.0.beta14"
gem "devise"
gem "auto_html"
gem "page_title_helper"
gem 'rdoc'
gem "rake", "~>0.9.2"

group :test do
  gem "cucumber-rails"
  gem "database_cleaner"
  gem "capybara", "2.0.3"
end

gem 'rspec-rails', :group => [:development, :test]
CODE

route 'root :to => "home#index"'

run "bundle install"

inside('public/') do
  FileUtils.rm_rf %w(index.html favicon.ico)
end

run "rm config/database.yml"

db_user = ask("Please enter your local mysql user")
db_password = ask("Please enter your local mysql password")

file "config/database.yml", <<-CODE
defaults: &defaults
  adapter: mysql2
  encoding: utf8
  reconnect: false
  pool: 5
  username: #{db_user}
  password: #{db_password}
  socket: /tmp/mysql.sock

development:
  database: #{app_name.camelize(:lower)}_development
  <<: *defaults

test: &test
  database: #{app_name.camelize(:lower)}_test
  <<: *defaults

production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  host:
  database: #{app_name.camelize(:lower)}_production
  pool: 5
  username:
  password:
CODE

initializer 'i18n.rb',
%q{#encoding: utf-8
I18n.default_locale = :en

LANGUAGES = [
  ['English',                  'en'],
  ["Espa&ntilde;ol".html_safe, 'es']
]
}

gsub_file 'config.ru', /# This file is used by Rack-based servers to start the application./ do
"if ENV['RAILS_ENV'] == 'production'
  ENV['HOME'] ||= `echo ~`.strip
  ENV['GEM_PATH'] = File.expand_path('~/.gems') + ':' + '/usr/lib/ruby/gems/1.8'
  ENV['GEM_HOME'] = File.expand_path('~/.gems')
end
# This file is used by Rack-based servers to start the application."
end

gsub_file 'config/environment.rb', /# Load the rails application/ do
"# Load the rails application
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ':' + '/usr/lib/ruby/gems/1.8'
end

gsub_file 'config/boot.rb', /# Load the rails application/ do
"# Load the rails application
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ':' + '/usr/lib/ruby/gems/1.8'
end

# Setup Google Analytics
if ask("Do you have Google Analytics key? (N/y)").upcase == 'Y'
  ga_key = ask("Please provide your Google Analytics tracking key: (e.g UA-XXXXXX-XX)")
else
  ga_key = nil
end

file "app/views/shared/_google_analytics.html.erb", <<-CODE
<script type="text/javascript" charset="utf-8">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '#{ga_key || "INSERT-URCHIN-CODE"}']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
CODE

if ga_key
append_file "app/views/layouts/application.html.haml", <<-CODE
    = render 'shared/google_analytics'
CODE
else
append_file "app/views/layouts/application.html.haml", <<-CODE
    = #render 'shared/google_analytics'
CODE
end

run "bundle exec rake db:create"
run "bundle exec rake db:migrate"

# Plugins
run "rails g jquery:install --ui"
run "rails g controller home index"

run "rails g cucumber:install"

# Sass + Compass + Susy
run "compass config config/config.rb --sass-dir=app/assets/stylesheets --css-dir=public/stylesheets --images-dir=public/images --javascripts-dir=public/javascripts"
run "compass init --config config/config.rb"
append_file "config.rb", <<-CODE
require "susy"
CODE
append_file "app/assets/stylesheets/screen.scss", <<-CODE
@import "susy";
CODE

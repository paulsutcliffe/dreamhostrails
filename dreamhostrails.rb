#---
# http://www.kosmyka.com/
#---

inside('public/javascripts') do
  FileUtils.rm_rf %w(controls.js dragdrop.js effects.js prototype.js rails.js)
end

# Downloads
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/Capfile", "Capfile"
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/config/deploy.rb", "config/deploy.rb"
get "https://raw.github.com/paulsutcliffe/dreamhostrails/master/config/initializers/barista_config.rb", "config/initializers/barista_config.rb"


append_file 'Rakefile', <<-CODE

# Change ApplicationName with you app name found in config/application.rb next to module
module ::ApplicationName
  class Application
    include Rake::DSL
  end
end

module ::RakeFileUtils
  extend Rake::FileUtilsExt
end
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

gem "haml"
gem "haml-rails"
gem "paperclip", "~>2.0"
gem "will_paginate"
gem "inherited_resources"
gem "rake", "~>0.9.2"
gem "client_side_validations"
gem "jquery-rails"
gem "paper_trail"
gem "metamagic"
gem "friendly_id", "~>4.0.0.beta14"
# gem "devise"
gem "nifty-generators"
gem "auto_html"
gem "page_title_helper"
gem "sitemap_generator"

group :test do
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'simplecov'
end

gem 'rspec-rails', :group => [:development, :test]
CODE


route 'root :to => "home#index"'

run "bundle install"

inside('public/') do
  FileUtils.rm_rf %w(index.html favicon.ico)
end

initializer 'i18n.rb', 
%q{#encoding: utf-8
I18n.default_locale = :es

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
ENV['HOME'] ||= `echo ~`.strip
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ':' + '/usr/lib/ruby/gems/1.8'
ENV['GEM_HOME'] = File.expand_path('~/.gems')"
end

file "public/dispatch.fcgi", <<-CODE
#!/usr/bin/ruby

# Dreamhost clears environment variables when calling dispatch.fcgi, so set them here 
ENV['RAILS_ENV'] ||= 'production'
ENV['HOME'] ||= `echo ~`.strip
ENV['GEM_HOME'] = File.expand_path('~/.gems')
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ":" + '/usr/lib/ruby/gems/1.8'

require 'rubygems'
Gem.clear_paths
require 'fcgi'

require File.join(File.dirname(__FILE__), '../config/environment')

class Rack::PathInfoRewriter
 def initialize(app)
   @app = app
 end

 def call(env)
   env.delete('SCRIPT_NAME')
   parts = env['REQUEST_URI'].split('?')
   env['PATH_INFO'] = parts[0]
   env['QUERY_STRING'] = parts[1].to_s
   @app.call(env)
 end
end

# Change ApplicationName with you app name found in config/application.rb next to module
Rack::Handler::FastCGI.run  Rack::PathInfoRewriter.new(ApplicationName::Application)
CODE

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
append_file "app/views/layouts/application.html.erb", <<-CODE
<%= render :partial => 'shared/google_analytics' %>
CODE
else
append_file "app/views/layouts/application.html.erb", <<-CODE
<%#= render :partial => 'shared/google_analytics' %>
CODE
end

rake "db:create"
rake "db:migrate"

# Headliner plugin 
plugin 'headliner', :git => "git://github.com/mokolabs/headliner.git"
run "rails g jquery:install --ui"
run "rails g controller home index"

# Sass + Compass + Susy
run "compass config config/config.rb --sass-dir=app/assets/stylesheets --css-dir=public/stylesheets --images-dir=public/images --javascripts-dir=public/javascripts"
run "compass init --config config/config.rb"
append_file "config.rb", <<-CODE
require "susy"
CODE
append_file "app/assets/stylesheets/screen.css", <<-CODE
@import "susy";
CODE
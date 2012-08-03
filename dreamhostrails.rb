#---
# http://www.kosmyka.com/
#---

inside('public/javascripts') do
  FileUtils.rm_rf %w(controls.js dragdrop.js effects.js prototype.js rails.js)
end

# Download latest jQuery drivers
# get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

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

initializer 'barista_config.rb', 
%q{
# Configure barista.
unless Rails.env.production?
Barista.configure do |c|

  # Change the root to use app/scripts
  c.root = Rails.root.join("app", "assets","javascripts")

  # Change the output root, causing Barista to compile into public/coffeescripts
  c.output_root = Rails.root.join("public", "javascripts")
  #
  # Disable auto compile, use generated file directly:
  # c.auto_compile = false

  # Add a new framework:

  # c.register :tests, :root => Rails.root.join('test', 'coffeescript'), :output_prefix => 'test'

  # Disable wrapping in a closure:
  # c.bare = true
  # ... or ...
  # c.bare!

  # Change the output root for a framework:

  # c.change_output_prefix! 'framework-name', 'output-prefix'

  # or for all frameworks...

  # c.each_framework do |framework|
  #   c.change_output_prefix! framework, "vendor/#{framework.name}"
  # end

  # or, prefix the path for the app files:

  # c.change_output_prefix! :default, 'my-app-name'

  # or, change the directory the framework goes into full stop:

  # c.change_output_prefix! :tests, Rails.root.join('spec', 'javascripts')

  # or, hook into the compilation:

  # c.before_compilation   { |path|         puts "Barista: Compiling #{path}" }
  # c.on_compilation       { |path|         puts "Barista: Successfully compiled #{path}" }
  # c.on_compilation_error { |path, output| puts "Barista: Compilation of #{path} failed with:\n#{output}" }
  # c.on_compilation_with_warning { |path, output| puts "Barista: Compilation of #{path} had a warning:\n#{output}" }

  # Turn off preambles and exceptions on failure:

  # c.verbose = false

  # Or, make sure it is always on
  # c.verbose!

  # If you want to use a custom JS file, you can as well
  # e.g. vendoring CoffeeScript in your application:
  # c.js_path = Rails.root.join('public', 'javascripts', 'coffee-script.js')

  # Make helpers and the HAML filter output coffee-script instead of the compiled JS.
  # Used in combination with the coffeescript_interpreter_js helper in Rails.
  # c.embedded_interpreter = true

end
end
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
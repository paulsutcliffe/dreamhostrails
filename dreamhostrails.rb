#---
# http://www.kosmyka.com/
#---

# Download latest jQuery drivers
get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

# Update Gemfile
inside('/') do
  FileUtils.rm_rf 'Gemfile'
end
get "https://github.com/paulyoyo/dreamhostrails/blob/master/Gemfile", "Gemfile"

route 'root :to => "home#index"'

run "bundle install"
run "rails g jquery:install --ui"
run "rails plugin install git://github.com/mokolabs/headliner.git"

initializer 'i18n.rb', 
%q{#encoding: utf-8
I18n.default_locale = :es

LANGUAGES = [
  ['English',                  'en'],
  ["Espa&ntilde;ol".html_safe, 'es']
]
}

run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm public/images/rails.png"

file "config.ru", 
%q{if ENV['RAILS_ENV'] == 'production'
  ENV['HOME'] = '/home/dreamhostusername'
  ENV['GEM_HOME'] = '/home/dreamhostusername/.gems'
  ENV['GEM_PATH'] = '/home/dreamhostusername/.gems'
end
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run #{app_name}::Application
}

file "config/enviroment.rb",
%q{ENV['GEM_PATH'] = '/home/dreamhostusername/gems:/usr/lib/ruby/gems/1.8'
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
#{app_name}::Application.initialize!
}

# Headliner plugin 
plugin 'headliner', :git => "git://github.com/mokolabs/headliner.git"

#generate :model, "meta keywords:string description:text"
#generate :controller, "home index"

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

#rake "db:create"
#rake "db:migrate"

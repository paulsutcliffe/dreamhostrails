if ENV['RAILS_ENV'] == 'production'
  Gem.clear_paths
end
require 'rubygems'
# Set up gems listed in the Gemfile.
if File.exist?(File.expand_path('../../Gemfile', __FILE__))
  require 'bundler'
  Bundler.setup
end

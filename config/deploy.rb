require "bundler/capistrano"
default_environment['PATH']='/usr/lib/ruby/gems/1.8/bin:/home/railschaxras/.gems/bin:/usr/local/bin:/usr/bin:/bin'
default_environment['GEM_PATH']='/home/railschaxras/.gems:/usr/lib/ruby/gems/1.8'

set :user, "railschaxras"
set :domain, "yorkville.dreamhost.com"
set :project, "chaxras"
set :application, "chaxras"
set :applicationdir, "/home/#{user}/#{application}"  # The standard Dreamhost setup
set :repository,  "git@github.com:paulsutcliffe/chaxras.git"
default_run_options[:pty] = true

ssh_options[:forward_agent] = true
set :git_enable_submodules, 1
set :scm, :git
set :scm_passphrase, ""
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :scm_verbose, true
set :deploy_to, applicationdir

role :web, domain                   # Your HTTP server, Apache/etc
role :app, domain                   # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

set :use_sudo, false

after 'deploy:create_symlink' do
  run "chmod 775 /home/railschaxras/chaxras/current/public/dispatch.fcgi"
  run "rm /home/railschaxras/chaxras/current/public/stylesheets/powerhouse.css"
  run "rm /home/railschaxras/chaxras/current/public/javascripts/powerfactory.js"
end


require "bundler/capistrano"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

# RVM Setup

set :rvm_ruby_string, :local
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs

before 'deploy:setup', 'rvm:install_rvm'  # install RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset

require "rvm/capistrano"

set :application, "diputados"
set :repository,  "https://github.com/BlueLemon/diputados.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/diputados"

role :web, "diputatres"                          # Your HTTP server, Apache/etc
role :app, "diputatres"                          # This may be the same as your `Web` server
role :db,  "diputatres", :primary => true        # This is where Rails migrations will run

set :user, "diputados"

set :use_sudo, false

namespace :deploy do

  namespace :db do

    desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
    DESC
    task :symlink, :except => { :no_release => true }, :role => :app do
      run "ln -fs ~/database.yml #{release_path}/config/database.yml"
    end

  end

  namespace :mail do

    desc <<-DESC
      [internal] Updates the symlink for mail.yml file to the just deployed release.
    DESC
    task :symlink, :except => { :no_release => true }, :role => :app do
      run "#{try_sudo} ln -fs #{shared_path}/mail.yml #{release_path}/config/mail.yml"
    end

  end

end

after "deploy:finalize_update", "deploy:db:symlink"
after "deploy:finalize_update", "deploy:mail:symlink"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :legacy  do
  desc "Link db/legacy for current deploy to the shared location"
  task :update_symlink, :roles => [:db] do
    run "#{try_sudo} ln -fs #{shared_path}/legacy #{release_path}/db/legacy"
  end
end

after "deploy:finalize_update", "legacy:update_symlink"


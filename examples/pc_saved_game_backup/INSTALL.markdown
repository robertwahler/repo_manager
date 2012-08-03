Creating the RepoManager Saved Game Backup Configuration
====================================================

> NOTE for Windows users
>
> The given instruction are intended for a Bash shell.  Bash is not
> required to use RepoManager, but it does make using the command prompt much
> more flexible and productive. The MSYS distribution of portable Git
> includes a lean and stable Bash environment.

Initial configuration
---------------------

### install repo_manager

    gem install repo_manager

### create configuration

The following commands were used to create this example folder from
scratch.

    mkdir -p examples/pc_saved_game_backup && cd examples/pc_saved_game_backup

Create configuration structure with the built-in 'generate:init' task

> NOTE
>
> We are creating a local configuration.  For a global configuration, you would
> execute the init command in your home folder

    repo generate:init repo_manager

We are going to keep this under version control

    git init
    git add .
    git commit -m "initial commit"
    echo "/repo.log" > .gitignore
    echo "/repo_manager/tmp" >> .gitignore

Change the generated paths from absolute to relative to make this example
portable.

    diff --git a/repo_manager/repo.conf b/repo_manager/repo.conf
    index ce4418d..3cc6dbe 100644
    --- a/repo_manager/repo.conf
    +++ b/repo_manager/repo.conf
    @@ -11,7 +11,7 @@ options:
     folders:

       # main repo configuration files
    -  assets  : /home/robert/examples/pc_saved_game_backup/repo_manager/assets
    +  assets  : assets

       #
       # repo user tasks, file extentions can be '.rb' or '.thor'
    @@ -26,7 +26,7 @@ folders:
       #
       #         c:/dat/condenser/tasks
       #
    -  tasks        : /home/robert/examples/pc_saved_game_backup/repo_manager/tasks
    +  tasks        : tasks

     # git commands must be whitelisted
     commands:
    @@ -55,7 +55,7 @@ logging:
           name          : logfile
           level         : info
           truncate      : true
    -      filename      : '/home/robert/examples/pc_saved_game_backup/repo_manager/repo.log'
    +      filename      : 'repo.log'
           layout:
             type        : Pattern
             pattern     : '[%d] %l %c : %m\n'

### add sample data

Add a few example save game folder.  These folders would normally be
scattered over the file system.

mines

    mkdir -p saved_games/mines/saves

    # profile data will not be stored in the Git repo since it may differ from PC to PC
    echo "# dummy profile data" > mines/my_profile.ini

    echo "# dummy save" > saved_games/mines/saves/save1
    echo "# dummy save" > saved_games/mines/saves/save2

hearts

    mkdir -p saved_games/hearts

    echo "# dummy save" > saved_games/hearts/save1
    echo "# dummy save" > saved_games/hearts/save2

### create remote folder

This folder will act as a remote to hold bare Git repositories. These
repos will store backups of our game saves, normally, this folder would be
on a remote server, NAS, or Drop Box like service.

    mkdir remote

remote/.gitignore

    *
    !/.gitignore


Create the specialized 'git init' task
--------------------------------------

User tasks can be added directly to the repo_manager/tasks folder.  This one
is 'repo_manager/tasks/remote.rb'.  It doesn't use any RepoManager specific features,
instead, it calls git directly via Thor's 'run' command. Adding the script
this way will keep this related functionality with this specific RepoManager
configuration.  Run 'repo -T' to see a full list of built-in tasks as well
as user defined tasks.

repo_manager/tasks/remote.rb

    require 'fileutils'

    module RepoManager

      class Generate < Thor

        # full path to the remote folder
        REMOTE = File.expand_path('remote')

        # Create, add, and commit the contents of the current working directory and
        # then push it to a predefined remote folder
        #
        # @example From the repo working
        #
        #   cd ~/my_repo_name
        #   repo generate:remote my_repo_name
        #
        # @example Specify the path to the working folder
        #
        #   repo generate:remote my_repo_name --path=/path/to/my_repo_name

        method_option :remote, :type => :string, :desc => "remote folder or git host, defaults to '#{REMOTE}'"
        method_option :path, :type => :string, :desc => "path to working folder, defaults to CWD"

        desc "remote REPO_NAME", "init a git repo in CWD and push to remote '#{REMOTE}'"
        def remote(name)
          path = options[:path] || FileUtils.pwd
          remote = options[:remote] || "#{File.join(REMOTE, name + '.git')}"

          Dir.chdir path do
            run("git init")

            # core config with windows in mind but works fine on POSIX
            run("git config core.autocrlf false")
            run("git config core.filemode false")
            exit $?.exitstatus if ($?.exitstatus > 1)

            # add everthing and commit
            run("git add .")
            run("git commit --message #{shell_quote('initial commit')}")
            exit $?.exitstatus if ($?.exitstatus > 1)

            # remove old origin first, if it exists
            run("git remote add origin #{remote}")
            run("git config branch.master.remote origin")
            run("git config branch.master.merge refs/heads/master")
            exit $?.exitstatus if ($?.exitstatus > 1)
          end

          run("git clone --bare #{shell_quote(path)} #{remote}")
          exit $?.exitstatus if ($?.exitstatus > 1)

          say "init done on '#{name}'", :green
        end

      end
    end

### add remotes

In one step, we will initialize a new git repository with the working folder's
content and push to a new bare repository for backup.

> Normally, you don't need to specify the --path if you are already in the
> working folder and the repo_manager can find its global config file.  For this
> example, we are using relative paths and will specify the working folder
> on the command line via the '--path' option.

    repo generate:remote mines --path=saved_games/mines/saves
    repo generate:remote hearts --path=saved_games/hearts

### create the repo_manager asset configuration files

    repo add:asset saved_games/mines/saves --name=mines --force
    repo add:asset saved_games/hearts --force


Create the specialized Update task
----------------------------------

repo_manager/tasks/update.rb

    module RepoManager
      class Action < Thor
        namespace :action
        include Thor::Actions
        include RepoManager::ThorHelper

        class_option :force, :type => :boolean, :desc => "Force overwrite and answer 'yes' to any prompts"

        method_option :repos, :type => :string, :desc => "Restrict update to comma delimited list of repo names", :banner => "repo1,repo2"
        method_option :message, :type => :string, :desc => "Override 'automatic commit' message"
        method_option 'no-push', :type => :boolean, :default => false, :desc => "Force overwrite of existing config file"

        desc "update", "run repo add -A, repo commit, and repo push on all modified repos"
        def update

          initial_filter = options[:repos] ? "--repos=#{options[:repos]}" : ""
          output = run("repo status --short --unmodified=HIDE --no-verbose --no-color #{initial_filter}", :capture => true)

          case $?.exitstatus
            when 0
              say 'no changed repos', :green
            else

              unless output
                say "failed to successfully run 'repo status'", :red
                exit $?.exitstatus
              end

              repos = []
              output = output.split("\n")
              while line = output.shift
                st,repo = line.split("\t")
                repos << repo
              end
              filter = repos.join(',')

              unless options[:force]
                say "Repo(s) '#{filter}' have changed."
                unless ask("Add, commit and push them? (y/n)") == 'y'
                  say "aborting"
                  exit 0
                end
              end

              say "updating #{filter}"

              run "repo add -A --no-verbose --repos #{filter}"
              exit $?.exitstatus if ($?.exitstatus > 1)

              commit_message = options[:message] || "automatic commit @ #{Time.now}"
              run "repo commit --message=#{shell_quote(commit_message)} --no-verbose --repos #{filter}"
              exit $?.exitstatus if ($?.exitstatus > 1)

              unless options['no-push']
                run "repo push --no-verbose --repos #{filter}"
                exit $?.exitstatus if ($?.exitstatus > 1)
              end

              say "update finished", :green
            end

        end
      end
    end

### whitelist non-default Git commands

Only a small subset of non-destructive git commands are enabled by default.  We will
add the commands needed by our user task to the commands whitelist.

Add 'push, add, and commit' to the commands whitelist

    diff --git a/repo_manager/repo.conf b/repo_manager/repo.conf
    index 3cc6dbe..226b8c0 100644
    --- a/repo_manager/repo.conf
    +++ b/repo_manager/repo.conf
    @@ -36,6 +36,9 @@ commands:
     - ls-files
     - show
     - status
    +- push
    +- add
    +- commit

Testing user tasks with Cucumber
--------------------------------------

### Add a Gemfile for use by Bundler

repo_manager/Gemfile

    source "http://rubygems.org"

    gem "repo_manager"

    gem "bundler", ">= 1.0.14"
    gem "rspec", ">= 2.6.0"
    gem "cucumber", "~> 1.0"
    gem "aruba", "= 0.4.5"

    gem "win32console", :platforms => [:mingw, :mswin]

### Install the dependencies

    gem install bundler

    cd repo_manager
    bundle

### Add Cucumber features and support files

repo_manager/features/tasks/update.feature

> NOTE: This is an excerpt, see the file for the full listing of functional tests

    @announce
    Feature: Automatically commit and update multiple repos

      Background: Test repositories and a valid config file
        Given a repo in folder "test_path_1" with the following:
          | filename         | status | content  |
          | .gitignore       | C      |          |
        And a repo in folder "test_path_2" with the following:
          | filename         | status | content  |
          | .gitignore       | C      |          |
        And a file named "repo.conf" with:
          """
          ---
          folders:
            assets : repo/asset/configuration/files
          """
        And the folder "repo/asset/configuration/files" with the following asset configurations:
          | name    | path         |
          | test1   | test_path_1  |
          | test2   | test_path_2  |


      Scenario: No uncommitted changes
        When I run `repo action:update`
        Then the output should contain:
          """
          no changed repos
          """

      ...

repo_manager/features/support/steps.rb

    require 'repo_manager/test/base_steps'
    require 'repo_manager/test/asset_steps'
    require 'repo_manager/test/repo_steps'

repo_manager/features/support/env.rb

    require 'repo_manager'
    require 'aruba/cucumber'
    require 'rspec/expectations'

repo_manager/features/support/aruba.rb

    require 'aruba/api'
    require 'fileutils'

    module Aruba
      module Api

        # override aruba avoid 'current_ruby' call and make sure
        # that binary run on Win32 without the binstubs
        def detect_ruby(cmd)
          wrapper = which('repo')
          cmd = cmd.gsub(/^repo/, "ruby -S #{wrapper}") if wrapper
          cmd
        end
      end
    end

### Run tests

    bundle exec cucumber

Bash completion
---------------

Handy functions for use under Bash.  These work fine on Win32 using
Git-Bash.

### CD command for working folders

rpushd: repo pushd (push directory).  Wrapper for 'pushd'.

### Completion for repo names

rcd: repo cd (change directory).  Wrapper for 'cd', allows for simple cd <repo
name> to the working folder on the filesystem referenced by the 'path'
configuration variable.

Source these functions in your .bashrc

    function rcd(){ cd "$(repo --match=ONE --no-color path $@)"; }
    function rpushd(){ pushd "$(repo path --match=ONE --no-color $@)"; }
    alias rpopd="popd"

    # provide completion for repo names
    function _repo_names()
    {
      local cur opts prev
      COMPREPLY=()
      cur="${COMP_WORDS[COMP_CWORD]}"
      opts=`repo list --list=name --no-color`

      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      return 0
    }
    complete -F _repo_names rcd rpushd repo

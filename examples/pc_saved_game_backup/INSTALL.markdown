Creating the Repoman Saved Game Backup Configuration
====================================================

> NOTE for Windows users
>
> The given instruction are intended for a Bash shell.  Bash is not
> required to use Repoman, but it does make using the command prompt much
> more flexible and productive. The MSYS distribution of portable Git
> includes a lean and stable Bash environment.

---------------------------------

The following commands were used to create this example folder from
scratch.

    mkdir examples/pc_saved_game_backup && cd examples/pc_saved_game_backup

Create configuration structure with the built-in 'generate:init' task

    repo generate:init repoman

Change the generated paths from absolute to relative to make this example
portable.

      diff --git a/examples/pc_saved_game_backup/repoman/repo.conf b/examples/pc_saved_game_backup/repoman/repo.conf
      index ed80bc6..e28637d 100644
      --- a/examples/pc_saved_game_backup/repoman/repo.conf
      +++ b/examples/pc_saved_game_backup/repoman/repo.conf
      @@ -11,7 +11,7 @@ options:
       folders:

         # main repo configuration files
      -  assets  : /home/robert/workspace/repoman/examples/pc_saved_game_backup/repoman/assets
      +  assets  : assets

         #
         # repo user tasks, file extentions can be '.rb' or '.thor'
      @@ -26,7 +26,7 @@ folders:
         #
         #         c:/dat/condenser/tasks
         #
      -  tasks        : /home/robert/workspace/repoman/examples/pc_saved_game_backup/repoman/tasks
      +  tasks        : tasks

       logging:
         loggers:
      @@ -46,7 +46,7 @@ logging:
             name          : logfile
             level         : debug
             truncate      : true
      -      filename      : '/home/robert/workspace/repoman/examples/pc_saved_game_backup/repoman/repo.log'
      +      filename      : 'repo.log'
             layout:
               type        : Pattern
               pattern     : '[%d] %l %c : %m\n'

### Add sample data

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

User tasks can be added directly to the repoman/tasks folder.  This one
is 'repoman/task/remote.rb'.  It doesn't use any Repoman specific features,
instead, it calls git directly via Thor's 'run' command. Adding the script
this way will keep this related functionality with this specific Repoman
configuration.  Run 'repo -T' to see a full list of built-in tasks as well
as user defined tasks.

repoman/task/remote.rb

    require 'fileutils'

    module Repoman

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
> work folder and the repoman can find its global config file.  For this
> example, we are using relative paths and will specify the working folder
> on the command line via the '--path' option.

    repo generate:remote mines --path=saved_games/mines/saves
    repo generate:remote hearts --path=saved_games/hearts

### create the repoman asset configuration files

    repo add:asset saved_games/mines/saves
    repo add:asset saved_games/hearts


Create the specialized Update task
----------------------------------


Testing with user tasks with Cucumber
--------------------------------------

Bash completion
---------------

### Completion for repo names

### CD command for working folders


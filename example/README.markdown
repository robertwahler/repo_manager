Using Repoman to Backup and Synchronize PC Game Saves
=====================================================

Use case:  Backup and synchronization of PC save games folders to a
central repository (ie Drop Box folder).  Game saves are typically
scattered across multiple folders and drives.

This example demonstrates the following features:

* Adding Repoman user tasks, see config/tasks/update.rb
* Testing user tasks with Cucumber
* Relative paths (not absolute) in config/repo.conf making the folder portable
* Bash completion for repo names, works on Win32 using Cygwin or MSYS Bash.
* Bash function to cd into a repo's working folder


Create the Repoman configuration
---------------------------------

The following commands were used to create this example folder from
scratch.


    mkdir example && cd example

Create config structure with the built-in generate:init task

    repo generate:init config

Change the generate paths from absolute to relative

      diff --git a/example/config/repo.conf b/example/config/repo.conf
      index ed80bc6..e28637d 100644
      --- a/example/config/repo.conf
      +++ b/example/config/repo.conf
      @@ -11,7 +11,7 @@ options:
       folders:

         # main repo configuration files
      -  assets  : /home/robert/workspace/repoman/example/config/assets
      +  assets  : assets

         #
         # repo user tasks, file extentions can be '.rb' or '.thor'
      @@ -26,7 +26,7 @@ folders:
         #
         #         c:/dat/condenser/tasks
         #
      -  tasks        : /home/robert/workspace/repoman/example/config/tasks
      +  tasks        : tasks

       logging:
         loggers:
      @@ -46,7 +46,7 @@ logging:
             name          : logfile
             level         : debug
             truncate      : true
      -      filename      : '/home/robert/workspace/repoman/example/config/repo.log'
      +      filename      : 'repo.log'
             layout:
               type        : Pattern
               pattern     : '[%d] %l %c : %m\n'

### Add sample data

Add a few example save game folder.  These folders would normally be
scattered over the file system.

    mkdir saved_games && cd saved_games

mines

    mkdir -p mines/saves

    # profile data will not be stored in the Git repo since it may differ from PC to PC
    echo "# dummy profile data" > mines/my_profile.ini

    echo "# dummy save" > mines/saves/save1
    echo "# dummy save" > mines/saves/save2

hearts

    mkdir -p hearts

    echo "# dummy save" > hearts/save1
    echo "# dummy save" > hearts/save2


### create remote folder

This folder will act as a remote to hold bare Git repositories. These
repos will store backups of our game saves, normally, this folder would be
on a remote server, NAS, or Drop Box like service

    mkdir remote
    touch remote/.gitignore


Create the specialized 'git init' task
--------------------------------------




Create the specialized Update task
----------------------------------


Testing with user tasks with Cucumber
--------------------------------------

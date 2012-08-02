Using RepoManager to Backup and Synchronize PC Game Saves
=====================================================

Use case:  Backup and synchronization of PC save games folders to a
central repository (ie Drop Box folder) using Git.  Game saves are
typically scattered across multiple folders and drives.

This example demonstrates the following features:

* Adding RepoManager user tasks, see repo_manager/tasks/
* Adding destructive git commands to the default whitelisted non-destructive git commands
* Testing user tasks with Cucumber, see repo_manager/features/
* Relative paths (not absolute) in repo_manager/repo.conf making the folder portable
* Bash completion for repo names, works on Win32 using Cygwin or MSYS Bash
* Bash function to 'cd' into a repo's working folder


Bootstrapping this example folder
--------------------------------

In order to try out the example commands below, you will need to bootstrap the
sample data git repositories and create the configuration files using the
following commands.  See [INSTALL.markdown](INSTALL.markdown) for a more
complete explanation.

    repo generate:remote mines --path=saved_games/mines/saves
    repo generate:remote hearts --path=saved_games/hearts

    repo add:asset saved_games/mines/saves --name=mines --force
    repo add:asset saved_games/hearts --force


Get information on configured saved game repositories
-----------------------------------------------------

    repo list --short
    repo status --unmodified DOTS


User tasks
---------

The task 'generate:remote' is a user task, it doesn't ship with RepoManager.

To view all the available tasks

    repo --tasks

or just

    repo -T

### Running tests on user tasks

    gem install bundler

    cd repo_manager
    bundle
    bundle exec cucumber

Backup
------

To backup the saved games, we will need another user task.  This on is called
'action:update'.  See [repo_manager/tasks/update.rb](repo_manager/tasks/update.rb)

    repo action:update

Synchronize
----------

Synchronizing saved games to another PC can be accomplished using Git's 'pull' command.

verify working folders are clean, if they are not, either revert them or commit and push

    repo status

pull from remote to all configured repos

    repo pull

Bash completion
---------------

Handy functions for use under Bash.  These work fine on Win32 using
Git-Bash.

* rcd: repo cd (change directory).  Wrapper for 'cd', allows for simple cd
  <repo name> to the working folder on the filesystem referenced by the 'path'
  configuration variable.
* rpushd: repo pushd (push directory).  Wrapper for 'pushd'.

Clean
-----
Resetting this example folder back to its shipping defaults

### Delete the git repositories

    rm -rf remote/hearts.git
    rm -rf remote/mines.git

    rm -rf saved_games/mines/saves/.git
    rm -rf saved_games/hearts/.git

### Remove the asset config files

    rm -rf repo_manager/assets/mines
    rm -rf repo_manager/assets/hearts

RepoManager
===========

Command line interface (CLI) for batch management of multiple Git repositories.

Overview
--------

RepoManager is a wrapper for Git, the distributed version control system.
RepoManager's wrapper functions allow a single git command to be executed
across multiple git repositories.

For example, you have two git repositories named 'repo1' and 'repo2' and
you want to check the status of both working folders.

### without repo_manager

    cd ~/workspace/delphi/repo1
    git status

    cd ~/workspace/delphi/repo2
    git status

### with repo_manager

    repo status

### suitable for

* Light weight mirroring of data across a network.  That is a job for
  rsync.  Or is it?  If you develop for multiple platforms across multiple
  (virtual) machines rsync'ing may not be the best option.  If you already
  have everything tucked into git repositories, you can use a single
  'repo pull'  command to mirror all of your repositories to one location
  for backup or reference.

### not suitable for

* Maintaining related source code repositories.  There are suitable tools
  for that including git's own 'git submodules',
  [git-subtree](https://github.com/apenwarr/git-subtree), and
  [GitSlave](http://gitslave.sourceforge.net/)


Getting started with RepoManager
--------------------------------

### installation

    gem install repo_manager

### help

    repo --help
    repo --tasks
    repo help generate:init

### generate configuration folder structure

    cd ~/workspace
    repo generate:init .repo_manager

generate:init output

      init  creating initial config file at '/home/robert/workspace/.repo_manager/repo.conf'
    create  .repo_manager/repo.conf
      init  creating initial file structure in '/home/robert/workspace/.repo_manager'
     exist  .repo_manager
    create  .repo_manager/.gitignore
    create  .repo_manager/assets/.gitignore
    create  .repo_manager/global/default/asset.conf
    create  .repo_manager/tasks/.gitignore

### generate individual repository configurations files

generate multiple config files by searching a folder, one level deep, for git repositories


    repo generate:config . --filter=mutagem,basic_*,repo_manager

generate config output

      collecting  collecting top level folder names
     configuring  setting discovered asset configuration paths
       comparing  looking for existing asset names
       comparing  looking for existing asset paths
    Discovered assets
           found  basic_gem                                path => './basic_gem'
           found  basic_website                            path => './basic_website'
           found  basic_assets                             path => './basic_assets'
           found  repo_manager                             path => './repo_manager'
           found  basic_app                                path => './basic_app'
           found  mutagem                                  path => './mutagem'
           found  basic_rails                              path => './basic_rails'

    Found 7 assets, write the configuration files (y/n)?

answer 'y'

    creating  repo_manager configuration file for basic_gem
    creating  repo_manager configuration file for basic_website
    creating  repo_manager configuration file for basic_assets
    creating  repo_manager configuration file for repo_manager
    creating  repo_manager configuration file for basic_app
    creating  repo_manager configuration file for mutagem
    creating  repo_manager configuration file for basic_rails


Example Usage - Managing game saves across multiple computers
-------------------------------------------------------------

See examples/pc_saved_game_backup/README.markdown


Bash completion
----------------

Handy functions for use under Bash.  These work fine on Win32 using
Git-Bash.

* rcd: repo cd (change directory).  Wrapper for 'cd', allows for simple cd
  <repo name> to the working folder on the filesystem referenced by the 'path'
  configuration variable.
* rpushd: repo pushd (push directory).  Wrapper for 'pushd'.


vim ~/.bashrc

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


Rake tasks
----------

bundle exec rake -T

    rake build         # Build repo_manager-0.0.1.gem into the pkg directory
    rake doc:clean     # Remove generated documenation
    rake doc:generate  # Generate YARD Documentation
    rake features      # Run Cucumber features
    rake install       # Build and install repo_manager-0.0.1.gem into system gems
    rake release       # Create tag v0.0.1 and build and push repo_manager-0.0.1.gem to Rubygems
    rake spec          # Run specs
    rake test          # Run specs and features


Development Environment
-----------------------

RepoManager was originally cloned from [BasicApp](http://github.com/robertwahler/BasicApp).

all systems

    cd ~/workspace
    git clone https://github.com/robertwahler/repo_manager
    cd repo_manager

    gem install bundler
    bundle

colored output on windows

    gem install win32console

Autotesting with Guard
----------------------

    bundle exec guard

## Copyright ##

Copyright (c) 2012 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.

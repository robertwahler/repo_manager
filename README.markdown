# Repoman #

Command line interface (CLI) for batch management of multiple Git repositories.

## Overview ##

Repoman is a wrapper for Git, the distributed version control system.
Repoman's wrapper functions allow a single git command to be executed
across multiple git repositories.

For example, you have two git repositories named 'repo1' and 'repo2' and
you want to check the status of both working folders.

### without repoman

    cd ~/workspace/delphi/repo1
    git status

    cd ~/workspace/delphi/repo2
    git status

### with repoman

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


## Getting started with Repoman

### installation

    gem install repoman

### help

    repo --help
    repo --tasks
    repo help generate:init

### generate configuration folder structure

    cd ~/workspace
    repo generate:init .repoman

generate:init output

      init  creating initial config file at '/home/robert/workspace/.repoman/repo.conf'
    create  .repoman/repo.conf
      init  creating initial file structure in '/home/robert/workspace/.repoman'
     exist  .repoman
    create  .repoman/.gitignore
    create  .repoman/assets/.gitignore
    create  .repoman/global/default/asset.conf
    create  .repoman/tasks/.gitignore

### generate individual repository configurations files

generate multiple config files by searching a folder, one level deep, for git repositories


    repo generate:config . --filter=mutagem,basic_*,repoman

generate config output

      collecting  collecting top level folder names
     configuring  setting discovered asset configuration paths
       comparing  looking for existing asset names
       comparing  looking for existing asset paths
    Discovered assets
           found  basic_gem                                path => './basic_gem'
           found  basic_website                            path => './basic_website'
           found  basic_assets                             path => './basic_assets'
           found  repoman                                  path => './repoman'
           found  basic_app                                path => './basic_app'
           found  mutagem                                  path => './mutagem'
           found  basic_rails                              path => './basic_rails'

    Found 7 assets, write the configuration files (y/n)?

answer 'y'

    creating  repoman configuration file for basic_gem
    creating  repoman configuration file for basic_website
    creating  repoman configuration file for basic_assets
    creating  repoman configuration file for repoman
    creating  repoman configuration file for basic_app
    creating  repoman configuration file for mutagem
    creating  repoman configuration file for basic_rails

## Example Usage

### Quick status of all the working folders in your workspace

TBD

### Mirroring Win32 code to the workspace of a Linux machine

TBD

### Managing game saves across multiple computers

TBD


## Configuration

TBD

## Extending Repoman by adding tasks

TBD


## Bash completion ######################################################

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

## Run-time dependencies ##

The following gems are required

* Term-ansicolor for optional color output <http://github.com/flori/term-ansicolor>
* Ruby-git for git repository support <http://github.com/schacon/ruby-git>


## Development dependencies ##

* Bundler for dependency management <http://github.com/carlhuda/bundler>
* Rspec for unit testing <http://github.com/dchelimsky/rspec>
* Cucumber for functional testing <http://github.com/aslakhellesoy/cucumber>
* YARD for documentation generation <http://github.com/lsegal/yard>


## Rake tasks ##

bundle exec rake -T

    rake build         # Build repoman-0.0.1.gem into the pkg directory
    rake doc:clean     # Remove generated documenation
    rake doc:generate  # Generate YARD Documentation
    rake features      # Run Cucumber features
    rake install       # Build and install repoman-0.0.1.gem into system gems
    rake release       # Create tag v0.0.1 and build and push repoman-0.0.1.gem to Rubygems
    rake spec          # Run specs
    rake test          # Run specs and features


## Development Environment ##

Repoman was originally cloned from [BasicApp](http://github.com/robertwahler/BasicApp).

all systems

    cd ~/workspace
    git clone https://github.com/robertwahler/repoman
    cd repoman

    gem bundle install
    bundle install

colored output on windows

    gem install win32console

Autotesting with Guard
----------------------

    bundle exec guard

## Copyright ##

Copyright (c) 2012 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.

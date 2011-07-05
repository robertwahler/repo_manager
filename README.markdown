Repoman
========

CLI for batch management of multiple Git repositories.  Repositories don't
need to be related.
<https://github.com/robertwahler/repoman>

Bash completion
---------------

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
      opts=`repo list --listing=name --no-color`

      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      return 0
    }
    complete -F _repo_names rcd rpushd repo

Run-time dependencies
---------------------
The following gems are required

* Term-ansicolor for optional color output <http://github.com/flori/term-ansicolor>
* Configatron for configuration support <http://github.com/markbates/configatron>
* Ruby-git for git repository support <http://github.com/schacon/ruby-git>


Development dependencies
------------------------

* Bundler for dependency management <http://github.com/carlhuda/bundler>
* Rspec for unit testing <http://github.com/dchelimsky/rspec>
* Cucumber for functional testing <http://github.com/aslakhellesoy/cucumber>
* Aruba for CLI testing <http://github.com/aslakhellesoy/aruba>
* YARD for documentation generation <http://github.com/lsegal/yard>
* Kramdown for documentation markup processing <https://github.com/gettalong/kramdown>


Rake tasks
----------

bundle exec rake -T

    rake build         # Build repoman-0.0.1.gem into the pkg directory
    rake doc:clean     # Remove generated documenation
    rake doc:generate  # Generate YARD Documentation
    rake features      # Run Cucumber features
    rake install       # Build and install repoman-0.0.1.gem into system gems
    rake release       # Create tag v0.0.1 and build and push repoman-0.0.1.gem to Rubygems
    rake spec          # Run specs
    rake test          # Run specs and features


Development Environment
-----------------------

all systems

    cd ~/workspace
    git clone https://github.com/robertwahler/repoman
    cd repoman

    gem bundle install
    bundle install

colored output on windows

    gem install win32console

Autotesting with Watchr
-------------------------

[Watchr](http://github.com/mynyml/watchr) provides a flexible alternative to Autotest.  A
jump start script is provided in spec/watchr.rb.

### Install watchr ###

    gem install watchr

### Run watchr ###

    watchr spec/watchr.rb

outputs a menu

    Ctrl-\ for menu, Ctrl-C to quit

Watchr will now watch the files defined in 'spec/watchr.rb' and run Rspec or Cucumber, as appropriate.
The watchr script provides a simple menu.

Ctrl-\

    MENU: a = all , f = features  s = specs, l = last feature (none), q = quit


Copyright
---------

Copyright (c) 2011 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.

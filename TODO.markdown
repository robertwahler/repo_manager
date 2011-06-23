TODO
====

* add dry-run option when adding features that can be destructive, i.e. commit, pull, copy, add, ...
* remove configatron usage from app.rb, put repos in @options hash
* status should show summary at the end
* move --short and --untracked option processing to app.status and provide help
* add feature tests for all combinations of XY result codes from 'git status --porcelain'
* remove unhelpful config command, use native instead
* verify relative and absolute paths both work with all config file locations
* remove dependency on ruby-git since we are only using native git calls now
* add alias examples: rpushd, rpopd, rcd
* add logger

subcommands
----------

  list
  path
  status

  init

  remote
    <no arg>
    show origin
    add origin git@red:grape/games/saves/real_myst.git

  config
    <no arg>
    branch.master.merge refs/heads/master
    core.autocrlf false
    core.filemode false
    branch.master.remote origin

    --list

  push
    <no arg>
    peach
    brown master

    --tags


  pull
    <no arg>
    origin master
    brown HEAD

  add
    <no arg>
    .

    -A
    -u

  commit
    -a
    -m


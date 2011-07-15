TODO
====

* options should be an array or array of strings when read from a  config
  file, that way they can be added to ARGV so they can be validated with
  the normal validation logic.
* stop using OptionParser, we don't want to use short options for non
  pass-through commands, checkout out 'slop'
* don't pass through destructive git commands unless they are in the approved
  list, i.e. prevent 'git reset'.  Alternatively, create a banned list that
  requires '--force'
* make sure common options are passed to git. i.e. '--verbose'
* provide native repo completion via --completion option so the entire ARGV can
  be scanned and passed back to bash.  We have to load ruby anyway, might as
  well provide completion for commands and options too.
* combine path and list commands
* add dry-run option when adding features that can be destructive, i.e. commit,
  pull, copy, add, ...
* status should show summary at the end
* add feature tests for all combinations of XY result codes from 'git status --porcelain'
* verify relative and absolute paths both work with all config file locations
* add logger
* add '--all' switch that sets the filter to '*' This is the default behaviour
  anyway.  Make it a required switch for the git action unless --repos/--filter
  switch used
* don't print path on status command, reserve that space for last commit

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


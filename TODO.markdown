TODO
====

* add generate:init task to create an initial configuration folder
* remove git gem and duplicate needed method.  The use of ENV[] will break on
  win32 and ruby 1.9.3
* add replaceable params as params: in master config file.  These  can be used
  in repo config yaml.
* add find action that finds a repo based on all strings in the repo config
* options should be an array or array of strings when read from a  config
  file, that way they can be added to ARGV so they can be validated with
  the normal validation logic.
* don't pass through destructive git commands unless they are in the approved
  list, i.e. prevent 'git reset'.  Use :include, :exclude hashes
* make sure common options are passed to git. i.e. '--verbose'
* provide native repo completion via --completion option so the entire ARGV can
  be scanned and passed back to bash.  We have to load ruby anyway, might as
  well provide completion for commands and options too.
* status should show summary at the end
* add feature tests for all combinations of XY result codes from 'git status --porcelain'
* status command should have option to show last commit information
* native git commands need to preserve ANSI escape codes for coloring
* add man page via markdown and ronn.  Change 'help' action to call man
  page if man available.

TODO
====

* remove git gem and duplicate needed method.  The use of ENV[] will break on
  win32 and ruby 1.9.3
* add find action that finds a repo based on all strings in the repo config
* don't pass through destructive git commands unless they are in the approved
  list, i.e. prevent 'git reset'.  Use :include, :exclude hashes
* provide native repo completion via --completion option so the entire ARGV can
  be scanned and passed back to bash.  We have to load ruby anyway, might as
  well provide completion for commands and options too.
* status should show summary at the end
* add feature tests for all combinations of XY result codes from 'git status --porcelain'
* status command should have option to show last commit information
* native git commands need to preserve ANSI escape codes for coloring
* add man page via markdown and ronn.  Change 'help' action to call man
  page if man available.

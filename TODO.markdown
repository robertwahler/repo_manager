TODO
====

* help commands should show global options as well as options for individual
  commands
* git native commands that are inferred by the missing 'git' action should not
  allow any args that match exactly to a repo name.  i.e.
      repo push # OK
      repo push screenshots # error
      repo git push screenshots # OK even though it still won't work
      repo push -r screenshots # OK and works as expected
      repo git push -r screenshots # OK and works as expected
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
* verify relative and absolute paths both work with all config file locations
* add logger
* add '--all' switch that sets the filter to '*' This is the default behaviour
  anyway.  Make it a required switch for the git action unless --repos/--filter
  switch used
* status command should have option to show last commit information
* native git commands need to preserve ANSI escape codes for coloring
* add JSON output for machine parsing, think "--porcelain" commands
* refactor app.rb and break each action in to its own file in the action
  folder. Each action will be based on action/base.rb.  Base includes common
  functions like "help" and "to_json".  Required for API usage.

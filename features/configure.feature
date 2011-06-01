@announce
Feature: Configuration via yaml file

  In order to configure options, as an interactive user or automated script,
  the program should process configuration options via yaml. These options
  should override hard coded defaults but not command line options.

  Config files are read from multiple locations in order of priority.  Once a
  config file is found, all other config files are ignored. Priority:
  ["./repo.conf", "./.repo.conf", "./config/repo.conf", "~/.repo.conf"]

  All command line options can be read from the config file from the "options:"
  block. This options block is optional.  The "repos" block describes the repo
  names and attributes.  The repos block is required.  Commands the operate on
  repos will fail if the repos block is invalid or missing.

  NOTE: All file system testing is done via the Aruba gem.  The home folder
  config file is stubbed to prevent testing contamination in case it exists.


  Scenario: Specified config file exists
    Given an empty file named "config.conf"
    When I run "repo path --verbose --config config.conf"
    Then the output should contain:
      """
      config file: config.conf
      """

  Scenario: Specified config file not found
    When I run "repo path --verbose --config config.conf"
    Then the exit status should be 1
    And the output should contain:
      """
      config file not found
      """

  Scenario: Reading options from config file with overrides on command line
    Given a file named "repo_no_coloring.conf" with:
      """
      ---
      options:
        coloring: false
      """
    And a file named "repo_with_coloring.conf" with:
      """
      ---
      options:
        coloring: true
      """
    When I run "repo path --verbose --config repo_no_coloring.conf"
    Then the output should contain:
      """
      :coloring=>false
      """
    When I run "repo path --verbose --config repo_no_coloring.conf --coloring"
    Then the output should contain:
      """
      :coloring=>true
      """
    When I run "repo path --verbose --config repo_with_coloring.conf"
    Then the output should contain:
      """
      :coloring=>true
      """
    When I run "repo path --verbose --config repo_with_coloring.conf --no-coloring"
    Then the output should contain:
      """
      :coloring=>false
      """


  Scenario: Reading default valid config files ordered by priority


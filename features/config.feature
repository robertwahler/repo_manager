@announce
Feature: Configuration via yaml file

  In order to configure options, as an interactive user or automated script,
  the program should process configuration options via yaml. These options
  should override hard coded defaults but not command line options.

  Config files are read from multile locations in order of priorty.  Once a
  config file is found, all other config files are ignored. Priorty:
  ["./repo.conf", "./.repo.conf", "./config/repo.conf", "~/.repo.conf"]

  All command line options can be read from the config file from the "options:"
  block. This options block is optional.  The "repos" block describes the repo
  names and attributes.  The repos block is required.  Commands the operate on
  repos will fail if the repos block is invalid or missing.


  Background: A valid config file
  Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """

  Scenario: Config file exists
    Given an empty file named "config.conf"
    When I run "repo path --verbose --config config.conf"
    Then the output should contain:
      """
      loading config file: config.conf
      """

  Scenario: Config file not found
    When I run "repo path --verbose --config config.conf"
    Then the output should not contain:
      """
      loading config file: config.conf
      """
    And the exit status should be 1
    And the output should contain:
      """
      config file not found
      """

  Scenario: Reading valid config files ordered by priority


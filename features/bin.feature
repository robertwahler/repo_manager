@announce
Feature: Options via a command line interface (CLI)

  The application should accept options on the command line.  These options
  should override hard coded defaults

 Background: Empty configuration file so that we don't read global config locations
   Given an empty file named "repo.conf"

  Scenario: Version info
    When I run `repo --version`
    Then the exit status should be 0
    And the output should match /repo_manager, version ([\d]+\.[\d]+\.[\d]+$)/

  Scenario: Help
    When I run `repo --help`
    Then the exit status should be 0
    And the output should match:
      """
      .*
        Usage: .*
      """

  Scenario: Invalid option
    When I run `repo --non-existing-option`
    Then the exit status should be 1
    And the output should match:
      """
      ^.* invalid option: --non-existing-option
      ^.* --help for more information

      """

  Scenario: Invalid action
    When I run `repo non-existing-action`
    Then the exit status should be 1
    And the output should match:
      """
      ^.* invalid action: non-existing-action
      ^.* --help for more information

      """

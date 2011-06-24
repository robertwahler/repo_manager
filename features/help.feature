@announce
Feature: Show help on pass-through command/action options

  The application should detail which Git command options
  are available as pass-through options.

  Example usage:

    repo help init
    repo help git

  Scenario: Valid command, help available
    When I run "repo help init"
    Then the exit status should be 0
    And the output should contain:
      """
      Usage: repo init
      """

  Scenario: Valid command, no help available
    When I run "repo help path"
    Then the exit status should be 0
    And the output should contain:
      """
      no help available for action
      """

  Scenario: Missing command
    When I run "repo help"
    Then the exit status should be 0
    And the output should contain:
      """
      no action specified
      """

  Scenario: Invalid command
    When I run "repo help badaction"
    Then the exit status should be 0
    And the output should contain:
      """
      invalid action
      """

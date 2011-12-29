Feature: Show help on pass-through command/action options

  The application should detail which Git command options are available as
  pass-through options.

  Show help test to STDOUT for a given action.

  Example usage:

    repo help init
    repo help git
	repo help help

 Scenario Outline: Valid action, help available
    When I run `repo help <action>`
    Then the exit status should be 0
    And the last output should match:
      """
      Usage: repo.* <action>
      """

  Examples:
    | action  |
    | git     |
    | help    |
    | init    |
    | list    |
    | path    |
    | status  |

  Scenario: Missing action
    When I run `repo help`
    Then the exit status should be 0
    And the output should contain:
      """
      no action specified
      """

  Scenario: Invalid action
    When I run `repo help badaction`
    Then the exit status should be 0
    And the output should contain:
      """
      invalid help action
      """
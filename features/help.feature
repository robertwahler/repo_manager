Feature: Show help on pass-through command/action options

  The application should detail which Git command options
  are available as pass-through options.

  Example usage:

    repo help init
    repo help git

 Scenario Outline: Valid action, help available
    When I run `repo help <action>"
    Then the exit status should be 0
    And the output should match:
      """
      Usage: .* <action> .*
      """

  Examples:
    | action  |
    | init    |
    | git     |
    | list    |
    | path    |
    | status  |
    | help    |

  Scenario: Missing action
    When I run `repo help"
    Then the exit status should be 0
    And the output should contain:
      """
      no action specified
      """

  Scenario: Invalid action
    When I run `repo help badaction"
    Then the exit status should be 0
    And the output should contain:
      """
      invalid action
      """

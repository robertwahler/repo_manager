Feature: Show help on actions

  Example usage:

    basic_app help help

 Scenario Outline: Valid action, help available
    When I run `basic_app help <action>`
    Then the exit status should be 0
    And the last output should match:
      """
      Usage: basic_app.* <action>
      """

  Examples:
    | action  |
    | help    |

  Scenario: Missing action
    When I run `basic_app help`
    Then the exit status should be 0
    And the output should contain:
      """
      no action specified
      """

  Scenario: Invalid action
    When I run `basic_app help badaction`
    Then the exit status should be 0
    And the output should contain:
      """
      invalid help action
      """

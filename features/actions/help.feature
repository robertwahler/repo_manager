Feature: Show help on actions

  Show action specific help to STDOUT for a given action

  Example usage:

      basic_app help list
      basic_app help task
      basic_app help help

  Notes

  * abbreviated help general app help is available via the --help option

 Background: Empty configuration file so that we don't read global config locations
   Given an empty file named "basic_app.conf"

 Scenario Outline: Valid action, help available
    When I run `basic_app help <action>`
    Then the exit status should be 0
    And its output should match:
      """
      Usage: basic_app.* <action>
      """
    And its output should match:
      """
      Options:
      """

  Examples:
    | action  |
    | help    |
    | list    |
    | task    |

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

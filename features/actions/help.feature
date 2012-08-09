Feature: Show help on actions

  Show action specific help to STDOUT for a given action

  Example usage:

      repo help list
      repo help task
      repo help help

  Notes

  * abbreviated help general app help is available via the --help option

 Background: Empty configuration file so that we don't read global config locations
   Given an empty file named "repo.conf"

 Scenario Outline: Valid action, help available
    When I run `repo help <action>`
    Then the exit status should be 0
    And its output should match:
      """
      Usage: repo.* <action>
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
    | git     |
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

  Scenario: Returning a list of actions for CLI completion
    When I run `basic_app help --actions`
    Then the exit status should be 0
    And the output should contain:
      """
      help
      list
      task
      """

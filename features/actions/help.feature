Feature: Show help on actions

  Show action specific help to STDOUT for a given action

  Example usage:

      repo help list
      repo help task
      repo help help

  Notes

  * abbreviated help general app help is available via the --help option

 Background: Default empty configuration file
    Given an empty file named "repo.conf"

 Scenario Outline: Valid action, help available
    When I run `repo help <action>`
    Then the exit status should be 0
    And the last output should match:
      """
      Usage: repo.* <action>
      """
    And the last output should match:
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

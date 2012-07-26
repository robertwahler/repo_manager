@announce
Feature: Generate init task

  End-user generation of a repoman configuration

  Example commands:

      repo task generate:init .repoman
      repo task generate:init .
      repo task generate:init repoman --force --verbose

  Scenario: Specify path on the command line
    When I run `repo task generate:init nodefault --no-config --verbose`
    Then the exit status should be 0
    Then the output should contain:
      """
      creating initial file structure
      """
    And the following files should exist:
      | nodefault/assets/.gitignore                |
      | nodefault/global/default/asset.conf        |
      | nodefault/tasks/.gitignore                 |

  Scenario: Path not specified
    When I run `repo task generate:init --no-config`
    Then the exit status should be 1
    Then the output should contain:
      """
      repo init requires at least 1 argument
      """

  Scenario: Config file not found
    When I run `repo task generate:init . --config=BadConfig.conf`
    Then the exit status should be 1
    Then the output should contain:
      """
      config file not found
      """

  Scenario: A file exists at destination and is not overwritten when answering 'No'
    Given a file named ".gitignore" with:
      """
      .my.file.3234134
      """
    When I run `repo task generate:init . --no-config` interactively
    When I type "n"
    Then the exit status should be 0
    And the following files should exist:
      | .gitignore             |
    And the file ".gitignore" should contain:
      """
      .my.file.3234134
      """
    And the following files should exist:
      | assets/.gitignore      |


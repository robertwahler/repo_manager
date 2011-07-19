@announce
Feature: Options via a command line interface (CLI)

  As an interactive user or automated script
  The application should accept options on the command line
  These options should override hard coded defaults
  In order to configure options

  Scenario: Version info
    When I run `basic_app --version`
    Then the exit status should be 0
    And the output should match /basic_app, version ([\d]+\.[\d]+\.[\d]+$)/

  Scenario: Help
    When I run `basic_app --help`
    Then the exit status should be 0
    And the output should match:
      """
      .*
        Usage: .*
      .*
      Options:
      .*
          -v, --\[no-\]verbose               Run verbosely
      """

  Scenario: Invalid option
    When I run `basic_app --non-existing-option`
    Then the exit status should be 1
    And the output should match:
      """
      ^.* invalid option: --non-existing-option
      ^.* --help for more information

      """

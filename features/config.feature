@announce
Feature: Setting repo configuration options

  As an interactive user or automated script. The application should set
  indiviual repository options from the command line

  Background: A valid config file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a repo in folder "test_path_2" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """


  Scenario: Normal (success)
    When I run "repo config 'user.name my_name'"
    Then the exit status should be 0
    And the file "test_path_1/.git/config" should contain:
      """
      name = my_name
      """

  Scenario: Bad config key command, missing section (failure [2])
    When I run "repo config 'missing_section some_value'"
    Then the exit status should be 2
    And the output should contain:
      """
      error: key does not contain a section: missing_section
      """
    And the file "test_path_1/.git/config" should not contain:
      """
      missing_section
      """

  Scenario: Using the git '--global' option (failure)
    When I run "repo config 'user.name my_name --global'"
    Then the exit status should not be 0
    And the output should contain:
      """
      config option not allowed
      """

  Scenario: Using the git '--system' option (fails)
    When I run "repo config 'user.name my_name --system'"
    Then the exit status should not be 0
    And the output should contain:
      """
      config option not allowed
      """

  Scenario: Invalid repo
    Given I delete the folder "test_path_2/.git"
    When I run "repo config 'user.name my_name'"
    Then the exit status should be 3
    And the output should contain:
      """
      test2: test_path_2 [unable to read repo]
      """

  Scenario: Missing repo folder
    Given I delete the folder "test_path_2"
    When I run "repo config 'user.name my_name'"
    Then the exit status should be 3
    And the output should contain:
      """
      test2: test_path_2 [unable to read repo]
      """


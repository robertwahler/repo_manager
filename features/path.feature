@announce
Feature: Listing repo path information

  As an interactive user or automated script
  The application should show the repository path
  to stdout so that it can be used for scripting

  Background: A valid config file
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """

  Scenario: No filter, valid config, valid repos
    When I run "repo path"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario:Single Filter
    When I run "repo path test"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """
    When I run "repo path test$"
    Then the exit status should be 0
    And the output should not contain:
      """
      test_path_1
      """
    When I run "repo path t.st1"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      """
    And the output should not contain:
      """
      test_path_2
      """

  Scenario:Multiple filters
    When I run "repo path test1 test2 test3"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """
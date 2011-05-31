@announce
Feature: Listing repo path information

  As an interactive user or automated script. The application should show the
  repository status to stdout

  Background: A valid config file
    Given a repo named "test1" in folder "test_path_1"
    And a repo named "test2" in folder "test_path_2"
    And a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """

  Scenario: No uncommited changes, no filter, valid config, valid repos
    When I run "repo status"
    Then the exit status should be 0
    And the output should contain:
      """
      ..
      """

  Scenario: One uncommited change
    Given I append to "test_path_1/.gitignore" with:
      """
      tmp/*
      log/
      """
    When I run "repo status"
    Then the exit status should be 1
    And the output should contain:
      """
      test1: test_path_1
        modified: .gitignore
      .
      """

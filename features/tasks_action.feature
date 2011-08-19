@announce
Feature: Thor action tasks


  Run repo add -A, repo commit, and repo push on all dirty repos via Thor

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
      config: *.yml
      """
    And a file named "repo1.yml" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
      """
    And a file named "repo2.yml" with:
      """
      ---
      repos:
        test2:
          path: test_path_2
      """


  Scenario: No uncommitted changes
    When I run `thor repoman:action:update`
    Then the output should contain:
      """
      no changed repos
      """

  Scenario: One uncommitted change
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run `thor repoman:action:update`
    Then the output should contain:
      """
      updating test1
      """
    And the output should not contain:
      """
      test2
      """
    When I run `repo status`
    Then the exit status should be 0

@announce
Feature: Thor action tasks

  Run repo add -A, repo commit, and repo push on all dirty repos via Thor

  Background: Test repositories and a valid config file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a repo in folder "test_path_2" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a file named "repo.conf" with:
      """
      ---
      config: repos/*.yml
      """
    And a file named "repos/repo1.yml" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
      """
    And a file named "repos/repo2.yml" with:
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

  Scenario: Uncommitted changes in multiple repos, non-interactive, custom commit message
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    And a repo in folder "test_path_2" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
      | test             | ?      | test     |
    And the repo in folder "test_path_1" has a remote named "origin" in folder "test_path_1.remote.git"
    And the repo in folder "test_path_2" has a remote named "origin" in folder "test_path_2.remote.git"
    When I run `thor repoman:action:update --force --message="my custom commit message"`
    Then the output should contain:
      """
      updating test1,test2
      adding...
      committing...
      pushing...
      """
    And the output should not contain:
      """
      failed
      """
    When I run `repo status --no-verbose`
    Then the exit status should be 0
    When I run `repo --no-verbose git log -1 --pretty=format:'%s' --repos test1`
    Then the output should contain:
      """
      my custom commit message
      """
    Then the output should not contain:
      """
      automatic commit
      """
    When I run `repo push --no-verbose --repos test1`
    Then its output should contain:
      """
      up-to-date
      """

  @slow_process
  Scenario: Uncommitted changes in a single repo, interactive prompt to continue
    And a repo in folder "test_path_2" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
      | test             | ?      | test     |
    And the repo in folder "test_path_2" has a remote named "origin" in folder "test_path_2.remote.git"
    When I run `thor repoman:action:update` interactively
    And I type "y"
    Then the output should contain:
      """
      updating test2
      adding...
      committing...
      pushing...
      """
    And the output should not contain:
      """
      failed
      """
    When I run `repo status --no-verbose`
    Then the exit status should be 0
    When I run `repo --no-verbose git log -1 --pretty=format:'%s' --repos test2`
    Then the output should contain:
      """
      automatic commit
      """
    When I run `repo push --no-verbose --repos test2`
    Then its output should contain:
      """
      up-to-date
      """

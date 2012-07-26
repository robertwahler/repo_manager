@announce
Feature: Automatically commit and update multiple repos

  This task will run:

      repo add -A, repo commit, and repo push on all dirty repos

  Examples

    Interactive

      repo action:update

    Non-interactive

      repo action:update --force

    Filter repos

      repo action:update --repos=repo1,repo2

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
      folders:
        assets : repo/asset/configuration/files
      """
    And the folder "repo/asset/configuration/files" with the following asset configurations:
      | name    | path         |
      | test1   | test_path_1  |
      | test2   | test_path_2  |


  Scenario: No uncommitted changes
    When I run `repo action:update`
    Then the output should contain:
      """
      no changed repos
      """

  Scenario: Uncommitted changes filtered out with the '--repos' param
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    And a repo in folder "test_path_2" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
      | test             | ?      | test     |
    And a repo in folder "my_clean_repo" with the following:
      | filename         | status | content  |
      | .gitignore       | C      | tmp/*    |
    When I run `repo action:update --force --repos=my_clean_repo`
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
    When I run `repo action:update --force --message="my custom commit message"`
    Then the output should contain:
      """
      updating test1,test2
      """
    And the output should contain:
      """
      update finished
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
    When I run `repo action:update` interactively
    And I type "y"
    Then the output should contain:
      """
      updating test2
      """
    And the output should contain:
      """
      update finished
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

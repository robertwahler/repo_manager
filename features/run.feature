@announce
Feature: Running an arbitrary git command

  As an interactive user or automated script. The application should run an
  arbitrary git command echoing output and collecting status result codes.

  Example usage:

    repo run ls-files
    repo run git ls-files

    repo run add .
    repo run add . --filter=test
    repo run git add . --filter=test

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

  Scenario: Run 'git ls-files' on each repo
    When I run "repo run git ls-files"
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test_path_1
      .gitignore
      test2: test_path_2
      .gitignore
      """

  Scenario: Run 'ls-files' on each repo, 'git' is an optional first argument
    When I run "repo run ls-files"
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test_path_1
      .gitignore
      test2: test_path_2
      .gitignore
      """

  Scenario: Run 'git status' on each repo with no changes
    When I run "repo run git status --porcelain"
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test_path_1

      test2: test_path_2

      """

  Scenario: Run 'git status' on each repo with uncommited change
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run "repo run git status --porcelain"
    Then the exit status should be 4
    And the output should contain:
      """
      test1: test_path_1
       M .gitignore
      test2: test_path_2

      """

#   Scenario: Missing all run arguments
#     When I run "repo run"
#     Then the exit status should be 1
#     And the output should contain:
#       """
#       no git command given
#       """

#   Scenario: Invalid repo
#     Given I delete the folder "test_path_2/.git"
#     When I run "repo status test1 test2 --unmodified DOTS"
#     Then the exit status should be 2
#     And the output should contain:
#       """
#       .
#       I    test2: test_path_2 [not a valid repo]
#       """

#   Scenario: Missing repo folder
#     Given I delete the folder "test_path_2"
#     When I run "repo status --filter=test2 --unmodified DOTS --no-verbose"
#     Then the exit status should be 1
#     And the output should contain exactly:
#       """
#       X    test2: test_path_2 [no such folder]
#       """


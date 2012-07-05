@announce
Feature: Running an arbitrary git command

  The application should run an arbitrary git command echoing output and
  collecting status result codes.  Repoman provides alternatives to some of the
  git commands. For example, Repoman has its own status command that provides
  summary information.  To use the native command, you must place the arg 'git'
  in front of the status command.

  Example:

   Run the native Git status command

      repo git status -v

   Run Repoman version of the status command

      repo status -v

   Add and commit all

      repo add .
      repo commit -m "automatic add and commit"

   Since there is no Repoman version of the 'ls-files' command, these command
   lines are equivalent:

      repo git ls-files --others --ignored -v
      repo ls-files --others --ignored -v

   These command lines are also equivalent, note the alias for '--filter' is '--repos':

      repo add . --filter=test
      repo git add . --filter=test
      repo git add . --repos=test

    Git native commands do not allow any args that match exactly to a repo name
    unless a filter is specified or args=0.  Example, if 'screenshots' is a
    repo name:

        repo push # OK
        repo push screenshots # error
        repo git push screenshots # error
        repo push -r screenshots # OK
        repo git push -r screenshots # OK

    Short formatted log information

      repo git log -1 --pretty=format:"%h committed %cr"

  Background: A valid config file
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        repos  : repo_assets
      """
    And a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a repo in folder "test_path_2" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And the folder "repo_assets" with the following asset configurations:
      | name       | path          |
      | test1      | test_path_1   |
      | test2      | test_path_2   |

  Scenario: Missing all run arguments
    When I run `repo git`
    Then the exit status should be 1
    And the output should contain:
      """
      no git command given
      """

  Scenario: Run 'git ls-files' on each repo
    When I run `repo git ls-files`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      .gitignore
      test2
      .gitignore
      """

  Scenario: Run 'ls-files' on each repo, 'git' is an optional first argument
    When I run `repo ls-files`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      .gitignore
      test2
      .gitignore
      """

  Scenario: Run 'ls-files' on each repo using a filter
    When I run `repo --verbose ls-files --repos=test1`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      .gitignore
      """
    And the output should not contain:
      """
      test2
      .gitignore
      """

  Scenario: Run 'ls-files' using a repo name as an argument with no filter
    supplied (failure)
    When I run `repo  ls-files test1`
    Then the exit status should be 1
    And the output should contain:
      """
      'test1' cannot be used as a filter
      """

  Scenario: Run 'git ls-files' using a repo name as an argument with no filter
    supplied (failure)
    When I run `repo git ls-files test1`
    Then the exit status should be 1
    And the output should contain:
      """
      'test1' cannot be used as a filter
      """

  Scenario: Run 'git ls-files' using argument that is not a repo name with no
    filter supplied (success)
    When I run `repo git ls-files .gitignore`
    Then the exit status should be 0

  Scenario: Run 'git status' on each repo with no changes
    When I run `repo git status`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      # On branch master
      nothing to commit (working directory clean)
      test2
      # On branch master
      nothing to commit (working directory clean)
      """

  Scenario: Run 'git status --porcelain' on each repo with no changes shows nothing on stdout
    When I run `repo git status --porcelain`
    Then the exit status should be 0
    And the output should not contain:
      """
      test1: test_path_1
      """
    And the output should not contain:
      """
      test2: test_path_2
      """

  Scenario: Run native 'git status' on each repo with uncommited change
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run `repo --verbose git status --porcelain`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
       M .gitignore
      """

  Scenario: Run native git status command on an invalid repo
    Given the folder "repo_assets" with the following asset configurations:
      | name       | path          |
      | test1      | test_path_1   |
      | test2      | test_path_2   |
      | bad_repo   | not_a_repo    |
    And a directory named "not_a_repo"
    When I run `repo git status --porcelain --repos=test1,test2,bad_repo`
    Then the exit status should be 128
    And the output should contain:
      """
      bad_repo
      fatal: Not a git repository
      """

  Scenario: Run Repoman status command on an invalid repo
    Given the folder "repo_assets" with the following asset configurations:
      | name       | path          |
      | test1      | test_path_1   |
      | test2      | test_path_2   |
      | bad_repo   | not_a_repo    |
    And a directory named "not_a_repo"
    When I run `repo status --repos=test1,bad_repo --unmodified=SHOW --no-verbose`
    Then the exit status should be 2
    And the normalized output should contain:
      """
      I       bad_repo: ./not_a_repo [not a valid repo]
              test1
      """

  Scenario: Native and repoman status command missing repo folder has different
    exit status values
    Given the folder "repo_assets" with the following asset configurations:
      | name       | path          |
      | bad_repo   | bad_repo_path |
    When I run `repo git status --filter=bad_repo --unmodified DOTS --no-verbose`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      bad_repo: ./bad_repo_path [no such path]

      """
    When I run `repo status --filter=bad_repo --unmodified DOTS --no-verbose`
    Then the exit status should be 1


  Scenario: Folders with spaces in path
    Given a repo in folder "test 1/test path 1" with the following:
      | filename         | status | content   |
      | testfile 1.txt   | CM     | something |
    And a file named "repo1.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      """
    When I run `repo git ls-files --config=repo1.conf`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      testfile 1.txt
      test2
      .gitignore
      """

  Scenario: Git 'add' on a repo with uncommited change
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run `repo add . --repo test1`
    Then the exit status should be 0
    And the output should not contain:
      """
      test1: test_path_1
      """

  Scenario: Git 'commit' on a repo with an added file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | new_stuff.txt    | A      | tmp/*    |
    When I run `repo commit -m 'automatic commit via repoman' --repos test1`
    Then the exit status should be 0
    And the output should contain:
      """
       1 files changed, 1 insertions(+), 0 deletions(-)
      """

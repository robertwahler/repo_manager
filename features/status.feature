@announce
Feature: Listing repo path information

  As an interactive user or automated script. The application should show the
  repository status to stdout

  Example usage:

    repo status
    repo status --short
    repo status repo1 --unmodified DOTS
    repo status repo1 repo2 --unmodified DOTS

  Equivalent filtering:

    repo status --filter=test2 --unmodified DOTS
    repo status test2 --unmodified DOTS"

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

  Scenario: No uncommitted changes, default output
    When I run `repo status`
    Then the exit status should be 0
    And the output should contain:
      """
      no modified repositories, all working folders are clean
      """
    And the output should not contain:
      """
      ..
      """

  Scenario: No uncommitted changes, using dots to show progress, one dot per file
    When I run `repo status --unmodified=DOTS`
    Then the output should contain:
      """
      ..
      no modified repositories, all working folders are clean
      """

  Scenario: Uncommittable changes don't show
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | test_file3.txt   | C      | hi file3 |
    When I run `touch test_path_1/test_file3.txt`
    And I run `repo status`
    Then the exit status should be 0
    Then the output should contain:
      """
      no modified repositories, all working folders are clean
      """

  Scenario: Invalid repo
    Given I delete the folder "test_path_2/.git"
    When I run `repo status test1 test2 --unmodified DOTS`
    Then the exit status should be 2
    And the output should contain:
      """
      .
      I    test2: test_path_2 [not a valid repo]
      """

  Scenario: Missing repo folder
    Given I delete the folder "test_path_2"
    When I run `repo status --filter=test2 --unmodified DOTS --no-verbose`
    Then the exit status should be 1
    And the output should contain exactly:
      """
      X    test2: test_path_2 [no such folder]

      """

  Scenario: One uncommitted change
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 4
    And the output should contain:
      """
      M    test1: test_path_1
             modified: .gitignore
      .
      """

  Scenario: One uncommitted change, don't show individual files
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run `repo status --short --unmodified=DOTS`
    And the output should contain:
      """
      M    test1: test_path_1
      .
      """

  Scenario: One new file added
    Given a repo in folder "test_path_2" with the following:
      | filename      | status | content          |
      | new_file2.txt | A      | hello new file2  |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 8
    And the output should contain:
      """
      .
        A  test2: test_path_2
             added: new_file2.txt
      """
    And the output should not contain:
      """
      no modified repositories, all working folders are clean
      """

  Scenario: One existing file added to the index
    Given a repo in folder "test_path_2" with the following:
      | filename      | status | content    |
      | .gitignore    | A      | new_stff   |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 8
    And the output should contain:
      """
      .
        A  test2: test_path_2
             added: .gitignore
      """

  Scenario: One deleted file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status |
      | .gitignore       | D      |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 16
    And the output should contain:
      """
         D test1: test_path_1
             deleted: .gitignore
      .
      """

  Scenario: Two untracked files
    Given a repo in folder "test_path_1" with the following:
      | filename      | status | content          |
      | new_file1.txt | ?      | hello new file1  |
      | new_file2.txt | ?      | hello new file2  |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 32
    And the output should contain:
      """
       ?   test1: test_path_1
             untracked: new_file1.txt
             untracked: new_file2.txt
      .
      """

  Scenario: One uncommitted change, two untracked files, one added, and one deleted file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content            |
      | deleted_file.txt | D      | hello deleted file |
    And a repo in folder "test_path_1" with the following:
      | filename         | status | content            |
      | added_file.txt   | A      | hello added file   |
      | .gitignore       | M      | tmp/*              |
      | new_file1.txt    | ?      | hello new file1    |
      | new_file2.txt    | ?      | hello new file2    |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 60
    And the output should contain:
      """
      M?AD test1: test_path_1
             modified: .gitignore
             untracked: new_file1.txt
             untracked: new_file2.txt
             added: added_file.txt
             deleted: deleted_file.txt
      .
      """

  Scenario: Two untracked files, one is gitignored
    Given a repo in folder "test_path_1" with the following:
      | filename      | status | content          |
      | .gitignore    | DC     | new_file2.txt    |
      | new_file1.txt | ?      | hello new file1  |
      | new_file2.txt | ?      | hello new file2  |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 32
    And the output should contain:
      """
       ?   test1: test_path_1
             untracked: new_file1.txt
      .
      """

  Scenario: Folders with spaces in path, run 'git ls-files' on each repo
    Given a repo in folder "test 1/test path 1" with the following:
      | filename         | status | content  |
      | .gitignore       | CM     | tmp/*    |
    And a file named "repo1.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      """
    When I run `repo status --unmodified=DOTS --config=repo1.conf`
    Then the exit status should be 4
    And the output should contain:
      """
      M    test1: test 1/test path 1
             modified: .gitignore
      .
      """

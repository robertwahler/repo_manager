@announce
Feature: Listing repo path information

  Show the repository status to stdout

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
    Given a file named "repo.conf" with:
      """
      ---
      config: *.yml
      repos:
        bad_repo:
          path: not_a_repo
      """
    And a directory named "not_a_repo"
    When I run `repo status test1 test2 bad_repo --unmodified DOTS --no-verbose`
    Then the exit status should be 2
    And the normalized output should contain:
      """
      I       bad_repo: not_a_repo [not a valid repo]
      ..
      """

  Scenario: Missing repo folder
    Given a file named "repo.conf" with:
      """
      ---
      config: *.yml
      repos:
        bad_repo:
          path: not_a_repo
      """
    When I run `repo status --filter=bad_repo --unmodified DOTS --no-verbose`
    Then the exit status should be 1
    And the normalized output should contain:
      """
      X       bad_repo: not_a_repo [no such path]
      """

  Scenario: One uncommitted change
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 4
    And the normalized output should contain:
      """
      M       test1
                modified: .gitignore
      .
      """

  Scenario: One uncommitted change, don't show individual files
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run `repo status --short --unmodified=DOTS`
    And the normalized output should contain:
      """
      M       test1
      .
      """

  Scenario: One new file added
    Given a repo in folder "test_path_2" with the following:
      | filename      | status | content          |
      | new_file2.txt | A      | hello new file2  |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 8
    And the normalized output should contain:
      """
      .
        A     test2
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
    And the normalized output should contain:
      """
      .
        A     test2
                added: .gitignore
      """

  Scenario: One deleted file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status |
      | .gitignore       | D      |
    When I run `repo status --unmodified=DOTS`
    Then the exit status should be 16
    And the normalized output should contain:
      """
         D    test1
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
    And the normalized output should contain:
      """
       ?      test1
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
    And the normalized output should contain:
      """
      M?AD    test1
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
    And the normalized output should contain:
      """
       ?      test1
                untracked: new_file1.txt
      .
      """

  Scenario: Folders with spaces in path
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
    And the normalized output should contain:
      """
      M       test1
                modified: .gitignore
      .
      """

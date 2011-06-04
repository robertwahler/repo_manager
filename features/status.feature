@announce
Feature: Listing repo path information

  As an interactive user or automated script. The application should show the
  repository status to stdout

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

  Scenario: No uncommited changes, no filter, valid config, valid repos
    When I run "repo status"
    Then the exit status should be 0
    And the output should contain:
      """
      no modified repositories, all working folders are clean
      """
    And the output should not contain:
      """
      ..
      """
    When I run "repo status --unmodified=DOTS"
    Then the output should contain:
      """
      ..
      no modified repositories, all working folders are clean
      """

  Scenario: Uncommitable changes don't show
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | test_file3.txt   | C      | hi file3 |
    When I run "repo status"
    Then the exit status should be 0
    And the output should contain:
      """
      no modified repositories, all working folders are clean
      """
    When I run "touch test_path_1/test_file3.txt"
    And I run "repo status"
    Then the output should contain:
      """
      no modified repositories, all working folders are clean
      """

  Scenario: Invalid repo
    Given I delete the folder "test_path_1/.git"
    When I run "repo status test1"
    Then the exit status should be 2
    And the output should contain:
      """
      not a valid repo
      """

  Scenario: Missing repo folder
    Given I delete the folder "test_path_1"
    When I run "repo status test1"
    Then the exit status should be 1
    And the output should contain:
      """
      no such folder
      """

  Scenario: One uncommited change
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | M      | tmp/*    |
    When I run "repo status --unmodified=DOTS"
    Then the exit status should be 4
    And the output should contain:
      """
      M    test1: test_path_1
             modified: .gitignore
      .
      """
    When I run "repo status --short --unmodified=DOTS"
    And the output should contain:
      """
      M    test1: test_path_1
      .
      """

  Scenario: One added file
    Given a repo in folder "test_path_2" with the following:
      | filename      | status | content          |
      | new_file2.txt | A      | hello new file2  |
    When I run "repo status --unmodified=DOTS"
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

  Scenario: One deleted file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status |
      | .gitignore       | D      |
    When I run "repo status --unmodified=DOTS"
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
    When I run "repo status --unmodified=DOTS"
    Then the exit status should be 32
    And the output should contain:
      """
       ?   test1: test_path_1
             untracked: new_file1.txt
             untracked: new_file2.txt
      .
      """

  Scenario: One uncommited change, two untracked files, one added, and one deleted file
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content            |
      | deleted_file.txt | D      | hello deleted file |
    And a repo in folder "test_path_1" with the following:
      | filename         | status | content            |
      | added_file.txt   | A      | hello added file   |
      | .gitignore       | M      | tmp/*              |
      | new_file1.txt    | ?      | hello new file1    |
      | new_file2.txt    | ?      | hello new file2    |
    When I run "repo status --unmodified=DOTS"
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
    When I run "repo status --unmodified=DOTS"
    Then the exit status should be 32
    And the output should contain:
      """
       ?   test1: test_path_1
             untracked: new_file1.txt
      .
      """

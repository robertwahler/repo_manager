@announce
Feature: Setting repo configuration options

  As an interactive user or automated script. The application should set
  indiviual repository options from the command line

  Example usage:

    repo config
    repo config --list --filter=t.*

    repo config core.autocrlf false
    repo config core.filemode false --filter=test1

    repo config branch.master.remote origin
    repo config branch.master.merge refs/heads/master


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

  Scenario: Normal no filtering
    When I run "repo config core.testname find_me_here"
    Then the exit status should be 0
    And the file "test_path_1/.git/config" should contain:
      """
      testname = find_me_here
      """
    And the file "test_path_2/.git/config" should contain:
      """
      testname = find_me_here
      """

  Scenario: Normal with filtering
    When I run "repo config core.testname find_me_here --filter=test1"
    Then the exit status should be 0
    And the file "test_path_1/.git/config" should contain:
      """
      testname = find_me_here
      """
    And the file "test_path_2/.git/config" should not contain:
      """
      testname = find_me_here
      """

  Scenario: Setting the default origin for push/pull with filtering. The
    following section will be added to the config file:
      [branch "master"]
        remote = origin
        merge = refs/heads/master
    Given the file "test_path_1/.git/config" should not contain:
      """
      [branch "master"]
      """
    When I run "repo config branch.master.remote origin --filter=test1"
    Then the exit status should be 0
    And I run "repo config branch.master.merge refs/heads/master --filter=test1"
    Then the exit status should be 0
    And the file "test_path_2/.git/config" should not contain:
      """
      [branch "master"]
      """
    And the file "test_path_1/.git/config" should contain:
      """
      [branch "master"]
      """
    And the file "test_path_1/.git/config" should contain:
      """
      remote = origin
      """
    And the file "test_path_1/.git/config" should contain:
      """
      merge = refs/heads/master
      """

  Scenario: No config options given, default to '--list'
    When I run "repo config user.name find_me_here"
    Then the exit status should be 0
    And the file "test_path_1/.git/config" should contain:
      """
      name = find_me_here
      """
    When I run "repo config"
    Then the exit status should be 0
    And the output should contain:
      """
      user.name=find_me_here
      """

  Scenario: Bad config key command, missing section (failure [2])
    When I run "repo config missing_section some_value"
    Then the exit status should be 2
    And the output should contain:
      """
      error: key does not contain a section: missing_section
      """
    And the file "test_path_1/.git/config" should not contain:
      """
      missing_section
      """

  Scenario: Using the git '--unknown-switch' option (failure)
    When I run "repo config --unknown-switch"
    Then the exit status should not be 0
    And the output should contain:
      """
      invalid option: --unknown-switch
      """

  Scenario: Using the git '--global' option (failure)
    When I run "repo config user.name my_name --global"
    Then the exit status should not be 0
    And the output should contain:
      """
      invalid option: --global
      """

  Scenario: Using the git '--system' option (failure)
    When I run "repo config user.name my_name --system"
    Then the exit status should not be 0
    And the output should contain:
      """
      invalid option: --system
      """

  Scenario: Invalid repo
    Given I delete the folder "test_path_2/.git"
    When I run "repo config user.name my_name"
    Then the exit status should be 3
    And the output should contain:
      """
      test2: test_path_2 [unable to read repo]
      """

  Scenario: Missing repo folder
    Given I delete the folder "test_path_2"
    When I run "repo config user.name my_name"
    Then the exit status should be 3
    And the output should contain:
      """
      test2: test_path_2 [unable to read repo]
      """


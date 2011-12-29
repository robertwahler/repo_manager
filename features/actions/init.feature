@announce
Feature: Initializing a repo

  The application should initialize a repository from the command line

  Example usage:

    repo init
    repo init test1 test2

  These are the same:

    repo init --filter=t.*
    repo init --repos=t.*
    repo init t.*

  Background: A valid config file
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """

  Scenario: Default options
    Given a directory named "test_path_1"
    And a directory named "test_path_2"
    When I run `repo init`
    Then the exit status should be 0
    And the output should contain:
      """
      Initialized empty Git repository
      """
    And the following files should exist:
      | test_path_1/.git/config |
      | test_path_2/.git/config |

  Scenario: Default options with filtering using '--filter'
    Given a directory named "test_path_1"
    And a directory named "test_path_2"
    When I run `repo init --filter=t.st2`
    Then the exit status should be 0
    And the output should contain:
      """
      Initialized empty Git repository
      """
    And the following files should exist:
      | test_path_2/.git/config |
    And the following files should not exist:
      | test_path_1/.git/config |

  Scenario: Default options with filtering using ARGV
    Given a directory named "test_path_1"
    And a directory named "test_path_2"
    When I run `repo init t.st2 repo2 repo4`
    Then the exit status should be 0
    And the output should contain:
      """
      Initialized empty Git repository
      """
    And the following files should exist:
      | test_path_2/.git/config |
    And the following files should not exist:
      | test_path_1/.git/config |

  Scenario: 1 missing folder
    Given a directory named "test_path_1"
    When I run `repo init`
    Then the exit status should be 1
    And the output should contain:
      """
      test1: test_path_1
      Initialized empty Git repository
      """
    And the output should contain:
      """
      test2: test_path_2 [no such path]
      """
    And the following files should exist:
      | test_path_1/.git/config |
    And the following files should not exist:
      | test_path_2/.git/config |

  Scenario: All folders are missing
    When I run `repo init`
    Then the exit status should be 1
    And the output should contain:
      """
      test1: test_path_1 [no such path]
      test2: test_path_2 [no such path]
      """
    And the following files should not exist:
      | test_path_1/.git/config |
      | test_path_2/.git/config |

  Scenario: Already init'd
    Given a repo in folder "test_path_1" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a repo in folder "test_path_2" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    When I run `repo init`
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test_path_1
      Reinitialized existing Git repository
      """
    And the output should contain:
      """
      test2: test_path_2
      Reinitialized existing Git repository
      """

  Scenario: With remote specified in config file
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
          remotes:
            origin: ./remotes/test1.git
        test2:
          path: test_path_2
      """
    Given a directory named "test_path_1"
    And a directory named "test_path_2"
    When I run `repo init`
    Then the exit status should be 0
    And the output should contain:
      """
      Initialized empty Git repository
      """
    And the following files should exist:
      | test_path_1/.git/config |
      | test_path_2/.git/config |
    And the file "test_path_1/.git/config" should contain:
      """
      [remote "origin"]
      """
    And the file "test_path_1/.git/config" should contain:
      """
      url = ./remotes/test1.git
      """
    And the file "test_path_2/.git/config" should not contain:
      """
      [remote "origin"]
      """


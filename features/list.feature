@announce
Feature: Listing repo information contained in the configuration file

  The application should list repository information contained in the
  configuration file to stdout.  The actual repositories are not validated.
  The list command operates only on the config file.

  Example usage:

    repo list
    repo list --listing=SHORT
    repo list --listing=NAME
    repo list --listing=PATH

  Equivalent filtering:

    repo list --filter=test1
    repo list test1

  Scenario: Default action, no filter, --listing==SHORT
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --listing=SHORT`
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test_path_1
      test2: test_path_2
      """

  Scenario: Default action, no filter, --listing=NAME
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --listing=NAME`
    Then the exit status should be 0
    And the output should contain:
      """
      test1
      test2
      """

  Scenario: Default action, no filter, --listing=PATH
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test_path_1
        test2:
          path: test_path_2
      """
    When I run `repo list --listing=PATH`
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario: Missing path defaults to repo name
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
        test2:
          path: test2
      """
    When I run `repo list --listing=SHORT`
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test1
      test2: test2
      """

  Scenario: Missing repos is still valid
    Given a file named "repo.conf" with:
      """
      ---
      repos:
      """
    When I run `repo list --listing=SHORT`
    Then the exit status should be 0

  Scenario: Remotes short format with --filter repo
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test1
          remotes:
            origin: ./remotes/test1.git
        test2:
          path: test2
      """
    When I run `repo list --filter=test1 --listing=SHORT --no-verbose`
    Then the exit status should be 0
    And the output should contain exactly:
      """
      test1: test1

      """

  Scenario: Remotes short format with arg repo
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test1
          remotes:
            origin: ./remotes/test1.git
        test2:
          path: test2
      """
    When I run `repo list test1 --listing=SHORT --no-verbose`
    Then the output should contain exactly:
      """
      test1: test1

      """

  Scenario: Remotes long format
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test1
          remotes:
            origin: ./remotes/test1.git
        test2:
          path: test2
      """
    When I run `repo list`
    And the output should match:
      """
      test1:
      .*
      :remotes:.
        :origin: ./remotes/test1.git
      """

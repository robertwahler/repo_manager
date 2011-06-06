@announce
Feature: Listing repo information contained in the configuration file

  The application should list repository information contained in the
  configuration file to stdout.  The actual repositories are not validated.
  The list command operates only on the config file.

  Example:

    repo list


  Scenario: Default action, no filter, valid config, valid repos
    And a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test1
        test2:
          path: test2
      """
    When I run "repo list --short"
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test1
      test2: test2
      """

  Scenario: Missing path defaults to repo name
    And a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
        test2:
          path: test2
      """
    When I run "repo list --short"
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test1
      test2: test2
      """

  Scenario: Missing repos is still valid
    And a file named "repo.conf" with:
      """
      ---
      repos:
      """
    When I run "repo list --short"
    Then the exit status should be 0

  Scenario: Remotes short and long format
    And a file named "repo.conf" with:
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
    When I run "repo list test1 --short"
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test1
      """
    When I run "repo list"
    And the output should match:
      """
      test1:
      .*
      :remotes:.
        :origin: ./remotes/test1.git
      :path: test1
      """

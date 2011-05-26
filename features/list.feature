@announce
Feature: Listing repo information

  As an interactive user or automated script
  The application should list repository information
  to stdout


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
    When I run "repo list --no-verbose"
    Then the exit status should be 0
    And the output should contain:
      """
      test1: test1
      test2: test2
      """



@announce
Feature: Listing repo path information

  As an interactive user or automated script, the application should show the
  repository path defined in the config file to stdout so that it can be used
  for scripting.

  Example: chdir to the path of the repo named "my_repo_name"

    cd $(repo path my_repo_name)
    cd $(repo path my_repo_name)

  Example: chdir to the path of the repo named "my_repo_name"

    cd $(repo path --filter=my_repo_name)

  Example: chdir to the path of the repo named "my_repo_name" using a Bash
           function. This handles repo paths that contain spaces.

    .bashrc:

      function rcd(){ cd "$(repo path $@)"; }

    usage:

      rcd my_repo_name

  Example: repo versions of Bash's pushd and popd

    .bashrc:

      function rpushd(){ pushd "$(repo path $@)"; }
      alias rpopd="popd"

    usage:

      rcd my_repo_name


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

  Scenario: No filter, valid config, valid repos
    When I run "repo path"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario: Single Filter, allows for regex
    When I run "repo path --filter=test"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """
    When I run "repo path --filter=test$"
    Then the exit status should be 0
    And the output should not contain:
      """
      test_path_1
      """
    When I run "repo path --filter=t.st1"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      """
    And the output should not contain:
      """
      test_path_2
      """

  Scenario: Multiple filters delimited. Regex allowed on each filter separately
    When I run "repo path --filter=test1,t...2,t...3"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """
    When I run "repo path --repos=test1,t...2,t...3"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """
    When I run "repo path test1 t...2 t...3"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """


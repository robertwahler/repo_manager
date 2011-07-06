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

    vim ~/.bashrc

        function rcd(){ cd "$(repo --match=ONE --no-color path $@)"; }

    usage:

        rcd my_repo_n

  Example: repo versions of Bash's pushd and popd

    vim ~/.bashrc

        function rpushd(){ pushd "$(repo path --match=ONE --no-color $@)"; }
        alias rpopd="popd"

    usage:

        rpushd my


  Example: enable bash repo name completion for the repo, rcd, and rpushd commands

    vim ~/.bashrc

        function _repo_names()
        {
          local cur opts
          COMPREPLY=()
          cur="${COMP_WORDS[COMP_CWORD]}"
          opts=`repo list --listing=name --no-color`

          COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
          return 0
        }
        complete -F _repo_names rcd rpushd repo


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

  Scenario: Single Filter, allows for regex, liberal filter
    When I run "repo path --filter=test --no-verbose"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario: Single Filter, allows for regex, filter restricting at end of word
    When I run "repo path --filter=test$ --no-verbose"
    Then the exit status should be 0
    And the output should not contain:
      """
      test_path_1
      """

  Scenario: Single Filter, allows for regex, filter with character placeholder
    When I run "repo path --filter=t.st1 --no-verbose"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      """
    And the output should not contain:
      """
      test_path_2
      """

  Scenario: Single Filter using --match mode=ALL
    When I run "repo path --filter=test --match ALL"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario: Single Filter using --match mode=FIRST
    When I run "repo path --filter=test --match=FIRST --no-verbose"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      """
    And the output should not contain:
      """
      test_path_2
      """

  Scenario: Single Filter using --match mode=ONE
    When I run "repo path --filter=test --match=ONE"
    Then the exit status should be 1

  Scenario: Multiple filters delimited. Regex allowed on each filter
    separately, --filter switch
    When I run "repo path --filter=test1,t...2,t...3"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario: Multiple filters delimited. Regex allowed on each filter
    separately, --repos switch
    When I run "repo path --repos=test1,t...2,t...3"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """

  Scenario: Multiple filters delimited. Regex allowed on each filter
    separately, args instead of switch
    When I run "repo path test1 t...2 t...3"
    Then the exit status should be 0
    And the output should contain:
      """
      test_path_1
      test_path_2
      """


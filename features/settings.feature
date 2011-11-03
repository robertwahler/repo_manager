@announce
Feature: Configuration via YAML

  The application should process configuration options via YAML. These options
  should override hard coded defaults but not command line options.

  Master configuration files are read from multiple locations in order of
  priority.  Once a master configuration file is found, all other config files
  are ignored.  Priority: ["./repo.conf", "./.repo.conf", "./config/repo.conf",
  "~/.repo.conf"]

  All command line options can be read from the configuration file from the
  "options:" block. The "options" block is optional.  The "repos" block
  describes the repo names and attributes.  The "repos" block is required.
  Commands that operate on repos will fail if the repos block is invalid or
  missing.

  Config file priority:

      repo.conf
      .repo.conf
      config/repo.conf
      ~/.repo.conf

  The "repos" block can be specified in the master configuration file and/or in
  separate YAML files by specifying a filespec pattern for the option key
  "repo_configuration_glob:".  If repo_configuration_glob is specified, the
  repos: hash from the master configuration file is merged with each file found
  by globbing the repo_configuration_glob.  The repository "path" can be
  absolute or relative to the master configuration file.

  Example master configuration file:

      ---
      options:
        color: true
      repo_configuration_glob: config/*.yml
      repos:
        test1:
          path: workspace/test_path_1
          remotes:
            origin: ../remotes/test1.git
        test2:
          path: /home/robert/repos/test_path_2

  Example stand alone repo configuration file:

      ---
      repos:
        test1:
          path: workspace/test_path_1
          remotes:
            origin: ../remotes/test1.git
        test2:
          path: /home/robert/repos/test_path_2


  Scenario: Specified config file exists
    Given an empty file named "config.conf"
    When I run `repo path --verbose --config=config.conf`
    Then the output should contain:
      """
      config file: config.conf
      """

  Scenario: Specified config file option but not given on command line
    When I run `repo path --verbose --config`
    Then the exit status should be 1
    And the output should contain:
      """
      missing argument: --config
      """

  Scenario: Specified config file not found
    When I run `repo path --verbose --config=config.conf`
    Then the exit status should be 1
    And the output should contain:
      """
      config file not found
      """

 Scenario: Reading options from specified config file, ignoring the
    default config file
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        color: true
      """
    And a file named "repo_no_color.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        color: false
      """
    When I run `repo path --verbose --config=repo_no_color.conf`
    Then the output should contain:
      """
      :color=>false
      """
    And the output should not contain:
      """
      :color=>true
      """

  Scenario: Reading options from specified config file, ignoring the
    default config file with override on command line
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        color: true
      """
    And a file named "repo_no_color.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        color: false
      """
    When I run `repo path --verbose --config=repo_no_color.conf --color`
    Then the output should contain:
      """
      :color=>"AUTO"
      """
    And the output should not contain:
      """
      :color=>false
      """
    And the output should not contain:
      """
      :color=>true
      """

 Scenario: Reading options from config file with negative override on command line
    And a file named "repo_with_color.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        color: true
      """
    When I run `repo path --verbose --config=repo_with_color.conf --no-color`
    Then the output should contain:
      """
      :color=>false
      """

 Scenario: Negative override on command line with alternative spelling '--no-coloring'
    And a file named "with_color.conf" with:
      """
      ---
      options:
        color: true
      """
    When I run `repo path --verbose --config with_color.conf --no-coloring`
    Then the output should contain:
      """
      :color=>false
      """

  Scenario: Reading text options from config file
    Given a file named "repo_with_always_color.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        color: ALWAYS
      """
    When I run `repo path --verbose --config=repo_with_always_color.conf`
    Then the output should contain:
      """
      :color=>"ALWAYS"
      """

  Scenario: Reading default valid config files ordered by priority
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        repo1:
          path: repo1
      """
    And a file named ".repo.conf" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    And a file named "config/repo.conf" with:
      """
      ---
      repos:
        repo3:
          path: repo3
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo1: repo1
      """
    And the output should not contain:
      """
      repo2: repo2
      """
    And the output should not contain:
      """
      repo3: repo3
      """

  Scenario: Reading default config file '.repo.conf'
    Given a file named ".repo.conf" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    And a file named "config/repo.conf" with:
      """
      ---
      repos:
        repo3:
          path: repo3
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo2: repo2
      """
    And the output should not contain:
      """
      repo3: repo3
      """

  Scenario: Reading default config file 'config/repo.conf
    Given a file named "config/repo.conf" with:
      """
      ---
      repos:
        repo3:
          path: repo3
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo3: repo3
      """

  Scenario: Config file is a pattern, read from multiple files
    Given a file named "config/repo1.yml" with:
      """
      ---
      repos:
        repo1:
          path: repo1
      """
    And a file named "config/repo2.yml" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    When I run `repo list --listing=SHORT --config=config/*.yml`
    Then the output should contain:
      """
      repo1: repo1
      repo2: repo2
      """

  Scenario: Config file on command line is a pattern, but doesn't match any files
    When I run `repo path --config=config/*.invalid_pattern`
    Then the exit status should be 1
    And the output should contain:
      """
      config file not found
      """

  Scenario: Config file pattern doesn't match any files
    Given a file named "repo.conf" with:
      """
      ---
      repo_configuration_glob: config/*.invalid_pattern
      repos:
        repo0:
          path: repo0
      """
    When I run `repo path`
    Then the exit status should be 0
    And the output should contain:
      """
      config file pattern did not match any files
      """

  Scenario: Config file contains a config file pattern, read from mutiple files
    Given a file named "repo.conf" with:
      """
      ---
      repo_configuration_glob: config/*.yml
      repos:
        repo0:
          path: repo0
      """
    And a file named "config/repo1.yml" with:
      """
      ---
      repos:
        repo1:
          path: repo1
      """
    And a file named "config/repo2.yml" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo0: repo0
      repo1: repo1
      repo2: repo2
      """

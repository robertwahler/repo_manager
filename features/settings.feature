@announce
Feature: Configuration via YAML

  The application should process configuration options via YAML. These options
  should override hard coded defaults but not command line options.

  Config files are read from multiple locations in order of priority.  Once a
  config file is found, all other config files are ignored.


  Config file priority:

      ./repo.conf
      ./.repo.conf
      ./config/repo.conf
      ~/.repo.conf
      ~/repoman/repo.conf
      ~/.repoman/repo.conf

  All command line options can be read from the config file from the "options:"
  block. The "options" block is optional.

  NOTE: All file system testing is done via the Aruba gem.  The home folder
  config file is stubbed to prevent testing contamination in case it exists.


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

 Scenario: Ignoring the config file with the "--no-config" option
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color: true
      """
    When I run `repo action --verbose`
    Then its output should contain:
      """
      :color=>true
      """
    When I run `repo list --verbose --no-config`
    Then its output should contain:
      """
      :color=>"AUTO"
      """
    And its output should not contain:
      """
      :color=>true
      """

 Scenario: Reading options from specified config file, ignoring the
    default config file
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color: true
      """
    And a file named "repo_no_color.conf" with:
      """
      ---
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
     options:
        color: true
      """
    And a file named "repo_no_color.conf" with:
      """
      ---
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
      options:
        color: ALWAYS
      """
    When I run `repo path --verbose --config=repo_with_always_color.conf`
    Then the output should contain:
      """
      :color=>"ALWAYS"
      """

  Scenario: Processing ERB
    Given a file named "erb.conf" with:
      """
      ---
      options:
        color: <%= "ALWAYS" %>
      """
    When I run `repo action --verbose --config erb.conf`
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
    When I run `repo list --list=SHORT --verbose`
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
    When I run `repo list --list=SHORT`
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
    When I run `repo list --list=SHORT`
    Then the output should contain:
      """
      repo3: repo3
      """

@announce
Feature: Configuration via yaml file

  In order to configure options, as an interactive user or automated script,
  the program should process configuration options via yaml. These options
  should override hard coded defaults but not command line options.

  Config files are read from multiple locations in order of priority.  Once a
  config file is found, all other config files are ignored.

  All command line options can be read from the config file from the "options:"
  block. The "options" block is optional.

  NOTE: All file system testing is done via the Aruba gem.  The home folder
  config file is stubbed to prevent testing contamination in case it exists.


  Scenario: Specified config file exists
    Given an empty file named "config.conf"
    When I run `basic_app action --verbose --config config.conf`
    Then the output should contain:
      """
      config file: config.conf
      """

  Scenario: Specified config file option but not given on command line
    When I run `basic_app action --verbose --config`
    Then the exit status should be 1
    And the output should contain:
      """
      missing argument: --config
      """

  Scenario: Specified config file not found
    When I run `basic_app path --verbose --config config.conf`
    Then the exit status should be 1
    And the output should contain:
      """
      config file not found
      """

 Scenario: Reading options from specified config file, ignoring the
    default config file
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color: true
      """
    And a file named "no_color.conf" with:
      """
      ---
      options:
        color: false
      """
    When I run `basic_app action --verbose --config no_color.conf`
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
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color: true
      """
    And a file named "no_color.conf" with:
      """
      ---
      options:
        color: false
      """
    When I run `basic_app action --verbose --config no_color.conf --color`
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
    And a file named "with_color.conf" with:
      """
      ---
      options:
        color: true
      """
    When I run `basic_app action --verbose --config with_color.conf --no-color`
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
    When I run `basic_app action --verbose --config with_color.conf --no-coloring`
    Then the output should contain:
      """
      :color=>false
      """

  Scenario: Reading text options from config file
    Given a file named "with_always_color.conf" with:
      """
      ---
      options:
        color: ALWAYS
      """
    When I run `basic_app action --verbose --config with_always_color.conf`
    Then the output should contain:
      """
      :color=>"ALWAYS"
      """


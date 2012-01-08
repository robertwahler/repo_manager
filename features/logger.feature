@announce
Feature: Logging to console and log files

  The application outputs warnings and error messages on the console by
  default.  These same messages can be optionally logged to file.

  Logging configuration is handled in the YAML config file.  There are no
  command line modifiers.

  Configuration Notes:

  Log levels can be one of: debug, info, warn, error, or fatal

  All logging configuration is under the key "logging".  Configuration
  specified will overwrite the hard-coded defaults.

  See the orginal test fixture here:
  https://github.com/TwP/logging/blob/master/data/logging.yaml

  Scenario: Debug output to console via the "--verbose" switch
    Given a file named "basic_app.conf" with:
      """
      ---
      """
    When I run `basic_app help --verbose`
    Then the output should contain:
      """
      DEBUG
      """

  Scenario: No debug output to console without the "--verbose" switch
    Given a file named "basic_app.conf" with:
      """
      ---
      """
    When I run `basic_app help`
    Then the output should not contain:
      """
      DEBUG
      """

  Scenario: No debug output to console using a config file that only specifies a
    logger type of File
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color: true
      logging:
        loggers:
          - name          : root
            level         : debug
            appenders:
              - logfile
        appenders:
          - type          : File
            name          : logfile
            level         : debug
            truncate      : true
            filename      : 'temp.log'
            layout:
              type        : Pattern
              pattern     : '[%d] %l %c : %m\n'
      """
    When I run `basic_app help --verbose`
    Then the output should not contain:
      """
      DEBUG
      """
    And the file "temp.log" should contain:
      """
      DEBUG
      """


  Scenario: Override default STDOUT appender level with a config file
    Given a file named "basic_app.conf" with:
      """
      ---
      logging:
        loggers:
          - name          : root
            level         : debug
            appenders:
              - logfile
              - stdout
        appenders:
          - type          : Stdout
            name          : stdout
            level         : debug
            layout:
              type        : Pattern
              pattern     : '[%d] %l %c : %m\n'
              color_scheme: default
          - type          : File
            name          : logfile
            level         : debug
            truncate      : true
            filename      : 'temp.log'
            layout:
              type        : Pattern
              pattern     : '[%d] %l %c : %m\n'
      """
    When I run `basic_app help --verbose`
    Then the output should contain:
      """
      DEBUG
      """
    And the file "temp.log" should contain:
      """
      DEBUG
      """

  @wip
  Scenario: Logging to file with the truncate option

@announce
Feature: Asset configuration

  The application should process and manage asset configuration via YAML.

  Example global/asset_id.yml:

      ---
      path:     workspace/test_path_1
      binary:   bin/test.exe
      repos:
        save1:
          path: some/other/path
        config1:
          path: some/new/path

  Example config/data/asset_id.yml:

      ---
      parent    : ../global/folder
      acquired  : 01/01/2011
      launched  : 01/01/2011

  A list of assets can be found by globbing *.yml in the data folder.

  For each asset in the data folder, initialize an array of assets by passing
  in the user asset config filename and asset global config filename.


 Background: A general app settings file
    Given a file named "cond.conf" with:
      """
      ---
      options:
        color  : true
      folders:
        global : global
        user   : data
      """


  Scenario: No parent
    Given a file named "data/assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `cond list --verbose`
    Then the output should contain:
      """
      :path: user_path
      """

  # TODO: need step to build configs using table syntax
  Scenario: Parent configuration fills in missing items
    Given the folder "global/assets" with the following asset configurations:
      | name         | path          |
      | asset1       | global_path   |
    And the folder "data/assets" with the following asset configurations:
      | name         | parent        | binary          |
      | asset1       | ../../global  | path_to/bin.exe |
    When I run `cond list --verbose`
    Then the output should contain:
      """
      :path: global_path
      """

  Scenario: User configuration file overrides global configuration file
    Given the folder "global/assets" with the following asset configurations:
      | name         | path          |
      | asset1       | global_path   |
    And the folder "data/assets" with the following asset configurations:
      | name         | parent        | path      |
      | asset1       | ../../global  | user_path |
    When I run `cond list --verbose`
    Then the output should contain:
      """
      :path: user_path
      """


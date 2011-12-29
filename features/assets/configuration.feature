@announce
Feature: Asset configuration

  The application should process and manage asset configuration via YAML.

  A list of assets can be found by globbing '*/' in the data folder to return a
  list of folder names.

  For each asset in the data folder, initialize an array of assets by passing
  in the user asset config filename and a hash of options

  Example general settings config.conf

      ---
      options:
        color  : true
      folders:
        global : global
        user   : data

  Example global/assets/asset1/asset.conf:

      ---
      path:     workspace/test_path_1
      repos:
        save1:
          path: some/other/path
        config1:
          path: some/new/path

  Example with parent: config/data/assets/asset1/asset.conf:

      ---
      parent    : ../../global/assets/asset1
      acquired  : 01/01/2011
      launched  : 01/01/2011

  Example without parent: config/data/assets/asset1/asset.conf:

      ---
      acquired  : 01/01/2011
      launched  : 01/01/2011

 Background: A general app settings file
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color  : true
      folders:
        user   : data
      """


  Scenario: No parent
    Given a file named "data/app_assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `basic_app list --verbose --type=app_asset`
    Then the output should contain:
      """
      :path: user_path
      """

  Scenario: Parent configuration fills in missing items
    Given the folder "global/app_assets" with the following asset configurations:
      | name         | path          |
      | default      | set_by_parent |
    And the folder "data/app_assets" with the following asset configurations:
      | name         | an_attribute  | parent                           | binary          |
      | asset1       |               | ../../global/app_assets/default  | path_to/bin.exe |
    When I run `basic_app list --verbose --type=app_asset`
    Then the output should contain:
      """
      :path: set_by_parent
      """

  Scenario: User configuration file overrides global configuration file
    Given the folder "global/app_assets" with the following asset configurations:
      | name         | path          |
      | default      | set_by_parent |
    And the folder "data/app_assets" with the following asset configurations:
      | name         | path          | parent                           | binary          |
      | asset1       | set_by_user   | ../../global/app_assets/default  | path_to/bin.exe |
    When I run `basic_app list --verbose --type=app_asset`
    Then the output should contain:
      """
      :path: set_by_user
      """

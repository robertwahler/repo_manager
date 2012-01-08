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

  Scenario: Specify assets folder explicity
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color       : true
      folders:
        repos  : data/app_assets
      """
    And a file named "data/app_assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `repo list`
    Then the output should contain:
      """
      path: user_path
      """

  Scenario: Assets folder determined by convention, relative to config folder,
    by convention the folder name is the asset class
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color       : true
      """
    And a file named "repo_assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `repo list`
    Then the output should contain:
      """
      path: user_path
      """

  Scenario: Asset attribute read from asset configuration using the asset key ':repo'
    Given a file named "repo.conf" with:
      """
      ---
      # TODO: configuration file must exist, even when all attributes
      # are determined by convention due to bug in 'base_folder' determination
      """
    And a file named "repo_assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      repo:
        path: the_real_path
      """
    When I run `repo list`
    Then the output should contain:
      """
      path: the_real_path
      """
    Then the output should not contain:
      """
      path: user_path
      """

  Scenario: Assets attributes are specified directly in the config file,
    attributes key is by convention, the name of the asset class
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color       : true
      repos:
        asset1:
          path: user_path
      """
    When I run `repo list`
    Then the output should contain:
      """
      path: user_path
      """

  Scenario: Parent configuration fills in missing items
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color       : true
      folders:
        repos  : data/app_assets
      """
    And the folder "global/app_assets" with the following asset configurations:
      | name         | path          |
      | default      | set_by_parent |
    And the folder "data/app_assets" with the following asset configurations:
      | name         | an_attribute  | parent                           | binary          |
      | asset1       |               | ../../global/app_assets/default  | path_to/bin.exe |
    When I run `repo list`
    Then the output should contain:
      """
      path: set_by_parent
      """

  Scenario: User configuration file overrides global configuration file
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color       : true
      folders:
        repos  : data/app_assets
      """
    And the folder "global/app_assets" with the following asset configurations:
      | name         | path          |
      | default      | set_by_parent |
    And the folder "data/app_assets" with the following asset configurations:
      | name         | path          | parent                           | binary          |
      | asset1       | set_by_user   | ../../global/app_assets/default  | path_to/bin.exe |
    When I run `repo list`
    Then the output should contain:
      """
      path: set_by_user
      """
    And the output should not contain:
      """
      path: set_by_parent
      """

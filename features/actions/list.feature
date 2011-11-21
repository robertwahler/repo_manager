@announce
Feature: Listing assets

  Assets can be listed to the screen in html or plain text

  Example usage:

    basic_app list
    basic_app list --type=asset_type
    basic_app list --tags=adventure,favorites  --sort=ACQUIRED
    basic_app list --format=HTML >> tmp/aruba/index.html

 Background: A master configuration file
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color  : true
      folders:
        user   : data
      """

  Scenario: Invalid asset type
    When I run `basic_app list --type=invalid_asset_type`
    Then the exit status should be 1
    Then the output should contain:
      """
      unknown asset type
      """

  Scenario: List all
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --type=app_asset`
    Then the output should contain:
      """
      asset1:
      --- {}

      asset2:
      --- {}

      asset3:
      --- {}
      """

  Scenario: List just name
    Given the folder "data/app_assets" with the following asset configurations:
      | name         |
      | asset1       |
      | asset2       |
      | asset3       |
    When I run `basic_app list --list=NAME --type=app_asset`
    Then the output should contain:
      """
      asset1
      asset2
      asset3
      """




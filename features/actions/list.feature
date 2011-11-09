@announce
Feature: Listing assets

  Assets can be listed to the screen in html or plain text

  Example usage:

    basic_app list
    basic_app list --tags=adventure,favorites  --sort=ACQUIRED
    basic_app list --format=HTML >> tmp/aruba/index.html

 Background: A master configuration file
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color  : true
      folders:
        global : global
        user   : data
      """

  Scenario: List all
    Given the folder "data/assets" with the following asset configurations:
      | name         | path          |
      | asset1       | /c/user_path  |
      | asset2       | /d/user_path  |
      | asset3       | /d/user_path1 |
    When I run `basic_app list`
    Then the output should contain:
      """
      asset1:
      ---
      :path: /c/user_path

      asset2:
      ---
      :path: /d/user_path

      asset3:
      ---
      :path: /d/user_path1
      """

  Scenario: List just path
    Given the folder "data/assets" with the following asset configurations:
      | name         | path          |
      | asset1       | /c/user_path  |
      | asset2       | /d/user_path  |
      | asset3       | /d/user_path1 |
    When I run `basic_app list --verbose --list=PATH`
    Then the output should contain:
      """
      /c/user_path
      /d/user_path
      /d/user_path1
      """




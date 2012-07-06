@announce
Feature: Create user defined attributes

  The user can create an array of attribute names that will
  be converted into read/write accessors at instantiation. This
  allows using user defined attributes via Mustache tags in user
  defined tasks.

  Example defining user attributes

      ---
      user_attributes:
      - my_folder
      my_folder: folder name
      path: folder/{{my_folder}}/another_folder

  For simple variable replacement, there is no need to predefine the
  Mustache tags variables.

  Example ad hoc user attributes

      ---
      my_folder: folder name
      path: folder/{{my_folder}}/another_folder

  Background: Master config file and ERB template
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        app_assets  : app_assets
      """
    And a file named "test.erb" with:
      """
      <% require 'basic_app/actions/action_helper' -%>
      <% extend BasicApp::ActionHelper -%>

      <% for item in items do -%>
      <%= item.name %>:
      ---
      path: <%= relative_path(item.path) %>
      <% end -%>
      """

  Scenario: Using user attributes with pre-defined read/write accessors
    Given a file named "global/app_assets/default/asset.conf" with:
      """
      ---
      user_attributes:
      - my_folder
      """
    And a file named "app_assets/asset1/asset.conf" with:
      """
      ---
      parent: ../global/app_assets/default
      my_folder: folder name
      path: folder/{{my_folder}}/another_folder
      """
    When I run `basic_app list --type=app_asset --verbose`
    Then the exit status should be 0
    And its output should contain:
      """
      path: folder/{{my_folder}}/another_folder
      """
    When I run `basic_app list --template=test.erb --type=app_asset --verbose`
    Then the exit status should be 0
    And its output should not contain:
      """
      path: folder/{{my_folder}}/another_folder
      """
    And its output should contain:
      """
      path: ./folder/folder name/another_folder
      """

  Scenario: Using user attributes with ad hoc template variable expansion
    Given a file named "app_assets/asset1/asset.conf" with:
      """
      ---
      my_folder: folder name
      path: folder/{{my_folder}}/another_folder
      """
    When I run `basic_app list --type=app_asset --verbose`
    Then the exit status should be 0
    And its output should contain:
      """
      path: folder/{{my_folder}}/another_folder
      """
    When I run `basic_app list --template=test.erb --type=app_asset --verbose`
    Then the exit status should be 0
    And its output should not contain:
      """
      path: folder/{{my_folder}}/another_folder
      """
    And its output should contain:
      """
      path: ./folder/folder name/another_folder
      """

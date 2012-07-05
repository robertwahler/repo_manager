@announce
Feature: Create user defined attributes

  The user can create an array of attribute names that will
  be converted into read/write accessors at instantiation. This
  allows using user defined attributes via Mustache tags.

  Scenario: Using user attributes with pre-defined read/write accessors
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        app_assets  : app_assets
      """
    And a file named "global/app_assets/default/asset.conf" with:
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


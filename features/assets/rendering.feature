@announce
Feature: Asset template rendering

  Assets should render Mustache variables.  When listing to STDOUT without a
  template, the raw attribute will be shown.

 Background: Empty configuration file so that we don't read global config locations
   Given an empty file named "basic_app.conf"

  Scenario: Render templates to STDOUT
    Given a file named "test.erb" with:
      """
      <% require 'repoman/actions/action_helper' -%>
      <% extend Repoman::ActionHelper -%>

      <% for item in items do -%>
      <%= item.name %>:
      ---
      path: <%= relative_path(item.path) %>
      <% end -%>
      """
    And a file named "assets/asset1/asset.conf" with:
      """
      ---
      path: folder/{{name}}/another_folder
      """
    When I run `repo list --type=app_asset`
    Then the exit status should be 0
    And its output should contain:
      """
      path: folder/{{name}}/another_folder
      """
    When I run `repo list --template=test.erb --type=app_asset`
    Then the exit status should be 0
    And its output should not contain:
      """
      path: folder/{{name}}/another_folder
      """
    And its output should contain:
      """
      path: ./folder/asset1/another_folder
      """

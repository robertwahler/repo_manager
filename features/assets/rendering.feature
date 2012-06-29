@announce
Feature: Asset template rendering

  Assets should render Mustache variables.  When listing to STDOUT without a
  template, the raw attribute will be shown.

  Scenario: Specify assets folder explicity
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        app_assets  : app_assets
      """
    Given a file named "test.erb" with:
      """
      <% for item in items do -%>
      <%= item.name %>:
      ---
      path: <%= item.path %>
      <% end -%>
      """
    And a file named "app_assets/asset1/asset.conf" with:
      """
      ---
      path: folder/{{name}}/another_folder
      """
    When I run `repo list --verbose --type=app_asset`
    Then the exit status should be 0
    And its output should contain:
      """
      path: folder/{{name}}/another_folder
      """
    When I run `repo list --template=test.erb  --type=app_asset --verbose`
    Then the exit status should be 0
    And its output should not contain:
      """
      path: folder/{{name}}/another_folder
      """
    And the last output should match:
      """
      path: \/.*\/asset1\/another_folder
      """

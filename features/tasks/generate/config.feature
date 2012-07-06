@announce
Feature: Task to generate asset configurations

  Generate config files automatically by searching each top level folder
  contained in the given command line FOLDER.  If a '.git' folder exists,
  then that top level folder will be used to generate a new config file.

  Help:

      repo help generate:config

  Usage:

    repo generate:config FOLDER

  Options:
    -r, [--refresh]               # Refresh existing blank attributes
    -f, [--filter=one two three]  # List of regex folder name filters

  Runtime options:
    -s, [--skip]     # Skip files that already exist
    -q, [--quiet]    # Suppress status output
    -p, [--pretend]  # Run but do not make any changes
    -f, [--force]    # Overwrite files that already exist

  Examples

    cond generate:config c:/users/robert/documents/
    cond generate:config ~/workspace/delphi
    cond generate:config ~/workspace --filter guard-*,repoman-*

  General Notes:

    * task is not recursive and only looks for .git folder in direct children of the top level folder
    * task will skip existing asset names and existing asset paths unless using the '--refresh' switch
    * add '.condenser' file to application path to have Condenser always skip this application

  Example output (~/repoman/assets/asset.conf):

      ---
      path: some/path/my_repo_name


  Background: Test repositories and a valid config file
    Given a repo in folder "workspace/repo1_path" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a repo in folder "workspace/repo2_path" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a directory named "workspace/not_a_repo"
    And a directory named "assets"


  Scenario: Point at a top level folder that contains two repos and on non repo folder
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        assets : assets
      """
    When I run `repo generate:config workspace` interactively
    When I type "y"
    Then the exit status should be 0
    And the output should contain:
      """
      Found 2 assets
      """
    And the file "assets/repo1_path/asset.conf" should match:
      """
      path: .*/workspace/repo1_path
      """
    And the file "assets/repo2_path/asset.conf" should match:
      """
      path: .*/workspace/repo2_path
      """

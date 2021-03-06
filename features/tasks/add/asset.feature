@announce
Feature: Task to generate asset configurations

  Generate config files automatically by searching each top level folder
  contained in the given command line FOLDER.  If a '.git' folder exists,
  then that top level folder will be used to generate a new config file.

  Help:

      repo help add:asset

      repo help add:assets

  USAGE :

    repo add:asset WORKING_FOLDER

    repo add:assets TOP_LEVEL_FOLDER

  Options:
    -r, [--refresh]               # Refresh existing blank attributes
    -f, [--filter=one two three]  # List of regex folder name filters

  Runtime options:
    -s, [--skip]     # Skip files that already exist
    -q, [--quiet]    # Suppress status output
    -p, [--pretend]  # Run but do not make any changes
    -f, [--force]    # Overwrite files that already exist

  Examples

    cond add:assets c:/users/robert/documents/
    cond add:assets ~/workspace/delphi
    cond add:assets ~/workspace --filter guard-*,repo_manager-*

  General Notes:

    * task is not recursive and only looks for .git folder in direct children of the top level folder
    * task will skip existing asset names and existing asset paths unless using the '--refresh' switch
    * add '.condenser' file to application path to have Condenser always skip this application

  Example output (~/repo_manager/assets/asset.conf):

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


  Scenario: Point at a top level folder that contains two repos and on non repo folder
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        assets : assets
      """
    And a directory named "assets"
    When I run `repo add:assets workspace` interactively
    When I type "y"
    Then the exit status should be 0
    And the output should contain:
      """
      Found 2 asset(s)
      """
    And the file "assets/repo1_path/asset.conf" should match:
      """
      path: .*/workspace/repo1_path
      """
    And the file "assets/repo2_path/asset.conf" should match:
      """
      path: .*/workspace/repo2_path
      """

  Scenario: Point at a single working folder
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        assets : assets
      """
    And a directory named "assets"
    When I run `repo add:asset workspace/repo1_path` interactively
    When I type "y"
    Then the exit status should be 0
    And the output should contain:
      """
      Found 1 asset(s)
      """
    And the file "assets/repo1_path/asset.conf" should match:
      """
      path: .*/workspace/repo1_path
      """

  Scenario: Point at a single working folder relative to repo.conf
    Given a file named "repo_manager/repo.conf" with:
      """
      ---
      folders:
        assets : assets
      """
    And a directory named "repo_manager/assets"
    When I run `repo add:asset workspace/repo1_path` interactively
    When I type "y"
    Then the exit status should be 0
    And the output should contain:
      """
      Found 1 asset(s)
      """
    And the file "repo_manager/assets/repo1_path/asset.conf" should match:
      """
      path: .*/workspace/repo1_path
      """

  Scenario: Point at an invalid working folder
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        assets : assets
      """
    And a directory named "assets"
    When I run `repo add:asset workspace/not_a_repo` interactively
    Then the exit status should be 1
    And the output should not contain:
      """
      Found 1 asset(s)
      """
    And the output should contain:
      """
      unable to find '.git' folder
      """

  Scenario: Point at a single working folder and give it a non-default name
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        assets : assets
      """
    And a directory named "assets"
    When I run `repo add:asset workspace/repo1_path --name=repo1 --verbose` interactively
    When I type "y"
    Then the exit status should be 0
    And the output should contain:
      """
      Found 1 asset(s)
      """
    And the file "assets/repo1/asset.conf" should match:
      """
      path: .*/workspace/repo1_path
      """

  Scenario: Attempting to add an asset that exists under a different name
    Given a file named "repo.conf" with:
      """
      ---
      folders:
        assets : assets
      """
    And a directory named "assets"
    And the folder "assets" with the following asset configurations:
      | name       | path                  |
      | repo1_path | workspace/repo1_path  |
    When I run `repo add:asset workspace/repo1_path --name repo1` interactively
    When I type "y"
    Then the exit status should be 1
    And its output should contain:
      """
      asset already exists under a different name
      """

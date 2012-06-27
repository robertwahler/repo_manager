@announce
Feature: Thor generate tasks

  As a repoman user, I want to generate config files using automatically so that I don't
  have to do it by hand.

  This is a task to generate a YAML config file for a single repo.  Repoman
  config files may contain multiple repositories.  This generator will not
  handle that situation.  Instead, 'repo generate:config' will generate a
  config file for just one repository.

  Example command:

      repo generate:config NAME
      repo generate:config NAME --path=PATH
      repo generate:config NAME --path=PATH --remote=git@somewhere.com:repo_name.git

  Example output (config/repos/my_repo_name/asset.conf):

      ---
      path: some/path/my_repo_name
      remotes:
        origin: //my_smb/server/repos/my_repo_name.git

  Defaults

  * 'path' will be taken as the CWD unless specified
  * 'name' has no default and must be specified
  * 'FILE' will be constructed based on 'name' and the path taken from the
    repo.conf 'folders' option.
  * 'remote' will be constructed based on configuration[:defaults][:remote_dirname] and 'name'

  Background: Test repositories and a valid config file
    Given a repo in folder "repo1_path" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a repo in folder "repo2_path" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |


  Scenario: Specify path on the command line
    Given a file named "repo.conf" with:
      """
      ---
      defaults:
        remote_dirname: ../remotes
      folders:
        repos  : config/repos
      """
    When I run `repo generate:config repo1 --path="repo1_path"`
    Then the output should contain:
      """
      Creating repoman configuration file
      """
    And the file "config/repos/repo1/asset.conf" should contain:
      """
      ---
      path: repo1_path
      remotes:
        origin: ../remotes/repo1.git
      """

@announce
Feature: Thor generate tasks

  As a repoman user, I want to generate config files using Thor so that I don't
  have to do it by hand.

  This is a Thor task to generate a YAML config file for a single repo.
  Repoman config files may contain multiple repositories.  This generator will
  not handle that situation.  Instead, 'thor repoman:generate:config' will
  generate a config file for just one repository.  Using the repoman option
  '--config config/*.yml' pattern, multiple repostories can be configured from
  separate config files.

  Example command:

      thor repoman:generate:config NAME
      thor repoman:generate:config NAME --path=PATH
      thor repoman:generate:config NAME --path=PATH --remote=git@somewhere.com:repo_name.git

  Example output (config/my_repo_name.yml):

      ---
      repos:
        my_repo_name:
          path: some/path/my_repo_name
          remotes:
            origin: //my_smb/server/repos/my_repo_name.git


  Procedure:

  1) read the repo.config file via

        options = Repoman::Settings.new(FileUtils.pwd).options

  2) use defaults array from repo.conf to generate config files based on
  conventions.  Conventions can be overriden on the Thor command line.

  3) print params to STDOUT and prompt the user to say "OK", use --force
  to avoid the interactive prompt

  Conventions:

  * 'path' will be taken as the cwd unless specified
  * 'name' has no convention and must be specified
  * 'FILE' will be constructed based on 'name' and the path taken from the
    repo.config 'config' option.  If no config value, use the working folder
    for the repo.config file itself.
  * 'remote' will be constructed based on configuration[:defaults][:remote_dirname] and 'name'

  Background: Test repositories and a valid config file
    Given a repo in folder "repo1_path" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |
    And a repo in folder "repo2_path" with the following:
      | filename         | status | content  |
      | .gitignore       | C      |          |


  Scenario: Repo config file not found
    When I run `thor repoman:generate:config repo1`
    Then the output should contain:
      """
      unable to find repo config file
      """

  Scenario: Specify path on the command line
    Given a file named "repo.conf" with:
      """
      ---
      repo_configuration_glob: repos/*.yml
      defaults:
        remote_dirname: ../remotes
      """
    When I run `thor repoman:generate:config repo1 --path="repo1_path"`
    Then the output should contain:
      """
      Creating repoman configuration file
      """
    And the file "repos/repo1.yml" should contain:
      """
      ---
      repos:
        repo1:
          path: repo1_path
          remotes:
            origin: ../remotes/repo1.git
      """

@announce
Feature: Invoke external tasks, normally Thor tasks.

  Tasks can be defined by the app and placed in lib/tasks or tasks can be
  defined by the user and placed in the user tasks folder.

  Examples

      repo task test:init /to/some/folder

  Task action is not required

      repo test:init /to/some/folder

  Add user tasks by specifying folders.tasks in the master config file
  and add Thor tasks.  See background scenario.

  Background: A master configuration file
    Given a file named "repo.conf" with:
      """
      ---
      options:
        color       : true
      folders:
        assets           : repo_manager/assets
        tasks            : repo_manager/tasks
      """
    And an empty file named "output/.gitignore"
    And a file named "repo_manager/tasks/test.rb" with:
      """
      module RepoManager
        class Test < Thor
          namespace :test

          desc "init", "a test init task"
          def init(path)
            say path
            return 0
          end

        end
      end
      """
    And a file named "repo_manager/tasks/test.thor" with:
      """
      module RepoManager
        class TestB < Thor

          desc "hello", "a test hello task"
          def hello(message)
            say message
            return 0
          end

        end
      end
      """

  Scenario: Listings available tasks from gem and user task locations
    When I run `repo task -T --verbose`
    Then the exit status should be 0
    And the output should not contain:
      """
      thor generate:configs FOLDER
      """
    And the output should contain:
      """
      repo test:init
      """
    And the output should contain:
      """
      repo repo_manager:test_b:hello
      """

  Scenario: Listings available tasks without the 'task' action
    When I run `repo -T`
    Then the exit status should be 0
    And the output should contain:
      """
      repo test:init
      """

  Scenario: Show help for a given task
    When I run `repo task help test:init`
    Then the exit status should be 0
    Then the output should contain:
      """
      Usage:
        repo test:init

      a test init task
      """

  Scenario: Show help for a given task without the 'task' action
    When I run `repo help test:init`
    Then the exit status should be 0
    Then the output should contain:
      """
      Usage:
        repo test:init

      a test init task
      """

  Scenario: Successful task run without the 'repo_manager:' namespace
    When I run `repo task test:init my_path`
    Then the exit status should be 0
    Then the output should contain:
      """
      my_path
      """

  Scenario: Successful task run without the 'task' action
    When I run `repo test:init my_path`
    Then the exit status should be 0
    Then the output should contain:
      """
      my_path
      """

  Scenario: Successful task run with the 'repo_manager:' namespace
    When I run `repo task repo_manager:test_b:hello my_message`
    Then the exit status should be 0
    Then the output should contain:
      """
      my_message
      """

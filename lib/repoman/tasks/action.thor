# @see features/tasks/action.feature
module Repoman
  class Action < Thor
    include Repoman::ThorHelper

    class_option :force, :type => :boolean, :desc => "Force overwrite and answer 'yes' to any prompts"

    method_option :repos, :type => :string, :desc => "Restrict update to comma delimited list of repo names", :banner => "repo1,repo2"
    method_option :message, :type => :string, :desc => "Override 'automatic commit' message"
    method_option 'no-push', :type => :boolean, :default => false, :desc => "Force overwrite of existing config file"
    desc "update", "run repo add -A, repo commit, and repo push on all modified repos"
    def update

      initial_filter = options[:repos] ? "--repos=#{options[:repos]}" : ""
      output = `repo status --short --unmodified=HIDE --no-verbose --no-color #{initial_filter}`

      case $?.exitstatus
        when 0
          say 'no changed repos', :green
        else

          repos = []
          output = output.split("\n")
          while line = output.shift
            st,repo = line.split("\t")
            repos << repo
          end
          filter = repos.join(',')

          unless options[:force]
            say "Repositories '#{filter}' are modified."
            unless ask("Add, commit and push them? (y/n)") == 'y'
              say "aborting"
              exit 0
            end
          end
          say "updating #{filter}"

          say "adding..."
          `repo add -A --no-verbose --no-color --repos #{filter}`
          unless $?.exitstatus == 0
            say "add failed, exiting", :red
            exit $?.exitstatus
          end

          commit_message = options[:message] || "automatic commit @ #{Time.now}"
          say "committing..."
          `repo commit --message=#{shell_quote(commit_message)} --no-verbose --no-color --repos #{filter}`
          unless $?.exitstatus == 0
            say "commit failed, exiting", :red
            exit $?.exitstatus
          end

          unless options['no-push']
            say "pushing..."
            `repo push --no-verbose --no-color --repos #{filter}`
            unless $?.exitstatus == 0
              say "push failed, exiting", :red
              exit $?.exitstatus
            end
          end

          say "done", :green
        end

    end
  end
end

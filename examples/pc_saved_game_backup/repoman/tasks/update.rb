# @see features/tasks/action.feature
module Repoman
  class Action < Thor
    namespace :action
    include Thor::Actions
    include Repoman::ThorHelper

    class_option :force, :type => :boolean, :desc => "Force overwrite and answer 'yes' to any prompts"

    method_option :repos, :type => :string, :desc => "Restrict update to comma delimited list of repo names", :banner => "repo1,repo2"
    method_option :message, :type => :string, :desc => "Override 'automatic commit' message"
    method_option 'no-push', :type => :boolean, :default => false, :desc => "Force overwrite of existing config file"

    desc "update", "run repo add -A, repo commit, and repo push on all modified repos"
    def update

      initial_filter = options[:repos] ? "--repos=#{options[:repos]}" : ""
      output = run("repo status --short --unmodified=HIDE --no-verbose --no-color #{initial_filter}", :capture => true)

      case $?.exitstatus
        when 0
          say 'no changed repos', :green
        else

          unless output
            say "failed to successfully run 'repo status'", :red
            exit $?.exitstatus
          end

          repos = []
          output = output.split("\n")
          while line = output.shift
            st,repo = line.split("\t")
            repos << repo
          end
          filter = repos.join(',')

          unless options[:force]
            say "Repo(s) '#{filter}' have changed."
            unless ask("Add, commit and push them? (y/n)") == 'y'
              say "aborting"
              exit 0
            end
          end

          say "updating #{filter}"

          run "repo add -A --no-verbose --repos #{filter}"
          exit $?.exitstatus if ($?.exitstatus > 1)

          commit_message = options[:message] || "automatic commit @ #{Time.now}"
          run "repo commit --message=#{shell_quote(commit_message)} --no-verbose --repos #{filter}"
          exit $?.exitstatus if ($?.exitstatus > 1)

          unless options['no-push']
            run "repo push --no-verbose --repos #{filter}"
            exit $?.exitstatus if ($?.exitstatus > 1)
          end

          say "update finished", :green
        end

    end
  end
end

# @see features/tasks/atction.feature
module Repoman
  class Action < Thor

    method_option 'no-push', :type => :boolean, :default => false, :desc => "Force overwrite of existing config file"
    desc "update", "run repo add -A, repo commit, and repo push on all changed repos "
    def update

      # TODO: add --filter command
      output = `repo status --short --unmodified=HIDE --no-verbose --no-color`

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

          # TODO: optionally 'ask' user to continue
          filter = repos.join(',')
          say "updating #{filter}"

          say "adding..."
          `repo add -A --no-verbose --no-color --repos #{filter}`
          unless $?.exitstatus == 0
            say "add failed, exiting"
            exit 1
          end

          # TODO: add optional '--message' option
          say "committing..."
          `repo commit --message='automatic commit @ #{Time.now}' --no-verbose --no-color --repos #{filter}`
          unless $?.exitstatus == 0
            say "commit failed, exiting"
            exit 1
          end

          unless options['no-push']
            say "pushing..."
            `repo push --no-verbose --no-color --repos #{filter}`
            unless $?.exitstatus == 0
              say "push failed, exiting"
              exit 1
            end
          end

          say "done", :green
        end

    end
  end
end

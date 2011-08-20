module Repoman
  class Action < Thor

    desc "update", "run repo add -A, repo commit, and repo push on all changed repos "
    def update

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
          # TODO: use system command instead of backticks so that we echo output
          `repo add -A --no-verbose --no-color --repos #{filter}`
          unless $?.exitstatus == 0
            say "add command failed, exiting"
            exit 1
          end

          say "committing..."
          `repo commit --message='automatic commit' --no-verbose --no-color --repos #{filter}`
          unless $?.exitstatus == 0
            say "add command failed, exiting"
            exit 1
          end

          # TODO: optionally push to origin
          say "pushing..."

          say "done", :green
        end

    end
  end
end

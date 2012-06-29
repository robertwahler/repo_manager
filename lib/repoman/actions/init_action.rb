module Repoman

  # @group CLI actions
  #
  # Pass through for 'git init'
  #
  # Running git init in an existing repository is safe.
  #
  # @example Usage: repo init
  #
  #   repo init
  #   repo init repo1 repo1
  #   repo init --filter=repo1,repo1
  #   repo init --filter=repo.
  #
  # Run 'repo git init' instead to pass through all options to the native version
  #
  # @return [Number] pass through of 'git init' result code
  class InitAction < AppAction

    def process

      st = 0
      result = 0
      output = ""

      repos.each do |repo|

        begin
          st = repo.status.bitfield
        rescue InvalidRepositoryError => e
          st = 0 #Status::INVALID
        rescue NoSuchPathError => e
          st = Status::NOPATH
        end

        result |= st unless (st == 0)

        case st
          when (Status::NOPATH)
            output += repo.name.red
            output += ": #{repo.path}"
            output += " [no such path]\n"
          else
            output += repo.name.green
            output += ": #{repo.path}\n"
            git_output = ''
            begin
              git = Git::Lib.new(:working_directory => repo.fullpath, :repository => File.join(repo.fullpath, '.git'))
              git_output = git.native('init') + "\n"
              if repo.attributes.include?(:remotes)
                repo.attributes[:remotes].each do |key, value|
                  git_output += git.native('remote', ['add', key.to_s, value.to_s]) + "\n"
                end
              end
            rescue Git::CommandFailed => e
              result |= e.exitstatus
              git_output = e.error
            end
            output += git_output + "\n"
        end
      end

      write_to_output(output)

      # numeric return
      result
    end

    def help
      super :comment_starting_with => "Pass through for 'git init'", :located_in_file => __FILE__
    end

  end
end

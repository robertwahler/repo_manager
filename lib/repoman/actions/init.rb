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
  #
  class InitAction < AppAction

    def execute
      st = 0
      result = 0

      # optparse on args so that only allowed options pass to git
      OptionParser.new do |opts|
        opts.banner = help
        begin
          opts.parse(args)
        rescue OptionParser::InvalidOption => e
          puts "option error: #{e}"
          puts opts
          exit 1
        end
      end

      filters = args.dup
      filters += @options[:filter] if @options[:filter]

      repos(filters).each do |repo|

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
            print repo.name.red
            print ": #{repo.path}"
            puts " [no such path]"
          else
            print repo.name.green
            puts ": #{repo.path}"
            output = ''
            begin
              git = Git::Lib.new(:working_directory => repo.fullpath, :repository => File.join(repo.fullpath, '.git'))
              output = git.native('init')
              if repo.attributes.include?(:remotes)
                repo.attributes[:remotes].each do |key, value|
                  output += git.native('remote', ['add', key.to_s, value.to_s])
                end
              end
            rescue Git::CommandFailed => e
              result |= e.exitstatus
              output = e.error
            end
            puts output
        end
      end
      result
    end

    def help
      super :comment_starting_with => "Pass through for 'git init'", :located_in_file => __FILE__
    end

  end
end

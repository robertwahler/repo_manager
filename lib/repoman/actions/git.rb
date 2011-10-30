module Repoman

  # @group CLI actions
  #
  # Native 'git' command pass-through
  #
  # @example Usage: repo [options] git args [options]
  #
  #   repo ls-files
  #   repo git ls-files
  #
  #   repo add .
  #   repo add . --filter=test
  #   repo git add . --filter=test
  #
  # @return [Numeric] pass through of 'git' result code
  class GitAction < AppAction

    def execute

      OptionParser.new do |opts|
        opts.banner = help
        begin
          opts.parse(args)
        rescue OptionParser::InvalidOption => e
          # do nothing, we are just passing through all options
        end
      end

      raise "no git command given" if args.empty?

      # the first arg is optionally 'git'
      args.shift if args[0] == 'git'
      raise "no git command given" if args.empty?

      command = args.shift
      st = 0
      result = 0
      filters = options[:filter] || []
      repositories = repos(filters)

      # args should not match a repo name
      if ((!args.empty?) && (filters.empty?))
        repositories.each do |repo|
          raise "repo name '#{repo.name}' cannot be used as a filter for git native commands, use --r, --repos, or --filter switches instead" if args.include?(repo.name)
        end
      end

      repositories.each do |repo|
        begin
          st = repo.status.bitfield
        rescue InvalidRepositoryError => e
          st = 0 #Status::INVALID
        rescue NoSuchPathError => e
          st = Status::NOPATH
        end

        case st
          when (Status::NOPATH)
            print repo.name.red
            print ": #{repo.path}"
            puts " [no such path]"
          else
            output = ''
            begin
              git = Git::Lib.new(:working_directory => repo.fullpath, :repository => File.join(repo.fullpath, '.git'))
              output = git.native(command, args)
              result |= $?.exitstatus unless ($?.exitstatus == 0)
            rescue Git::CommandFailed => e
              result |= e.exitstatus
              output = e.error
            end
            if output != ''
              puts repo.name.green
              puts output
            end
        end
      end
      result
    end

    def help
      super :comment_starting_with => "Native 'git' command", :located_in_file => __FILE__
    end

  end
end

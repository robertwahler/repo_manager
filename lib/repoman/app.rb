require 'configatron'
require 'term/ansicolor'
require 'optparse'

class String
  include Term::ANSIColor
end

module Repoman

  AVAILABLE_ACTIONS = %w[help list path init status config git]

  # these commands don't need to have the 'git' arg precede them
  GIT_NATIVE_SUPPORT = %w[add branch checkout commit diff fetch
                          grep log merge mv pull push rm show tag
                          gc remote ls-files cat-file diff-files
                          diff-index]

  class App

    def initialize(working_dir, argv=[], options={})
      @working_dir = working_dir
      @options = options
      @argv = argv
      if @options[:verbose]
        puts "working_dir: #{@working_dir}".cyan
        puts "options: #{@options.inspect}".cyan
        puts "base_dir: #{@options[:base_dir]}".cyan if @options[:base_dir]
        puts "config file: #{@options[:config]}".cyan if @options[:config]
      end
      $stdout.sync = true
    end

    def execute
      begin

        if action_argument_required?
          action = @argv.shift
          args = @argv

          # push action back to args if this is a native pass-through command
          if GIT_NATIVE_SUPPORT.include?(action)
            args.unshift(action)
            action = 'git'
          end

          unless AVAILABLE_ACTIONS.include?(action)
            if action.nil?
              puts "repo action required"
            else
              puts "repo invalid action: #{action}"
            end
            puts "repo --help for more information"
            exit 1
          end
          puts "repo run action: #{action} #{args.join(' ')}".cyan if @options[:verbose]
          raise "action #{action} not implemented" unless respond_to?(action)
          result = send(action, args)
        else
          #
          # default action if action_argument_required? is false
          #
          result = 0
        end

        if result.is_a?(Numeric)
          exit(result)
        else
          # handle all other return types
          exit(result ? 0 : 1)
        end

      rescue SystemExit => e
        # This is the normal exit point, exit code from the send result
        # or exit from another point in the system
        puts "repo run system exit: #{e}, status code: #{e.status}".green if @options[:verbose]
        exit(e.status)
      rescue Exception => e
        STDERR.puts("repo command failed, error(s) follow")
        STDERR.puts("Use '--verbose' for backtrace.") unless @options[:verbose]
        STDERR.puts("#{e.message}".red)
        STDERR.puts(e.backtrace.join("\n")) if @options[:verbose]
        exit(1)
      end
    end

    def help(args)
      action = args.shift

      unless action
        puts 'no action specified'
        puts 'Usage: repo help action'
        exit(0)
      end

      action = action.downcase
      unless AVAILABLE_ACTIONS.include?(action)
        puts "invalid action: #{action}"
        exit(0)
      end

      case action
        when 'config'
          config(['--help'])
        when 'init'
          init(['--help'])
        when 'run'
          puts 'Run git with any git subcommands and options'
          puts 'Usage: repo [options] run args'
        else
          puts 'no help available for action'
      end
      exit(0)
    end

    # 'git' arbitrary command pass-through
    #
    # examples:
    #
    #   repo ls-files
    #   repo git ls-files
    #
    #   repo add .
    #   repo add . --filter=test
    #   repo git add . --filter=test
    #
    #
    # @return [Numeric] pass through of 'git init' result code
    def git(args)
      #Grit.debug = true
      raise "no git command given" if args.empty?

      # the first arg is optionally 'git'
      args.shift if args[0] == 'git'
      raise "no git command given" if args.empty?

      command = args.shift
      st = 0
      result = 0
      filters = @options[:filter] || []

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
            options = {:raise => true}
            output = ''
            begin
              Dir.chdir(repo.fullpath) do
                git = Grit::Git.new(File.join(repo.fullpath, '.git'))
                output = git.native(command, options, args)
              end
            rescue Grit::Git::CommandFailed => e
              result |= e.exitstatus
              output = e.err
            end
            puts output
        end
      end
      result
    end

    # 'git init' pass through
    #
    # Running git init in an existing repository is safe.
    #
    # examples:
    #
    #   repo init
    #   repo init --filter=test
    #
    # @return [Numeric] pass through of 'git init' result code
    def init(args)
      #Grit.debug = true
      st = 0
      result = 0

      # optparse on args so that only allowed options pass to git config
      OptionParser.new do |opts|
        opts.banner = "Usage: repo init\n" +
                      "       repo init --quiet\n" +
                      "n" +
                      "Run 'repo git init' to pass through all options to the native version t\n" +
                      "Allowed pass-through options:"
        opts.on("-q", "--quiet", "Only print error and warning messages, all other output will be suppressed")
        begin
          opts.parse(args)
        rescue OptionParser::InvalidOption => e
          puts "config error: #{e}"
          puts opts
          exit 1
        end
      end

      filters = @options[:filter] || []

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
            options = {:raise => true}
            output = ''
            begin
              git = Grit::Git.new(File.join(repo.path, '.git'))
              output = git.init(options, args)
              if repo.attributes.include?(:remotes)
                repo.attributes[:remotes].each do |key, value|
                  output += git.remote(options, ['add', key.to_s, value.to_s])
                end
              end
            rescue Grit::Git::CommandFailed => e
              result |= e.exitstatus
              output = e.err
            end
            puts output
        end
      end
      result
    end

    # 'git config' pass through
    #
    # examples:
    #
    #   repo config core.autocrlf false --filter=test
    #   repo config branch.master.remote origin
    #   repo config branch.master.merge refs/heads/master" --filter=test.*,somerepo1
    #
    # @return [Numeric] pass through of 'git config' result code
    def config(args)
      #Grit.debug = true
      st = 0
      result = 0

      # optparse on args so that only allowed options pass to git config
      OptionParser.new do |opts|
        opts.banner = "Usage: repo config section.name value\n" +
                      "       repo config --list\n" +
                      "n" +
                      "Run 'repo git config' to pass through all options to the native version t\n" +
                      "Allowed pass-through options:"
        opts.on("-l", "--list", "List all variables set in config file")
        begin
          opts.parse(args)
        rescue OptionParser::InvalidOption => e
          puts "config error: #{e}"
          puts opts
          exit 1
        end
      end

      args = ['--list'] if args.empty?
      filters = @options[:filter] || []

      repos(filters).each do |repo|

        begin
          st = repo.status.bitfield
        rescue InvalidRepositoryError, NoSuchPathError => e
          st = Status::INVALID | Status::NOPATH
        end

        result |= st unless (st == 0)

        case st
          when (Status::INVALID | Status::NOPATH)
            print repo.name.red
            print ": #{repo.path}"
            puts " [unable to read repo]"
          else
            print repo.name.green
            puts ": #{repo.path}"
            options = {:raise => true}
            begin
              output = repo.repo.git.config(options, args)
            rescue Grit::Git::CommandFailed => e
              result |= e.exitstatus
              output = e.err
            end
            puts output
        end
      end
      result
    end

    # Show repo working folder path from the config file
    #
    # @example: chdir to the path of the repo named "my_repo_name"
    #   cd $(repo path my_repo_name)
    # @example: chdir to the path of the repo named "my_repo_name"
    #   cd $(repo path --filter=my_repo_name)
    #
    # @return [String] path to repo
    def path(args)
      filters = args.dup
      filters += @options[:filter] if @options[:filter]

      repos(filters).each do |repo|
        puts repo.path
      end
    end

    # List repo info from the config file
    def list(args)
      filters = args.dup
      filters += @options[:filter] if @options[:filter]

      repos(filters).each do |repo|
        if @options[:short]
          print repo.name.green
          puts ": #{repo.path}"
        else
          attributes = repo.attributes.dup
          base_dir = attributes.delete(:base_dir)
          name = attributes.delete(:name)
          print name.green
          puts ":"
          puts attributes.to_yaml
          puts ""
        end
      end
    end

    # Output status of all repos to STDOUT
    #
    # @example:
    #
    #   repo status
    #
    # @return [Number] bitfield with combined repo status
    def status(args)
      filters = args.dup
      filters += @options[:filter] if @options[:filter]

      st = 0
      result = 0
      count_unmodified = 0
      need_lf = false

      repos(filters).each do |repo|

        # M ? A D I X
        begin
          st = repo.status.bitfield
        rescue InvalidRepositoryError => e
          st = Status::INVALID # I
        rescue NoSuchPathError => e
          st = Status::NOPATH # X
        end

        result |= st unless (st == 0)

        case st

          when Status::CLEAN
            count_unmodified += 1
            case @options[:unmodified]
              when "HIDE"
                # do nothing
              when "SHOW"
                puts "     #{repo.name}: #{repo.path}"
              when "DOTS"
                print ".".green
                need_lf = true
              else
                raise "invalid mode '#{@options[:unmodified]}' for '--unmodified' option"
              #
              # good point to run commands that need a clean repo. i.e. pull
              #
            end

          when Status::NOPATH
            puts "" if need_lf
            print "X    #{repo.name}: #{repo.path}"
            puts " [no such folder]".red
            need_lf = false

          when Status::INVALID
            puts "" if need_lf
            print "I    #{repo.name}: #{repo.path}"
            puts " [not a valid repo]".red
            need_lf = false

          else
            puts "" if need_lf

            # print MUAD status letters
            print (st & Status::CHANGED == Status::CHANGED) ? "M".red : " "
            print (st & Status::UNTRACKED == Status::UNTRACKED) ? "?".blue : " "
            print (st & Status::ADDED == Status::ADDED) ? "A".green : " "
            print (st & Status::DELETED == Status::DELETED) ? "D".yellow : " "

            puts " #{repo.name}: #{repo.path}"
            need_lf = false

            unless @options[:short]
              # modified (M.red)
              repo.status.changed.sort.each do |k, f|
                puts "       modified: #{f.path}".red
              end

              # untracked (?.blue)
              repo.status.untracked.sort.each do |k, f|
                puts "       untracked: #{f.path}".blue
              end

              # added (A.green)
              repo.status.added.sort.each do |k, f|
                puts "       added: #{f.path}".green
              end

              # deleted (D.yellow)
              repo.status.deleted.sort.each do |k, f|
                puts "       deleted: #{f.path}".yellow
              end
            end
        end
      end

      puts "" if need_lf

      # summary
      puts "no modified repositories, all working folders are clean" if (count_unmodified == repos.size)

      # numeric return
      result
    end

  private

    # true if application requires an action to be specified on the command line
    def action_argument_required?
      !AVAILABLE_ACTIONS.empty?
    end

    # @return [Array] of Repo
    def repos(filters=['.*'])
      raise "config file not found" unless @options[:config]
      filters = ['.*'] if filters.empty?
      repo_config = configatron.repos.to_hash
      base_dir = File.dirname(@options[:config])
      result = []
      configatron.repos.configatron_keys.sort.each do |name|
        attributes = {:name => name, :base_dir => base_dir}
        attributes = attributes.merge(repo_config[name.to_sym]) if repo_config[name.to_sym]
        path = attributes[:path]
        if filters.find {|filter| name.match(/#{filter}/)}
          result << Repo.new(path, attributes.dup)
        end
      end
      result
    end

  end

end

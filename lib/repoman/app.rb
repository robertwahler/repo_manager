require 'term/ansicolor'
require 'optparse'

class String
  include Term::ANSIColor

  # used for HERE docs, strips the leading whitespace based on the
  # whitespace in the first line
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

module Repoman

  AVAILABLE_ACTIONS = %w[help list path init status git]

  # these commands don't need to have the 'git' arg precede them
  GIT_NATIVE_SUPPORT = %w[add config branch checkout commit diff fetch
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
        STDERR.puts("#{e.message}".red)
        STDERR.puts("Use '--verbose' for backtrace.") unless @options[:verbose]
        STDERR.puts(e.backtrace.join("\n")) if @options[:verbose]
        exit(1)
      end
    end

    def help(args)
      action = args.shift

      unless action
        puts "no action specified"
        puts "Usage: repo help action | repo --help"
        puts ""
        puts "Where 'action' is one of: #{AVAILABLE_ACTIONS.join(' ')}"

        exit(0)
      end

      action = action.downcase
      unless AVAILABLE_ACTIONS.include?(action)
        puts "invalid action: #{action}"
        exit(0)
      end

      case action
        when 'help'
          puts "Provide help for an action"
          puts "Usage: repo help [action]"
        when 'git'
          puts "Run git with any git subcommands and options"
          puts "Usage: repo [options] git args [options]"
        else
          send(action, ['--help'])
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
              print repo.name.green
              puts ": #{repo.path}"
              puts output
            end
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
      st = 0
      result = 0

      # optparse on args so that only allowed options pass to git
      OptionParser.new do |opts|
        opts.banner = <<-USAGE.unindent
                        Usage: repo init
                               repo init repo1 repo1
                               repo init --filter=repo1,repo1
                               repo init --filter=repo.

                        Run 'repo git init' instead to pass through all options to the native version
                      USAGE
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

    # Show repo working folder path from the config file
    #
    # @example: chdir to the path of the repo named "my_repo_name" using Bash function
    #
    #     function rcd(){ cd "$(repo path $@)"; }
    #
    #     rcd my_repo_name
    #
    # @example: repo versions of Bash's pushd and popd
    #
    #     function rpushd(){ pushd "$(repo path $@)"; }
    #     alias rpopd="popd"
    #
    #     rcd my_repo_name
    #
    # @return [String] path to repo
    def path(args)

      OptionParser.new do |opts|
        opts.banner = <<-USAGE.unindent
                        Show repo working folder path from the config file

                        Usage: repo path

                        Example: Create an 'alias' named 'rcd' to chdir to the path of the repo
                                 named "my_repo_name" using a Bash function 'rcd()'

                            function rcd(){ cd "$(repo --match=ONE --no-color path $@)"; }

                            rcd my_repo_name

                        Example: repo versions of Bash's pushd and popd

                            function rpushd(){ pushd "$(repo path --match=ONE --no-color $@)"; }
                            alias rpopd="popd"

                            rcd my_repo_name
                      USAGE
        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          puts "option error: #{e}"
          puts opts
          exit 1
        end
      end

      filters = args.dup
      filters += @options[:filter] if @options[:filter]
      repos(filters).each do |repo|
        puts repo.path
      end
    end

    # List repo info from the config file
    def list(args)

      OptionParser.new do |opts|
        opts.banner = <<-USAGE.unindent
                        List repository information contained in the configuration file to STDOUT.
                        The actual repositories are not validated.  The list command operates only
                        on the config file.

                        Usage: repo list

                        Examples:

                          repo list
                          repo list --short

                        Equivalent filtering:

                          repo list --filter=test1
                          repo list test1

                        Options:
                      USAGE

        opts.on("--listing MODE", "Listing format.  ALL (default) SHORT, NAME, PATH") do |u|
          @options[:listing] = u || 'ALL'
          @options[:listing].upcase!
          unless ["ALL", "SHORT", "NAME", "PATH"].include?(@options[:listing])
            raise "invalid lising mode '#{@options[:listing]}' for '--listing' option"
          end
        end

        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          puts "option error: #{e}"
          puts opts
          exit 1
        end
      end

      listing_mode = @options[:listing] || 'ALL'
      filters = args.dup
      filters += @options[:filter] if @options[:filter]

      repos(filters).each do |repo|
        case listing_mode
          when 'SHORT'
            print repo.name.green
            puts ": #{repo.path}"
          when 'NAME'
            puts repo.name.green
          when 'PATH'
            puts repo.path
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

    # Output status of repos to STDOUT
    #
    # @example:
    #
    #   repo status
    #
    # @return [Number] bitfield with combined repo status
    def status(args)
      OptionParser.new do |opts|

        opts.banner = <<-USAGE.unindent
                        Show summary status of repos

                        Usage: repo status

                        Examples:

                          repo status
                          repo status --short
                          repo status repo1 --unmodified DOTS
                          repo status repo1 repo2 --unmodified DOTS

                        Equivalent filtering:

                          repo status --filter=test2 --unmodified DOTS
                          repo status test2 --unmodified DOTS"

                        Use git status directly:

                          repo git status

                        Options:
                      USAGE
        opts.on("-u", "--unmodified [MODE]", "Show unmodified repos.  MODE=SHOW (default), DOTS, or HIDE") do |u|
          @options[:unmodified] = u || "SHOW"
          @options[:unmodified].upcase!
        end
        opts.on("--short", "Summary status only, do not show individual file status") do |s|
          @options[:short] = s
        end

        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          puts "option error: #{e}"
          puts opts
          exit 1
        end
      end

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
            print (st & Status::UNTRACKED == Status::UNTRACKED) ? "?".blue.bold : " "
            print (st & Status::ADDED == Status::ADDED) ? "A".green : " "
            print (st & Status::DELETED == Status::DELETED) ? "D".yellow : " "

            puts " #{repo.name}: #{repo.path}"
            need_lf = false

            unless @options[:short]
              # modified (M.red)
              repo.status.changed.sort.each do |k, f|
                puts "       modified: #{f.path}".red
              end

              # untracked (?.blue.bold)
              repo.status.untracked.sort.each do |k, f|
                puts "       untracked: #{f.path}".blue.bold
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
      match_count = 0
      filters = ['.*'] if filters.empty?
      repo_config = @options[:repos]
      base_dir = File.dirname(@options[:config])
      result = []
      repo_config.keys.sort_by{ |sym| sym.to_s}.each do |key|
        name = key.to_s
        attributes = {:name => name, :base_dir => base_dir}
        attributes = attributes.merge(repo_config[key]) if repo_config[key]
        path = attributes[:path]
        if filters.find {|filter| name.match(/#{filter}/)}
          result << Repoman::Repo.new(path, attributes.dup)
          match_count += 1
          break if @options[:match] == 'FIRST'
          raise "match mode = ONE, multiple repos found" if (@options[:match] == 'ONE' && match_count > 1)
        end
      end
      result
    end

  end

end

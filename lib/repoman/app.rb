require 'configatron'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module Repoman

  AVAILABLE_ACTIONS = %w[list path status config]

  class App

    def initialize(working_dir, options={})
      @working_dir = working_dir
      @options = options
      if @options[:verbose]
        puts "working_dir: #{@working_dir}".cyan
        puts "options: #{@options.inspect}".cyan
        puts "base_dir: #{@options[:base_dir]}".cyan if @options[:base_dir]
        puts "config file: #{@options[:config]}".cyan if @options[:config]
      end
      $stdout.sync = true
    end

    def run
      begin

        if action_argument_required?
          action = ARGV.shift
          unless AVAILABLE_ACTIONS.include?(action)
            if action.nil?
              puts "repo action required"
            else
              puts "repo invalid action: #{action}"
            end
            puts "repo --help for more information"
            exit 1
          end
          args = ARGV
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

    # 'git config' pass through
    #
    # arg[0] contains the commandline to pass to 'git config', remaining
    # ARGV, if any, assumed to be filters.
    #
    # examples:
    #
    #   repo config "core.autocrlf false" test*
    #   repo config "branch.master.remote origin"
    #   repo config "branch.master.merge refs/heads/master" t* --dry-run
    #
    # @return [Numeric] pass through of 'git config' result code
    def config(args)
      #Grit.debug = true
      st = 0
      result = 0
      config_args = ARGV.shift || '--list'
      filters = ARGV

      # validate command line options
      raise "config option not allowed" if config_args.match(/--global|--system/)

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
              output = repo.repo.git.config(options, config_args.split(' '))
            rescue Grit::Git::CommandFailed => e
              result |= e.exitstatus
              output = e.err
            end
            puts output
        end
      end
      result
    end

    # Path only
    #
    # @example: chdir to the path the repo named "my_repo_name"
    #
    #   cd $(repo path my_repo_name)
    #
    # @return [String] path to repo
    def path(filters)
      repos(filters).each do |repo|
        puts repo.path
      end
    end

    # list repo info
    def list(filters)
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
    def status(filters)
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

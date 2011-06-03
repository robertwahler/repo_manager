require 'configatron'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module Repoman

  AVAILABLE_ACTIONS = %w[list path status]

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
          filters = ARGV
          puts "repo run action: #{action} #{filters.join(' ')}".cyan if @options[:verbose]
          raise "action #{action} not implemented" unless respond_to?(action)
          result = send(action, filters)
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
        STDERR.puts("repo command failed, error(s) follow. Use '--verbose' for backtrace.")
        STDERR.puts("#{e.message}".red)
        STDERR.puts(e.backtrace.join("\n")) if @options[:verbose]
        exit(1)
      end
    end

    #
    # app commands start
    #

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
        puts "#{repo.name}: #{repo.path}"
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
      need_lf = false

      repos(filters).each do |repo|

        # M U A D I X
        st = repo.status
        result |= st unless (st == 0)

        case st

          when Repo::CLEAN
            print ".".green
            need_lf = true
          when Repo::NOPATH
            STDERR.print "     #{repo.name}: #{repo.path}"
            STDERR.puts " [no such folder]".red
            need_lf = false
          when Repo::INVALID
            STDERR.print "     #{repo.name}: #{repo.path}"
            STDERR.puts " [not a valid repo]".red
            need_lf = false
          else
            puts "" if need_lf

            # print MUAD status letters
            print (st & Repo::CHANGED == Repo::CHANGED) ? "M".red : " "
            print (st & Repo::UNTRACKED == Repo::UNTRACKED) ? "U".blue : " "
            print (st & Repo::ADDED == Repo::ADDED) ? "A".green : " "
            print (st & Repo::DELETED == Repo::DELETED) ? "D".yellow : " "

            puts " #{repo.name}: #{repo.path}"
            need_lf = false

            unless @options[:short]
              # modified (M.red)
              repo.changed.sort.each do |k, f|
                puts "       modified: #{f.path}".red
              end

              # untracked (U.blue)
              repo.untracked.sort.each do |k, f|
                puts "       untracked: #{f.path}".blue
              end

              # added (A.green)
              repo.added.sort.each do |k, f|
                puts "       added: #{f.path}".green
              end

              # deleted (D.yellow)
              repo.deleted.sort.each do |k, f|
                puts "       deleted: #{f.path}".yellow
              end
            end
        end
      end

      puts "" if need_lf
      result
    end

    #
    # app commands end
    #

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

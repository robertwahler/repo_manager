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
      end
      configure(options)
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
        STDERR.puts("repo command failed, error(s) follow:")
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
        puts repo.inspect if @options[:verbose]
      end
    end

    # Status
    #
    # @example: chdir to the path the repo named "my_repo_name"
    #
    #   cd $(repo path my_repo_name)
    #
    # @return [String] path to repo
    def status(filters)
      repos(filters).each do |repo|
        #print "."
        #puts repo.status.inspect
        repo.status
      end
    end

    #
    # app commands end
    #

  private

    # true if application requires an action to be specified on the command line
    def action_argument_required?
      !AVAILABLE_ACTIONS.empty?
    end

    # read options for YAML config with ERB processing and initialize configatron
    def configure(options)
      config = @options[:config]
      # TODO: ["repo.conf", "config/repo.conf", "~/.repo.conf"].detect
      config = File.join(@working_dir, 'repo.conf') unless config
      if File.exists?(config)
        @base_dir = File.dirname(config)
        puts "setting base_dir: #{@base_dir}".cyan if @options[:verbose]
        # load configatron options from the config file
        puts "loading config file: #{config}".cyan if @options[:verbose]
        configatron.configure_from_yaml(config)
      else
        # user specified a config file?
        raise "config file not found" if @options[:config]
        # no error if user did not specify config file
        puts "#{config} not found".yellow if @options[:verbose]
      end

      #
      # set defaults, these will NOT override setting read from YAML
      #

    end

    # @return [Array] of Repo
    def repos(filters=['.*'])
      # TODO: raise ArgumentError unless filter.is_a(Array)
      filters = ['.*'] if filters.empty?
      repo_config = configatron.repos.to_hash
      result = []
      configatron.repos.configatron_keys.sort.each do |name|
        path = repo_config[name.to_sym][:path]
        if filters.find {|filter| name.match(/#{filter}/)}
          result << Repo.new(@base_dir, path, name, @options.dup)
        end
      end
      result
    end

  end

end

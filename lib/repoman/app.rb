require 'configatron'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module Repoman

  AVAILABLE_ACTIONS = %w[]

  class App

    def initialize(base_dir, options={})
      @base_dir = base_dir
      @options = options
      if @options[:verbose]
        puts "base_dir: #{@base_dir}".cyan
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
          puts "repo run action: #{action}".cyan if @options[:verbose]
          raise "action #{action} not implemented" unless respond_to?(action)
          result = send(action)
        else
          #
          # default action if action_argument_required? is false
          #
          result = 0
        end

        exit(result ? 0 : 1)

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
      config = File.join(@base_dir, 'repo.conf') unless config
      if File.exists?(config)
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

  end
end

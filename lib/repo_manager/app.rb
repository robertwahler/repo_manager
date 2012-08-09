require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module RepoManager

  AVAILABLE_ACTIONS = %w[help list task path status git]

  # Commands that don't need to have the 'git' arg precede them.  These are not
  # necessarily the same as the allowed 'commands' specified in the repo.conf
  # file.
  # NOTE: `git help --all` for a full list of git supported commands
  GIT_NATIVE_SUPPORT = %w[add config commit diff fetch log pull push show ls-files grep]

  class App

    # bin wrapper option parser object
    attr_accessor :option_parser

    def initialize(argv=[], configuration={})
      @configuration = configuration.deep_clone
      @options = @configuration[:options] || {}
      @argv = argv.dup
      $stdout.sync = true

      config_filename = @configuration[:configuration_filename]
      RepoManager::Logger::Manager.new(config_filename, :logging, @configuration)

      logger.debug "configuration: #{@configuration.inspect}"
      logger.debug "argv: #{@argv.inspect}"
      logger.debug "config file: #{@configuration[:configuration_filename]}" if @configuration[:configuration_filename]
    end

    def execute
      begin

        args = @argv
        if action_argument_required?
          action = @argv.shift

          # push action back to args if this is a native pass-through command
          if GIT_NATIVE_SUPPORT.include?(action)
            args.unshift(action)
            action = 'git'
          end

          # special case: actionless tasks
          action = 'task' if action.nil? && @options.include?(:tasks)

          # special case: `repo sweep:screenshots` is an acceptable task action
          if action && action.match(/[a-zA-Z]+:+/)
            args.unshift(action)
            action = 'task'
          end

          # special case: `repo help sweep:screenshots` is an acceptable task help action
          if action == 'help' && args.any?
            target = args[0]
            if target.match(/[a-zA-Z]+:+/)
              args.unshift(action)
              action = 'task'
            end
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
          logger.debug "execute action: #{action} #{args.join(' ')}"
          klass = Object.const_get('RepoManager').const_get("#{action.capitalize}Action")
          app_action = klass.new(args, @configuration)
          app_action.option_parser = self.option_parser
          result = app_action.execute
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
        # This is the normal exit point
        logger.debug "repo run system exit: #{e}, status code: #{e.status}"
        exit(e.status)
      rescue Exception => e
        logger.fatal("repo fatal exception: #{e.message}")
        STDERR.puts("repo failed: #{e.message}".red)
        STDERR.puts("Command failed, use '--verbose' for backtrace.") unless @options[:verbose]
        STDERR.puts(e.backtrace.join("\n")) if @options[:verbose]
        exit(1)
      end
    end

  private

    # true if application requires an action to be specified on the command line
    def action_argument_required?
      !AVAILABLE_ACTIONS.empty?
    end

  end
end

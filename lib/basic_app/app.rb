require 'term/ansicolor'
require 'logging'

include Logging.globally

class String
  include Term::ANSIColor
end

module BasicApp

  AVAILABLE_ACTIONS = %w[help]

  class App

    def initialize(argv=[], configuration={})
      @configuration = configuration
      @options = configuration[:options] || {}
      @argv = argv
      $stdout.sync = true

      # logging global default level
      Logging.logger.root.level = :warn
      Logging.logger.root.level = :debug if @options[:verbose]

      if @configuration[:logging]
        Logging::Config::YamlConfigurator.load(@options[:config], 'logging')
      else
        # setup a default root level STDOUT logger
        format = {:pattern => '%-5l %c: %m\n'}
        format = format.merge(:color_scheme => 'default') if @options[:color]
        Logging.appenders.stdout('stdout', :layout => Logging.layouts.pattern(format))
        Logging.logger.root.add_appenders('stdout')
      end

      # debug
      # Logging.show_configuration
      # logger.error "error"
      # logger.warn "warn"
      # logger.info "info"

      logger.debug "options: #{@options.inspect}"
      logger.debug "base_dir: #{@options[:base_dir]}" if @options[:base_dir]
      logger.debug "config file: #{@options[:config]}" if @options[:config]
    end

    def execute
      begin

        if action_argument_required?
          action = @argv.shift
          args = @argv

          unless AVAILABLE_ACTIONS.include?(action)
            if action.nil?
              puts "basic_app action required"
            else
              puts "basic_app invalid action: #{action}"
            end
            puts "basic_app --help for more information"
            exit 1
          end
          logger.debug "repo run action: #{action} #{args.join(' ')}"
          klass = Object.const_get('BasicApp').const_get("#{action.capitalize}Action")
          result = klass.new(args, @configuration).execute
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
        logger.debug "basic_app run system exit: #{e}, status code: #{e.status}"
        exit(e.status)
      rescue Exception => e
        logger.fatal("basic_app fatal exception")
        STDERR.puts("basic_app failed: #{e.message}".red)
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

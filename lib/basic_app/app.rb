require 'term/ansicolor'

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
      if @options[:verbose]
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

          unless AVAILABLE_ACTIONS.include?(action)
            if action.nil?
              puts "basic_app action required"
            else
              puts "basic_app invalid action: #{action}"
            end
            puts "basic_app --help for more information"
            exit 1
          end
          puts "repo run action: #{action} #{args.join(' ')}".cyan if @options[:verbose]
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
        puts "basic_app run system exit: #{e}, status code: #{e.status}".green if @options[:verbose]
        exit(e.status)
      rescue Exception => e
        STDERR.puts("basic_app command failed, error(s) follow:")
        STDERR.puts("#{e.message}".red)
        STDERR.puts("Use '--verbose' for backtrace.") unless @options[:verbose]
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

require 'term/ansicolor'
require 'optparse'

class String
  include Term::ANSIColor
end

module Repoman

  AVAILABLE_ACTIONS = %w[help list path init status git]

  # these commands don't need to have the 'git' arg precede them
  GIT_NATIVE_SUPPORT = %w[add config branch checkout commit diff fetch
                          grep log merge mv pull push rm show tag
                          gc remote ls-files cat-file diff-files
                          diff-index]

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
          #if action == 'list'
            # transform action to a namespaced class, ie. 'list' = Repoman::ListAction
            klass = Object.const_get('Repoman').const_get("#{action.capitalize}Action")
            result = klass.new(args, @configuration).execute
          #else
          #  raise "action #{action} not implemented" unless respond_to?(action)
          #  result = send(action, args)
          #end
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

    # @group CLI actions
    #
    # CLI help
    #
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

      # TODO: refactor so that each action class knows how to handle help
      case action
        when 'help'
          puts "Provide help for an action"
          puts "Usage: repo help [action]"
        when 'path'
          puts help_for_method(:path, :comment_starting_with => "Show repository path")
        when 'git'
          puts help_for_method(:git, :comment_starting_with => "Native 'git' command")
        else
          send(action, ['--help'])
      end

      exit(0)
    end

  private

    # true if application requires an action to be specified on the command line
    def action_argument_required?
      !AVAILABLE_ACTIONS.empty?
    end

    # Convert method comments block to help text
    #
    # @return [String] suitable for displaying on STDOUT
    def help_for_method(method_name, options={})
      comment_starting_with = options[:comment_starting_with]
      method_name = method_name.to_s
      located_in_file = options[:located_in_file] || __FILE__
      text = File.read(located_in_file)

      result = text.match(/(^\s*#\s*#{comment_starting_with}.*)^\s*def #{method_name}/m)
      result = $1
      result = result.gsub(/ @example/, '')
      result = result.gsub(/ @return \[Number\]/, ' Exit code:')
      result = result.gsub(/ @return .*/, '')
      result = result.gsub(/ @see .*$/, '')

      # strip the leading whitespace, the '#' and space
      result = result.gsub(/^\s*# ?/, '')

      # strip surrounding whitespace
      result.strip

      result += "General options:\n"
      result += @options[:general_options_summary].to_s
    end

  end

end

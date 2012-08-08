####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'optparse'

module BasicApp

  # @group CLI actions
  #
  # CLI help
  #
  # Provide help for an action
  #
  # @example Usage: basic_app help [action]
  class HelpAction < AppAction

    # Add action specific options
    def parse_options
      super do |opts|

        opts.on("--actions", "List available actions") do |a|
          options[:actions] = a
        end

      end
    end

    def process
      parse_options
      action = args.shift

      if options[:actions]
        AVAILABLE_ACTIONS.each do |act|
          puts act
        end

        exit(0) unless action
      end

      unless action
        puts "no action specified"
        puts "Usage: basic_app help action | basic_app --help"
        puts ""
        puts "Where 'action' is one of: #{AVAILABLE_ACTIONS.join(' ')}"

        exit(0)
      end

      action = action.downcase
      unless AVAILABLE_ACTIONS.include?(action)
        puts "invalid help action: #{action}"
        exit(0)
      end

      klass = Object.const_get('BasicApp').const_get("#{action.capitalize}Action")
      app_action = klass.new(['--help'], configuration)
      app_action.option_parser = self.option_parser
      result = app_action.execute

      exit(0)
    end

    def help
      super :comment_starting_with => "CLI help", :located_in_file => __FILE__
    end

  end
end

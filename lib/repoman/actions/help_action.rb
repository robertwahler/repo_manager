####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'optparse'

module Repoman

  # @group CLI actions
  #
  # CLI help
  #
  # Provide help for an action
  #
  # @example Usage: repo help [action]
  class HelpAction < AppAction

    def execute

      OptionParser.new do |opts|
        opts.banner = help
        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          puts "option error: #{e}"
          puts opts
          exit 1
        end
      end

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
        puts "invalid help action: #{action}"
        exit(0)
      end

      klass = Object.const_get('Repoman').const_get("#{action.capitalize}Action")
      result = klass.new(['--help'], configuration).execute

      exit(0)
    end

    def help
      super :comment_starting_with => "CLI help", :located_in_file => __FILE__
    end

  end
end

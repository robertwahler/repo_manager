require 'optparse'

module Repoman

  # @group CLI actions
  #
  # Show repository path contained in the configuration file to STDOUT.
  #
  # @example Usage: repo path
  #
  # Alias for 'repo list --listing=path'
  #
  # @see #list
  class PathAction < AppAction

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

      Repoman::ListAction.new(args.push('--listing=path'), configuration).execute
    end

    def help
      super :comment_starting_with => "Show repository path", :located_in_file => __FILE__
    end
  end
end

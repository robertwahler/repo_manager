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
  #
  class PathAction < AppAction

    def execute
      Repoman::ListAction.new(args.push('--listing=path'), configuration).execute
    end

  end
end

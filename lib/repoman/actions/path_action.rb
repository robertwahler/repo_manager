module RepoManager

  # @group CLI actions
  #
  # Show repository path contained in the configuration file to STDOUT.
  #
  # @example Usage: repo path
  #
  # Alias for 'repo list --list=path'
  #
  # @see #list
  class PathAction < AppAction

    def execute
      RepoManager::ListAction.new(args.push('--list=path'), configuration).execute
    end

    def help
      super :comment_starting_with => "Show repository path", :located_in_file => __FILE__
    end
  end
end

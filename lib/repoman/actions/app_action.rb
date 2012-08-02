####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
module RepoManager

  # An abstract superclass for basic action functionality specific to an
  # application implementation.  Put application specific code here.
  class AppAction < BaseAction

    # Used by asset factory to create assets.  Override in app_action.rb or a
    # descendant to set the class to be instantiated by by the AssetManager.
    #
    # @return [Symbol] asset type
    def asset_type
      :repo_asset
    end

    # alias for items/assets
    #
    # @return [Array] of repos
    def repos
      items
    end
  end

end

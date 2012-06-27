####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
module Repoman

  # An abstract superclass for basic action functionality specific to an
  # application implementation.  Put application specific code here.
  class AppAction < BaseAction

    # used by
    #   * asset factory to create assets
    #   * asset configuration to build attributes_key
    #   * asset configuration to determine the default asset configuration file name
    #
    # @return [Symbol] asset type
    def asset_type
      :repo_asset
    end

    # override asset_type for legacy, allows "repos:" instead of "repo_assets"
    def asset_key
      :repos
    end

    # alias for items/assets
    #
    # @return [Array] of repos
    def repos
      items
    end
  end

end

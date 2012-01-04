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

   # application overrides
    def asset_options
      result = super

      type = result[:type] || :repo_asset
      result = result.merge(:type => type)

      attributes_key = result[:type] ? "#{type.to_s}s".to_sym : :repos
      result = result.merge(:attributes_key => attributes_key)

      # optional key: :assets_folder, absolute path or relative to config file if :base_folder is specified
      puts configuration.inspect
      result = result.merge(:assets_folder => configuration[:folders][attributes_key]) if configuration[:folders]

      puts result.inspect
      result
    end
  end

end

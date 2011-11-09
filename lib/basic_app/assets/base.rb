####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'condenser/assets/configuration'

module Condenser

  class BaseAsset

    # asset name is tied to the name of the configuration folder (datastore)
    attr_accessor :name

    def initialize(config_folder=nil, options={})
      configuration.parent = options[:parent]
      if config_folder
        logger.debug "initializing new asset with folder: #{config_folder}"
        configuration.load(config_folder.to_s)
      end
    end

    def configuration
      @configuration ||= Condenser::AssetConfiguration.new(self)
    end

    # attributes is the hash loaded from the asset config file
    def attributes
      @attributes ||= {}
    end

    def to_hash
      result = {}
      result.merge!(:name => name) if name
      result.merge!(:attributes => attributes)
      result
    end

  end
end

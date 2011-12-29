####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'repoman/assets/asset_configuration'

module Repoman

  class BaseAsset

    # asset name is tied to the name of the configuration folder (datastore)
    attr_accessor :name

    # subclass factory
    def self.create(name, config_folder=nil, options={})
      name ||= :app_asset
      classified_name = name.to_s.split('_').collect!{ |w| w.capitalize }.join
      Object.const_get('Repoman').const_get(classified_name).new(config_folder, options)
    end

    def initialize(config_folder=nil, options={})
      configuration.parent = options[:parent]
      if config_folder
        logger.debug "initializing new asset with folder: #{config_folder}"
        configuration.load(config_folder.to_s)
      end
    end

    def configuration
      @configuration ||= Repoman::AssetConfiguration.new(self)
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

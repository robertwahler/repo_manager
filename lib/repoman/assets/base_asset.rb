####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'pathname'

require 'repoman/assets/asset_configuration'

module Repoman

  class BaseAsset

    # asset name is tied to the name of the configuration folder (datastore),
    # if the folder exists.  The name may also be a hash key from a YAML config
    # file.
    attr_accessor :name

    # subclass factory to create Assets
    #
    # Call with classname to create.  Pass in optional configuration folder
    # name and/or a hash of attributes
    #
    # @param [String] asset_type (AppAsset) classname to initialize
    # @param [String] asset_name (nil) asset name or folder name, if folder, will load YAML config
    # @param [Hash] attributes ({}) initial attributes
    #
    # @return [BaseAsset] the created BaseAsset or decendent asset
    def self.create(asset_type=:app_asset, asset_name=nil, attributes={})
      @asset_type = asset_type
      classified_name = asset_type.to_s.split('_').collect!{ |w| w.capitalize }.join
      Object.const_get('Repoman').const_get(classified_name).new(asset_name, attributes)
    end

    # @param [String] asset_name (nil) asset name or folder name, if folder, will load YAML config
    # @param [Hash] attributes ({}) initial attributes
    def initialize(asset_name=nil, attributes={})
      @name = Pathname.new(asset_name).basename.to_s
      logger.debug "Asset name: #{@name}"

      @attributes = attributes.dup

      if asset_name && File.exists?(asset_name)
        logger.debug "initializing new asset with folder: #{asset_name}"
        configuration.load(asset_name.to_s)
      end
    end

    def asset_type
      @asset_type ||= :app_asset
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

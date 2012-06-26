####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'mustache'

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
      classified_name = asset_type.to_s.split('_').collect!{ |w| w.capitalize }.join
      Object.const_get('Repoman').const_get(classified_name).new(asset_name, attributes)
    end

    # takes any path and returns a string suitable for asset name (Ruby identifier)
    #
    # @return [String] valid asset name
    def self.path_to_name(path)
      basename = File.basename(path)
      basename = basename.gsub(/\&/,' and ')
      basename = basename.downcase.strip.gsub(/ /,'_')
      basename = basename.gsub(/[^a-zA-Z_0-9]/,'')
      basename = basename.downcase.strip.gsub(/ /,'_')
      basename.gsub(/[_]+/,'_')
    end

    # @param [String] asset_name asset name or folder name, if folder, will load YAML config
    # @param [Hash] attributes ({}) initial attributes
    def initialize(asset_name=nil, attributes={})
      # allow for lazy loading (TODO), don't assign empty attributes
      @attributes = attributes.dup unless attributes.empty?

      #raise ArgumentError, "asset_name or configuration folder required" unless (asset_name.is_a?(String) || asset_name.is_a?(Symbol))
      return unless asset_name

      @asset_key = nil
      folder = asset_name.to_s
      @name = Repoman::BaseAsset.path_to_name(folder)

      logger.debug "Asset name: #{name}"
      logger.debug "Asset configuration folder: #{folder}"

      if File.exists?(folder)
        logger.debug "initializing new asset with folder: #{folder}"
        configuration.load(folder)
      end
    end

    # The asset_key, if defined, will be used as key to asset attributes when
    # loading from YAML, if not defined, the entire YAML file will load.
    #
    # Override in decendants.
    #
    # @ return [Symbol] or nil
    def asset_key
      nil
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

    # ERB binding
    def get_binding
      binding
    end

    # @return [String/nil] with mustache {{}} replaced or an nil if template is nil
    def render(template)
      return nil unless template

      Mustache.render(template, self)
    end

  end
end

####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'pathname'

require 'basic_app/assets/asset_configuration'

module BasicApp

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
    # @param [String] klassname classname (AppAsset) to initialize
    def self.create(klassname, config_folder=nil, attributes={})
      klassname ||= :app_asset
      classified_name = klassname.to_s.split('_').collect!{ |w| w.capitalize }.join
      Object.const_get('BasicApp').const_get(classified_name).new(config_folder, attributes)
    end

    def initialize(config_folder=nil, attributes={})
      @name = Pathname.new(config_folder).basename.to_s
      logger.debug "Asset name: #{@name}"

      if config_folder && File.exists?(config_folder)
        logger.debug "initializing new asset with folder: #{config_folder}"
        configuration.load(config_folder.to_s)
      end
    end

    def configuration
      @configuration ||= BasicApp::AssetConfiguration.new(self)
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

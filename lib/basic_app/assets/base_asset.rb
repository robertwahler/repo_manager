####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
require 'mustache'
require 'pathname'

require 'basic_app/assets/asset_configuration'
require 'basic_app/assets/asset_accessors'

module BasicApp

  class BaseAsset
    include BasicApp::AssetAccessors
    extend BasicApp::AssetAccessors

    #
    # --- Asset attributes START here ---
    #

    # Asset defined path
    #
    # Defaults to asset name when the path attribute is blank
    #
    # NOTE: This is not the path to the asset configuration file. If not an
    # absolute path, then it is relative to the current working directory
    #
    # @example Full paths
    #
    #     path: /home/robert/photos/photo1.jpg
    #
    #     path: /home/robert/app/appfolder
    #
    # @example Home folder '~' paths are expanded automatically
    #
    #     path: ~/photos/photo1.jpg  -> /home/robert/photos/photo1.jpg
    #
    # @example Relative paths are expanded automatically relative to the CWD
    #
    #     path: photos/photo1.jpg  -> /home/robert/photos/photo1.jpg
    #
    # @example Mustache templates are supported
    #
    #     path: /home/robert/{{name}}/appfolder -> /home/robert/app1/appfolder
    #
    # @example Mustache braces that come at the start must be quoted
    #
    #     path: "{{name}}/appfolder" -> /home/robert/app1/appfolder
    #
    # @return [String] an absolute path
    def path
      return @path if @path

      path = attributes[:path] || name
      path = render(path)
      if (path && !Pathname.new(path).absolute?)
        # expand path if starts with '~'
        path = File.expand_path(path) if path.match(/^~/)
        # paths can be relative to cwd
        path = File.join(File.expand_path(FileUtils.pwd), path) if (!Pathname.new(path).absolute?)
      end
      @path = path
    end
    def path=(value)
      @path = nil
      attributes[:path] = value
    end

    # Description (short)
    #
    # @return [String]
    create_accessors :description

    # Notes (user)
    #
    # @return [String]
    create_accessors :notes

    # Classification tags, an array of strings
    #
    # @return [Array] of tag strings
    def tags
      attributes[:tags] || []
    end
    def tags=(value)
      attributes[:tags] = value
    end

    #
    # --- Asset attributes END here ---
    #

    # The asset name is loosely tied to the name of the configuration folder (datastore).
    # The name may also be a hash key from a YAML config file.
    #
    # The name should be a valid ruby variable name, in turn, a valid folder name, but this
    # is not enforced.
    #
    # @see self.path_to_name
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
      Object.const_get('BasicApp').const_get(classified_name).new(asset_name, attributes)
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

    # @param [String/Symbol] asset name or folder, if folder exists, will load YAML config
    # @param [Hash] attributes ({}) initial attributes
    def initialize(asset_name_or_folder=nil, attributes={})
      # allow for lazy loading (TODO), don't assign empty attributes
      @attributes = attributes.dup unless attributes.empty?

      # create user_attribute methods
      create_accessors(@attributes[:user_attributes]) if @attributes && @attributes[:user_attributes]

      return unless asset_name_or_folder

      @asset_key = nil
      folder = asset_name_or_folder.to_s
      @name = File.basename(folder)

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

    # ERB binding
    def get_binding
      binding
    end

    # @return [String/nil] with mustache tags {{}}, {{{}}} replaced or nil if template is nil
    def render(template)
      return nil unless template

      Mustache.render(template, self)
    end

    # support for Mustache rendering of ad hoc user defined variables
    # if the key exists in the hash, use if for a lookup
    def method_missing(name, *args, &block)
      return attributes[name.to_sym] if attributes.include?(name.to_sym)
      return super
    end

    # method_missing support
    def respond_to?(name)
      return true if attributes.include?(name.to_sym)
      super
    end

  end
end

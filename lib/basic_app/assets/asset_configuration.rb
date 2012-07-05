require 'yaml'
require 'erb'
require 'pathname'
require 'fileutils'

module BasicApp

  # asset_configuration saves just the user data by subtracting out the
  # global hash and writing just the result
  #
  # An asset requires a global template but doesn't require a user datafile.
  #
  # LOADING:
  #
  # Load up the master template YAML file first,  evaluate the ERB, save this
  # hash for later use.
  #
  # Copy the results to the asset attributes and then load the user data.  The
  # user data doesn't contain ERB.
  #
  # SAVING:
  #
  # Compare existing asset attributes to the saved and eval'd master hash and write
  # just the change assets to the user file.
  #
  class AssetConfiguration

    # user datastore folder, can override parent datastore
    attr_accessor :folder

    # parent datastore defaults folder, read asset from here first if exists
    attr_accessor :parent

    attr_reader :asset

    def initialize(asset)
      #logger.debug "initializing new AssetConfiguration with asset class: #{asset.class.to_s}"
      @asset = asset
    end

    # Save specific attributes to an asset configuration file. Only the param
    # 'attrs' and the current  contents of the config file are saved. Parent
    # asset configurations are not saved.
    #
    # @raises
    def save(attrs=nil)
      raise "a Hash of attributes to save must be specified" unless attrs && attrs.is_a?(Hash)
      raise "folder must be set prior to saving attributes" unless folder

      # merge attributes to asset that contains parent attributes
      @asset.attributes.merge!(attrs)

      # load contents of the user folder and merge in attributes passed to save
      # so that we don't save parent attributes
      contents = {}
      if File.exists?(folder)
        contents = load_contents(folder)
        raise "expected contents to be a hash" unless contents.is_a?(Hash)
      end

      contents = contents.merge!(attrs)
      write_contents(folder, contents)
    end

    # load an asset from a configuration folder
    def load(ds=nil)
      @folder ||= ds

      contents = load_contents(folder)

      # if a global parent folder is defined, load it first
      parent = contents.delete(:parent) || parent
      if parent
        parent_folder = File.join(parent)
        unless Pathname.new(parent_folder).absolute?
          base_folder = File.dirname(folder)
          parent_folder = File.join(base_folder, parent_folder)
        end

        logger.debug "AssetConfiguration loading parent: #{parent_folder}"
        parent_configuration = BasicApp::AssetConfiguration.new(asset)

        begin
          parent_configuration.load(parent_folder)
        rescue
          logger.warn "AssetConfiguration parent configuration load failed: #{parent_folder}"
        end
      end

      # use part of the contents keyed to asset_key, allows
      # mutiple asset_types to share the same configuration file
      contents = contents[asset.asset_key].dup if (asset.asset_key && contents.has_key?(asset.asset_key))

      # Load all attributes as hash 'attributes' so that merging
      # and adding new attributes doesn't require code changes. Note
      # that the 'parent' setting is not merged to attributes
      @asset.attributes.merge!(contents)
      @asset.create_accessors(@asset.attributes[:user_attributes])
      @asset
    end

    def to_hash
      result = {}
      result.merge!(:parent => parent.folder) if parent
      result.merge!(:attributes => @asset.attributes)
      result
    end

    private

    # load the raw contents from an asset_folder, ignore parents
    #
    # @return [Hash] of the raw text contents
    def load_contents(asset_folder)
      file = File.join(asset_folder, 'asset.conf')
      if File.exists?(file)
        contents = YAML.load(ERB.new(File.open(file, "rb").read).result(@asset.get_binding))
        contents.recursively_symbolize_keys! if contents && contents.is_a?(Hash)
        contents
      else
        {}
      end
    end

    # write raw contents to an asset_folder
    def write_contents(asset_folder, contents)
      contents.recursively_stringify_keys!

      FileUtils.mkdir(asset_folder) unless File.exists?(asset_folder)
      filename = File.join(asset_folder, 'asset.conf')

      #TODO, use "wb" and write CRLF on Windows
      File.open(filename, "w") do |f|
        f.write(contents.to_conf)
      end
    end

  end
end

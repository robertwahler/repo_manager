require 'yaml'
require 'pathname'

module Condenser

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

    # global parent datastore config store folder, read asset from here
    # first if exists
    attr_accessor :parent

    def initialize(asset)
      logger.debug "initializing new AssetConfiguration"
      @asset = asset
    end

    # save an asset to a configuration file
    def save(ds=nil)
      folder ||= ds
      raise "not implemented"
    end

    # load an asset from a configuration folder
    def load(ds=nil)
      folder ||= ds
      @asset.name = Pathname.new(folder).basename.to_s
      logger.debug "Asset name: #{@asset.name}"

      file = File.join(folder, 'asset.conf')
      contents = YAML::load(File.open(file))
      contents.symbolize_keys! if contents && contents.is_a?(Hash)

      # if a global parent folder is defined, load it first
      parent = contents.delete(:parent) || parent
      if parent
        # TODO: load 'default' global folder first, if it exists

        parent_folder = File.join(parent, 'assets', @asset.name)
        unless Pathname.new(parent_folder).absolute?
          base_folder = File.dirname(folder)
          parent_folder = File.join(base_folder, parent_folder)
        end

        logger.debug "AssetConfiguration loading parent: #{parent_folder}"
        parent_configuration = Condenser::AssetConfiguration.new(@asset)
        parent_configuration.load(parent_folder)
      end

      # TODO: load 'default' user folder first, if it exists

      # Load all attributes as hash 'attributes' so that merging
      # and adding new attributes doesn't require code changes. Note
      # that the 'parent' setting is not merged to attributes
      @asset.attributes.merge!(contents)
    end

    def to_hash
      result = {}
      result.merge!(:parent => parent.folder) if parent
      result.merge!(:attributes => @asset.attributes)
      result
    end

  end
end

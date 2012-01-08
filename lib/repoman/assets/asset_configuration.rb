require 'yaml'
require 'pathname'

module Repoman

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
      logger.debug "initializing new AssetConfiguration with asset class: #{asset.class.to_s}"
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

      file = File.join(folder, 'asset.conf')
      contents = YAML::load(File.open(file, "rb") {|f| f.read})
      contents.symbolize_keys! if contents && contents.is_a?(Hash)

      # if a global parent folder is defined, load it first
      parent = contents.delete(:parent) || parent
      if parent
        parent_folder = File.join(parent)
        unless Pathname.new(parent_folder).absolute?
          base_folder = File.dirname(folder)
          parent_folder = File.join(base_folder, parent_folder)
        end

        logger.debug "AssetConfiguration loading parent: #{parent_folder}"
        parent_configuration = Repoman::AssetConfiguration.new(asset)
        parent_configuration.load(parent_folder)
      end

      # use part of the contents keyed to asset_key, allows
      # mutiple asset_types to share the same configuration file
      contents = contents[asset.asset_key].dup if (asset.asset_key && contents.has_key?(asset.asset_key))

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

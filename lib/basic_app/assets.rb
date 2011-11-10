require 'basic_app/assets/base'
require 'basic_app/assets/app'

require 'pathname'
require 'fileutils'

module BasicApp
  module Assets

  # options hash
    #
    # @return [Array] of Asset
    #
    def assets(options={})
      type = options[:type] || :app_asset

      if @assets
        return @assets[type] if @assets[type]
      else
        @assets = {}
      end

      raise "config file not found" unless configuration[:configuration_filename]
      user_folder = configuration[:folders][:user]
      logger.debug "reading from user_folder:'#{user_folder}' "

      asset_folder = options[:asset_folder] || "#{type.to_s}s"
      pattern = File.join(user_folder, asset_folder, '*/')
      # user_folder can be relative to main config file
      unless Pathname.new(pattern).absolute?
        base_folder = File.dirname(configuration[:configuration_filename])
        pattern = File.expand_path(File.join(base_folder, pattern))
      end
      logger.debug "asset glob pattern: #{pattern}"
      folders = Dir.glob(pattern)
      warn "config user folder pattern did not match any folders: #{pattern}" if folders.empty?

      logger.debug "generating assets array"
      assets = []
      folders.sort.each do |folder|
        # this is a good place to set a default ':parent' based on the
        # options hash and the asset folder, ex: condenser
        asset_options = {}
        asset = BasicApp::AppAsset.create(type, folder, asset_options)
        assets << asset
      end
      @assets[type] = assets
      @assets[type]
    end

  end
end

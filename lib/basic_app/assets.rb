require 'condenser/assets/base'
require 'condenser/assets/app'

require 'pathname'
require 'fileutils'

module Condenser
  module Assets

    # @return [Array] of Asset
    def assets
      return @assets if @assets
      raise "config file not found" unless configuration[:configuration_filename]

      user_folder = configuration[:folders][:user]
      logger.debug "reading from user_folder:'#{user_folder}' "

      pattern = File.join(user_folder, 'assets', '*/')
      # user_folder can be relative to main config file
      unless Pathname.new(pattern).absolute?
        base_folder = File.dirname(configuration[:configuration_filename])
        pattern = File.expand_path(File.join(base_folder, pattern))
      end
      logger.debug "asset glob pattern: #{pattern}"
      folders = Dir.glob(pattern)
      warn "config user folder pattern did not match any folders: #{pattern}" if folders.empty?

      # set the condenser global datastore folder
      options={}
      parent = configuration[:folders][:global]
      if parent
        unless Pathname.new(parent).absolute?
          base_folder = File.dirname(configuration[:configuration_filename])
          parent = File.expand_path(File.join(base_folder, parent))
        end
        options[:parent] = parent
      end

      logger.debug "generating assets array"
      @assets = []
      folders.sort.each do |folder|
        asset = Condenser::AppAsset.new(folder, options)
        @assets << asset
      end
      @assets

    end

  end
end

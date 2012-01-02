require 'basic_app/assets/base_asset'
require 'basic_app/assets/app_asset'

require 'pathname'
require 'fileutils'

module BasicApp

  # mixin module for actions used to describe and filter generic assets
  module Assets

    #
    # @raise [Exception] unless configuration ha
    #
    # @return [Array] of Asset
    def assets(asset_discovery_options={})
      type = asset_discovery_options[:type] || :app_asset

      if @assets
        return @assets[type] if @assets[type]
      else
        @assets = {}
      end

      raise "config file not found" unless configuration[:configuration_filename]
      user_folder = configuration[:folders][:user] if configuration[:folders]
      user_folder ||= ""
      logger.debug "reading from user_folder:'#{user_folder}' "

      asset_folder = asset_discovery_options[:asset_folder] || "#{type.to_s}s"
      pattern = File.join(user_folder, asset_folder, '*/')
      # user_folder can be relative to main config file
      unless Pathname.new(pattern).absolute?
        base_folder = File.dirname(configuration[:configuration_filename])
        pattern = File.expand_path(File.join(base_folder, pattern))
      end
      logger.debug "asset glob pattern: #{pattern}"
      folders = Dir.glob(pattern)
      warn "config user folder pattern did not match any folders: #{pattern}" if folders.empty?

      filters = asset_discovery_options[:filter] || ['.*']
      match_count = 0
      assets = []
      logger.debug "generating assets array with filter array: #{filters.join(',')}"
      folders.sort.each do |folder|
        folder_basename = Pathname.new(folder).basename.to_s
        logger.debug "matching folder: #{folder} using basename: #{folder_basename}"
        if filters.find {|filter| matches?(folder_basename, filter, asset_discovery_options)}
          logger.debug "match found for: #{folder_basename}"
          match_count += 1
          asset = BasicApp::AppAsset.create(type, folder, {})
          assets << asset
          break if ((asset_discovery_options[:match] == 'FIRST') || (asset_discovery_options[:match] == 'EXACT'))
          raise "match mode = ONE, multiple matching assets found filter" if (asset_discovery_options[:match] == 'ONE' && match_count > 1)
        end

      end
      @assets[type] = assets
      @assets[type]
    end

  private

    def matches?(str, filter, match_options={})
      if (match_options[:match] == 'EXACT')
        str == filter
      else
        str.match(/#{filter}/)
      end
    end

  end
end

require 'basic_app/assets/base_asset'
require 'basic_app/assets/app_asset'

require 'pathname'
require 'fileutils'

module BasicApp
  # mixin module for actions used to describe and filter generic assets
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
      user_folder = configuration[:folders][:user] if configuration[:folders]
      user_folder ||= ""
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

      filters = options[:filter] || ['.*']
      match_count = 0
      assets = []
      logger.debug "generating assets array with filter array: #{filters.join(',')}"
      folders.sort.each do |folder|
        logger.debug "matching name: #{folder}"
        if filters.find {|filter| matches?(folder, filter)}
          logger.debug "match found for: #{folder}"
          match_count += 1
          asset_options = {}
          asset = BasicApp::AppAsset.create(type, folder, asset_options)
          assets << asset
          break if ((options[:match] == 'FIRST') || (options[:match] == 'EXACT'))
          raise "match mode = ONE, multiple matching assets found filter" if (options[:match] == 'ONE' && match_count > 1)
        end

      end
      @assets[type] = assets
      @assets[type]
    end

  private

    def matches?(str, filter)
      if (options[:match] == 'EXACT')
        str == filter
      else
        str.match(/#{filter}/)
      end
    end

  end
end

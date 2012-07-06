####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################

require 'pathname'
require 'fileutils'

module Repoman

  class AssetManager

    # @raise [Exception] unless asset_options contains base_folder or :assets if an absolute path
    #
    # @return [Array] of Asset
    def assets(asset_options={})
      logger.debug "asset_options: #{asset_options.inspect}"
      # type of asset to create, used to guess the asset_folder name
      type = asset_options[:type] || :app_asset

      assets = []
      filters = asset_options[:filter] || ['.*']
      match_count = 0
      logger.debug "generating assets array with filter array: #{filters.join(',')}"

      assets_folder = asset_options[:assets_folder] || "assets"
      pattern = File.join(assets_folder, '*/')
      logger.debug "reading from asset type: '#{type}' from assets_folder:'#{assets_folder}' "

      # asset folder can be relative to main config file
      unless Pathname.new(pattern).absolute?
        # base_folder is determined from the configuration file
        # location, if it is not set, then the configuration file wasn't not found
        raise "configuration file not found" unless asset_options[:base_folder]
        base_folder = asset_options[:base_folder]
        pattern = File.expand_path(File.join(base_folder, pattern))
      end
      logger.debug "asset glob pattern: #{pattern}"
      folders = Dir.glob(pattern)
      logger.debug "user assets folder is empty: #{pattern}" if folders.empty?

      folders.sort.each do |folder|
        folder_basename = Pathname.new(folder).basename.to_s
        #logger.debug "matching folder: #{folder} using basename: #{folder_basename}"
        if filters.find {|filter| matches?(folder_basename, filter, asset_options)}
          logger.debug "match found for: #{folder_basename}"
          match_count += 1
          asset = Repoman::AppAsset.create(type, folder, {})
          assets << asset
          break if ((asset_options[:match] == 'FIRST') || (asset_options[:match] == 'EXACT'))
          raise "match mode = ONE, multiple matching assets found filter" if (asset_options[:match] == 'ONE' && match_count > 1)
        end
      end

      assets
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

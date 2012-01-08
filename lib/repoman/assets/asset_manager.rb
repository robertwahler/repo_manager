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

    def initialize(raw_attributes={})
      @raw_attributes = raw_attributes
    end

    # @raise [Exception] unless asset_options contains base_folder or :assets if an absolute path
    #
    # @return [Array] of Asset
    def assets(asset_options={})

      # type of asset to create, used to guess attributes_key and asset_folder name
      type = asset_options[:type] || :app_asset

      attributes_key = asset_options[:asset_key] || "#{type.to_s}s".to_sym
      assets = []
      filters = asset_options[:filter] || ['.*']
      match_count = 0
      logger.debug "generating assets array with filter array: #{filters.join(',')}"

      # if attributes_key exists in raw_attributes, use that
      if !@raw_attributes.empty? && @raw_attributes.has_key?(attributes_key)
        config_hash = @raw_attributes[attributes_key]
        logger.debug "configuring assets from master configuration hash using key:'#{attributes_key}' "
        config_hash.keys.sort_by{ |sym| sym.to_s}.each do |key|
          name = key.to_s
          attributes = {:name => name}
          attributes = attributes.merge(config_hash[key]) if config_hash[key]
          if filters.find {|filter| matches?(name, filter, asset_options)}
            logger.debug "match found for: #{name}"
            match_count += 1
            asset = Repoman::AppAsset.create(type, name, attributes)
            assets << asset
            break if ((asset_options[:match] == 'FIRST') || (asset_options[:match] == 'EXACT'))
            raise "match mode = ONE, multiple matching assets found filter" if (asset_options[:match] == 'ONE' && match_count > 1)
          end
        end
      # otherwise, try and load from assets_folder
      else
        assets_folder = asset_options[:assets_folder] || "#{type.to_s}s"
        pattern = File.join(assets_folder, '*/')
        logger.debug "reading from asset type: '#{type}' from assets_folder:'#{assets_folder}' "

        # asset folder can be relative to main config file
        unless Pathname.new(pattern).absolute?
          raise "assets_folder not absolute path and base_folder not specified" unless asset_options[:base_folder]
          base_folder = asset_options[:base_folder]
          pattern = File.expand_path(File.join(base_folder, pattern))
        end
        logger.debug "asset glob pattern: #{pattern}"
        folders = Dir.glob(pattern)
        warn "config user folder pattern did not match any folders: #{pattern}" if folders.empty?

        folders.sort.each do |folder|
          folder_basename = Pathname.new(folder).basename.to_s
          logger.debug "matching folder: #{folder} using basename: #{folder_basename}"
          if filters.find {|filter| matches?(folder_basename, filter, asset_options)}
            logger.debug "match found for: #{folder_basename}"
            match_count += 1
            asset = Repoman::AppAsset.create(type, folder, {})
            assets << asset
            break if ((asset_options[:match] == 'FIRST') || (asset_options[:match] == 'EXACT'))
            raise "match mode = ONE, multiple matching assets found filter" if (asset_options[:match] == 'ONE' && match_count > 1)
          end
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

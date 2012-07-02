require 'repoman'
require 'repoman/tasks/task_manager'
require 'repoman/actions/action_helper'
require 'pathname'

module Repoman

  module GenerateHelper

    def asset_name_to_config_file(name=nil)
      raise "unable to find configuration key ':folders'" unless configuration[:folders]
      raise "unable to find configuration key ':folders => :repos'" unless configuration[:folders][:repos]

      folder = configuration.folders[:repos]
      unless folder
        say "unable to find folder conf key ':folders => :repos', please set key"
        exit 1
      end

      if name
        file = File.join(File.expand_path(folder), name, "asset.conf")
      end

      file
    end

  end

  class Generate < Thor
    namespace :generate
    include Thor::Actions
    include Repoman::ThorHelper
    include Repoman::GenerateHelper
    include ::Repoman::ActionHelper

    # adds :quiet, :skip, :pretent, :force
    add_runtime_options!

    method_option :filter, :type => :array, :aliases => "-f", :desc => "List of regex folder name filters"
    method_option :refresh, :type => :boolean, :aliases => "-r", :desc => "Refresh existing blank attributes"

    desc "config FOLDER", "generate multiple config files by searching a folder for apps"
    def config(folder)

      say_status "collecting",  "collecting top level folder names"
      discovered_assets = []
      filters = options[:filter] || ['.*']
      # Thor does not allow comma separated array options, fix that here
      filters = filters.first.to_s.split(',') if filters.length == 1
      Dir.glob( File.join(folder, '*/')  ).each do |repo_folder|
        logger.debug "filters: #{filters.inspect}"
        next unless filters.find {|filter| repo_folder.match(/#{filter}/)}
        next unless File.exists?(File.join(repo_folder, '.git/'))

        # check existing assets for path match, if found, use existing name instead of the generated name
        existing = existing_assets.detect do |existing_asset|
          existing_asset.path && repo_folder && (File.expand_path(existing_asset.path) == File.expand_path(repo_folder))
        end

        if (existing)
          name = existing.name
        else
          name = ::Repoman::RepoAsset.path_to_name(repo_folder)
        end

        asset = ::Repoman::RepoAsset.new(name)
        asset.path = File.expand_path(repo_folder)

        discovered_assets << asset
      end

      say_status "configuring",  "setting discovered asset configuration paths"
      discovered_assets.each do |discovered_asset|
        folder = File.dirname(asset_name_to_config_file(discovered_asset.name))
        discovered_asset.configuration.folder = folder
      end

      if options[:refresh]
        if existing_assets.any? && discovered_assets.any?
          say_status "merging",  "merging existing asset attributes"
          discovered_assets.each do |discovered_asset|
            existing_asset = existing_assets.detect do |existing_asset|
              existing_asset.name == discovered_asset.name
            end
            discovered_asset.attributes.merge!(existing_asset.attributes) if existing_asset
          end
        end
      else
        say_status "comparing",  "looking for existing asset names"
        discovered_assets.delete_if do |asset|
          result = false
          if File.exists?(asset.configuration.folder)
            logger.debug "#{asset.name} asset name already exists, skipping"
            result = true
          end
          result
        end

        say_status "comparing",  "looking for existing asset paths"
        discovered_assets.delete_if do |asset|
          result = false
          existing_asset = existing_assets.detect do |existing_asset|
            existing_asset.path && asset.path && (File.expand_path(existing_asset.path) == File.expand_path(asset.path))
          end
          if (existing_asset)
            logger.debug "#{asset.name} path matches existing asset #{existing_asset.name}, skipping"
            result = true
          end
          result
        end
      end

      unless discovered_assets.any?
        say "no assets found for updating"
        exit 0
      end

      # list the new assets found
      say "Discovered assets"
      discovered_assets.each do |asset|
        say_status :found, "%-40s path date => '%s'" % [asset.name, relative_path(asset.path)] , :green
      end

      # prompt the user
      say
      unless options[:force]
        exit 0 unless (ask("Found #{discovered_assets.size} assets, write the configuration files (y/n)?") == 'y')
      end

      # write the assets
      say
      discovered_assets.each do |asset|

        say_status :creating, "repoman configuration file for #{asset.name}", :green
        logger.debug "writing asset #{asset.name} to #{asset.configuration.folder}"
        asset.attributes.merge!(:parent => "../global/default")
        save_writable_attributes(asset, asset.attributes)

      end

    end

    private

    # where to start looking, required by the template method
    def self.source_root
      File.dirname(__FILE__)
    end

    # write only the attributes that we have set
    def save_writable_attributes(asset, attributes)
      valid_keys = [:parent, :path]
      accessable_attributes = {}
      attributes.each do |key, value|
         accessable_attributes[key] = value.dup if valid_keys.include?(key)
      end
      asset.configuration.save(accessable_attributes)
    end

    def existing_assets
      return @existing_assets if @existing_assets
      asset_options = {}
      asset_options.merge!(:asset_key => :repos)
      asset_options.merge!(:assets_folder => configuration[:folders][:repos]) if configuration[:folders]
      asset_options.merge!(:base_folder => File.dirname(configuration[:configuration_filename])) if configuration[:configuration_filename]

      @existing_assets = ::Repoman::AssetManager.new(configuration).assets(asset_options)
    end

  end
end

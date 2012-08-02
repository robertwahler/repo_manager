require 'pathname'
require 'rbconfig'
require 'repo_manager'
require 'repo_manager/actions/action_helper'

module RepoManager
  module ThorHelper
    include ::RepoManager::ActionHelper

    # main repo_manager configuration setttings file
    def configuration(configuration_file=nil)
      return @configuration if @configuration
      logger.debug "getting repo_manager configuration"
      app_options = {}
      app_options[:config] = configuration_file || options[:config]
      @configuration = ::RepoManager::Settings.new(nil, app_options)
    end

    def configuration=(value={})
      logger.debug "setting repo_manager configuration"
      @configuration = value.dup
    end

    def ruby_binary
      File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
    end

  end
end

require 'pathname'
require 'rbconfig'
require 'repoman'
require 'repoman/actions/action_helper'

module RepoManager
  module ThorHelper
    include ::RepoManager::ActionHelper

    # main repoman configuration setttings file
    def configuration(configuration_file=nil)
      return @configuration if @configuration
      logger.debug "getting repoman configuration"
      app_options = {}
      app_options[:config] = configuration_file || options[:config]
      @configuration = ::RepoManager::Settings.new(nil, app_options)
    end

    def configuration=(value={})
      logger.debug "setting repoman configuration"
      @configuration = value.dup
    end

    def ruby_binary
      File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
    end

  end
end

require 'pathname'
require 'rbconfig'
require 'basic_app'
require 'basic_app/actions/action_helper'

module BasicApp
  module ThorHelper
    include ::BasicApp::ActionHelper

    # main basic_app configuration setttings file
    def configuration(configuration_file=nil)
      return @configuration if @configuration
      logger.debug "getting basic_app configuration"
      app_options = {}
      app_options[:config] = configuration_file || options[:config]
      @configuration = ::BasicApp::Settings.new(nil, app_options)
    end

    def configuration=(value={})
      logger.debug "setting basic_app configuration"
      @configuration = value.deep_clone
    end

    def ruby_binary
      File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
    end

  end
end

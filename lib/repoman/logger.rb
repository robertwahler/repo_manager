require 'logging'
include Logging.globally

module RepoManager
  module Logger

    class Manager

      def initialize(config_filename=nil, yaml_key=nil, configuration={})

        options = configuration[:options] || {}

        if config_filename && yaml_key && configuration.has_key?(yaml_key)
          Logging::Config::YamlConfigurator.load(config_filename, yaml_key.to_s)
        else
          # setup a default root level STDOUT logger
          format = {:pattern => '%-5l %c: %m\n'}
          format = format.merge(:color_scheme => 'default') if options[:color]
          Logging.appenders.stdout('stdout', :layout => Logging.layouts.pattern(format), :level => :info)
          Logging.logger.root.add_appenders('stdout')
        end

        # if verbose, all defined loggers are set to debug level
        if options[:verbose]
          Logging.appenders.each do |appender|
            appender.level = :debug
          end
        end

        # debug
        #Logging.show_configuration
        #logger.error "error"
        #logger.warn "warn"
        #logger.info "info"
      end
    end

  end
end

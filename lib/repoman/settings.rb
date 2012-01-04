require 'yaml'

module Repoman

  class Settings

    def initialize(working_dir, options={})
      @working_dir = working_dir
      @options = options
      @configuration = configure
    end

    # entire configuration hash after processing all the individual YAML
    # configuration files
    def to_hash
      @configuration
    end

    # just the configuration 'options' hash
    def options
      @options
    end

  private

    # read options from YAML config
    def configure

      # config file default options
      configuration = {
                        :options => {
                          :verbose => false,
                          :color => 'AUTO',
                          :short => false,
                          :unmodified => 'HIDE',
                          :match => 'ALL',
                          :list => 'ALL'
                        }
                      }

      # set default config if not given on command line
      config = @options[:config]
      unless config
        config = [
                   File.join(@working_dir, "repo.conf"),
                   File.join(@working_dir, ".repo.conf"),
                   File.join(@working_dir, "config", "repo.conf"),
                   File.expand_path(File.join("~", ".repo.conf"))
                 ].detect { |filename| File.exists?(filename) }
      end

      if config && File.exists?(config)
        # load options from the config file, overwriting hard-coded defaults
        config_contents = YAML::load(File.open(config))
        configuration.merge!(config_contents.symbolize_keys!) if config_contents && config_contents.is_a?(Hash)
      else
        # user specified a config file?, no error if user did not specify config file
        raise "config file not found" if @options[:config]
      end

      # store the original full config filename for later use
      configuration[:configuration_filename] = config


      configuration.recursively_symbolize_keys!

      # the command line options override options read from the config file
      @options = configuration[:options].merge!(@options)

      configuration
    end
  
  end

end

require 'yaml'
require 'pathname'

module Repoman

  # @see features/settings.feature
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

    # just the hash of repos collected from individual YAML files
    def repos
      configuration[:repos] || {}
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
                        },
                          :repos => {
                        }
                      }

      # set default config if not given on command line
      config = @options[:config]
      pattern = nil
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

        # optional additional config files to merge
        pattern = configuration[:repo_configuration_glob]
        pattern = File.join(@working_dir, pattern) if pattern && !Pathname.new(pattern).absolute?

      elsif config && !Dir.glob(config).empty?
        # pattern was specified on the command line
        pattern = config
      else
        # user specified a config file?, no error if user did not specify config file
        raise "config file not found: #{config}" if @options[:config]
      end

      # store the original full config filename for later use
      configuration[:configuration_filename] = config

      # process pattern for additional config files and merge the repos key
      if pattern
        files = Dir.glob(pattern)
        warn "config file pattern did not match any files: #{pattern}" if files.empty?
        files.sort.each do |file|
          config_contents = YAML::load(File.open(file))
          config_contents.symbolize_keys! if config_contents && config_contents.is_a?(Hash)
          if config_contents[:repos] and configuration[:repos]
            configuration[:repos].merge!(config_contents[:repos])
          end
        end
      end

      configuration.recursively_symbolize_keys!

      # the command line options override options read from the config file
      @options = configuration[:options].merge!(@options)

      configuration
    end
  end
end

require 'yaml'
require 'erb'
require 'fileutils'
require 'repo_manager/extensions/hash'

module RepoManager

  # Access setting via symbolized keys or using accessor methods
  #
  # @example
  #
  #   settings = Settings.new(FileUtils.pwd, {:config => 'some/file.yml'})
  #
  #       verbose = settings.to_hash[:options] ? settings.to_hash[:options][:verbose] : false
  #
  #    equivalent to:
  #
  #       verbose = settings.options ? settings.options.verbose : false
  #
  # @return [Hash], for pure hash use 'to_hash' instead
  class Settings < Hash
    include RepoManager::Extensions::MethodReader
    include RepoManager::Extensions::MethodWriter

    def initialize(working_dir=nil, options={})
      @working_dir = working_dir || FileUtils.pwd
      @configuration = configure(options.deep_clone)

      # call super without args
      super *[]

      self.merge!(@configuration)
    end

  private

    # read options from YAML config
    def configure(options)

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
                        :commands => [
                          'diff',
                          'grep',
                          'log',
                          'ls-files',
                          'show',
                          'status'
                        ]
                      }

      # set default config if not given on command line
      config = options[:config]
      if config.nil?
        config = [
                   File.join(@working_dir, "repo.conf"),
                   File.join(@working_dir, ".repo.conf"),
                   File.join(@working_dir, "repo_manager", "repo.conf"),
                   File.join(@working_dir, ".repo_manager", "repo.conf"),
                   File.join(@working_dir, "config", "repo.conf"),
                   File.expand_path(File.join("~", ".repo.conf")),
                   File.expand_path(File.join("~", "repo.conf")),
                   File.expand_path(File.join("~", "repo_manager", "repo.conf")),
                   File.expand_path(File.join("~", ".repo_manager", "repo.conf"))
                 ].detect { |filename| File.exists?(filename) }
      end

      if config && File.exists?(config)
        # load options from the config file, overwriting hard-coded defaults
        logger.debug "reading configuration file: #{config}"
        config_contents = YAML.load(ERB.new(File.open(config, "rb").read).result)
        configuration.merge!(config_contents.symbolize_keys!) if config_contents && config_contents.is_a?(Hash)
      else
        # user specified a config file?, no error if user did not specify config file
        raise "config file not found" if options[:config]
      end

      # store the original full config filename for later use
      configuration[:configuration_filename] = config

      configuration.recursively_symbolize_keys!

      # the command line options override options read from the config file
      configuration[:options].merge!(options)
      configuration
    end

  end

end

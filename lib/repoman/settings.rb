require 'yaml'
require 'pathname'

module Repoman

  class Settings

    def initialize(working_dir, options={})
      @working_dir = working_dir
      @options = options
      configure
    end

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
                          :coloring => true,
                          :short => false,
                          :unmodified => 'HIDE',
                          :match => 'ALL',
                          :listing => 'ALL'
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

      # config can be a filename or pattern, if it is a pattern, then we sort
      # by name and merge all the files.
      #
      # If config is a filename, then it may contain a repo filespec, these
      # need to be merged as well.
      #
      if config && File.exists?(config)
        # load options from the config file, overwriting hard-coded defaults
        config_contents = YAML::load(File.open(config))
        configuration.merge!(config_contents.symbolize_keys!) if config_contents && config_contents.is_a?(Hash)

        # config file may point to additional config files to load
        pattern = configuration[:config]
        pattern = File.join(@working_dir, pattern) if pattern && !Pathname.new(pattern).absolute?

      elsif config && !Dir.glob(config).empty?
        pattern = config
      else
        # user specified a config file?, no error if user did not specify config file
        raise "config file not found" if @options[:config]
      end

      # store the original full config filename or pattern for later use, the pattern read from
      # the config file, if any, is not needed anymore
      @options[:config] = config

      # process pattern for additional config files and merge the repos key
      if pattern
        files = Dir.glob(pattern)
        raise "config file pattern did not match any files" if files.empty?
        files.sort.each do |file|
          config_contents = YAML::load(File.open(file))
          config_contents.symbolize_keys! if config_contents && config_contents.is_a?(Hash)
          if config_contents[:repos] and configuration[:repos]
            configuration[:repos].merge!(config_contents[:repos])
          end
        end
      end

      # the command line options override options read from the config file
      @options = configuration[:options].merge!(@options)
      @options.symbolize_keys!

      # repos hash
      @options[:repos] = configuration[:repos].recursively_symbolize_keys! if configuration[:repos]

    end

  end

end

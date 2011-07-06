require 'yaml'

class Hash

  # sorted yaml
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sorted_keys = keys
        sorted_keys = begin
          sorted_keys.sort
        rescue
          sorted_keys.sort_by {|k| k.to_s} rescue sorted_keys
        end

        sorted_keys.each do |k|
          map.add( k, fetch(k) )
        end
      end
    end
  end

  # active_support hash key functions
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end

  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end

  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        v.recursively_symbolize_keys!
      end
    end
    self
  end

end

class Array
  def recursively_symbolize_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_symbolize_keys!
      elsif item.is_a? Array
        item.recursively_symbolize_keys!
      end
    end
  end
end


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
      unless config
        config = [
                   File.join(@working_dir, "repo.conf"),
                   File.join(@working_dir, ".repo.conf"),
                   File.join(@working_dir, "config", "repo.conf"),
                   File.expand_path(File.join("~", ".repo.conf"))
                 ].detect { |filename| File.exists?(filename) }
      end

      if config && File.exists?(config)
        # rewrite options full path for config for later use
        @options[:config] = config

        # load options from the config file, overwriting hard-coded defaults
        config_contents = YAML::load(File.open(config))
        configuration.merge!(config_contents.symbolize_keys!) if config_contents && config_contents.is_a?(Hash)
      else
        # user specified a config file?, no error if user did not specify config file
        raise "config file not found" if @options[:config]
      end

      # the command line options override options read from the config file
      @options = configuration[:options].merge!(@options)
      @options.symbolize_keys!

      # repos hash
      @options[:repos] = configuration[:repos].recursively_symbolize_keys! if configuration[:repos]

    end

  end

end

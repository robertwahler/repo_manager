require 'configatron'

module Repoman

  class Configure

    def initialize(working_dir, options={})
      @working_dir = working_dir
      @options = options
      configure(options)
    end

    def options
      @options
    end

  private

    # read options for YAML config with ERB processing and initialize configatron
    def configure(options)
      # set configatron defaults
      configatron.options.set_default(:verbose, false)
      configatron.options.set_default(:coloring, true)
      configatron.options.set_default(:short, false)
      configatron.options.set_default(:unmodified, 'HIDE')


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
        # load configatron options from the config file
        configatron.configure_from_yaml(config)
      else
        # user specified a config file?, no error if user did not specify config file
        raise "config file not found" if @options[:config]
      end

      # set options from config file unless already set via command line
      @options[:verbose] = configatron.options.verbose unless @options.include?(:verbose)
      @options[:coloring] = configatron.options.coloring unless @options.include?(:coloring)
      @options[:short] = configatron.options.short unless @options.include?(:short)
      @options[:unmodified] = configatron.options.unmodified unless @options.include?(:unmodified)

    end

  end

end

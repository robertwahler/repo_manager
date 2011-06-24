require 'configatron'

module Repoman

  class Settings

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

      # config file options may be blank, give them a default
      configatron.options.set_default(:verbose, false)
      configatron.options.set_default(:coloring, true)
      configatron.options.set_default(:short, false)
      configatron.options.set_default(:unmodified, 'HIDE')
      configatron.options.set_default(:match, 'ALL')

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

      # the command line options override options read from the config file
      @options[:verbose] = configatron.options.verbose unless @options.include?(:verbose)
      @options[:coloring] = configatron.options.coloring unless @options.include?(:coloring)
      @options[:short] = configatron.options.short unless @options.include?(:short)
      @options[:unmodified] = configatron.options.unmodified unless @options.include?(:unmodified)
      @options[:match] = configatron.options.match unless @options.include?(:match)

    end

  end

end

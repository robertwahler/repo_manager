require 'configatron'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module BasicApp
  class App

    def initialize(base_dir, options={})
      @base_dir = base_dir
      @options = options
      if @options[:verbose]
        puts "base_dir: #{@base_dir}".cyan
        puts "options: #{@options.inspect}".cyan
      end
      configure(options)
    end

    def run(action)
      begin
        puts "basic_app run action: #{action}".cyan if @options[:verbose]
        result = send(action)
        exit(result ? 0 : 1)
      rescue SystemExit => e
        # This is the normal exit point, exit code from the send result
        # or exit from another point in the system
        puts "basic_app run system exit: #{e}, status code: #{e.status}".green if @options[:verbose]
        exit(e.status)
      rescue Exception => e
        STDERR.puts("Basic_app command failed, error(s) follow:")
        STDERR.puts("#{e.message}".red)
        STDERR.puts(e.backtrace.join("\n")) if @options[:verbose]
        exit(1)
      end
    end

    #
    # Application commands
    #
    
  private

    # read options for YAML config with ERB processing and initialize configatron
    def configure(options)
      config = @options[:config]
      config = File.join(@base_dir, 'basic_app.conf') unless config
      if File.exists?(config)
        # load configatron options from the config file
        puts "loading config file: #{config}".cyan if @options[:verbose]
        configatron.configure_from_yaml(config)
      else
        # user specified a config file?
        raise "config file not found" if @options[:config]
        # no error if user did not specify config file
        puts "#{config} not found".yellow if @options[:verbose]
      end
      
      # 
      # set defaults, these will NOT override setting read from yaml
      #

    end

  end
end

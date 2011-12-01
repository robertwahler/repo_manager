####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
module BasicApp

  # An abstract superclass for basic action functionality
  class BaseAction
    include BasicApp::Assets

    # main configuration hash
    attr_reader :configuration

    # options hash, read from configuration hash
    attr_reader :options

    # args as passed on command line
    attr_reader :args

    # filename to template for rendering
    attr_accessor :template

    # filename to write output
    attr_accessor :output

    def initialize(args=[], configuration={})
      @configuration = configuration
      @options = configuration[:options] || {}
      @args = args
    end

    # Parse generic action options for all decendant actions
    #
    # @return [OptionParser] for use by decendant actions
    def parse_options
      logger.debug "base_action parsing args: #{args.join(' ')}"

      option_parser = OptionParser.new do |opts|
        opts.banner = help + "\n\nOptions:"

        opts.on("--template [NAME]", "Use a template to render output. (default=default.slim)") do |t|
          options[:template] = template.nil? ? "default.slim" : t
          @template = options[:template]
        end

        opts.on("--output FILENAME", "Render output directly to a file") do |f|
          options[:output] = f
          @output = options[:output]
        end

      end

      option_parser
    end

    def execute
      parse_options
      process
    end

    # handle "assets to items" transformations, if any, and write to output
    def process
      write_to_output(render)
    end

    # TODO: add exception handler and pass return values
    def write_to_output(content)
      if output
        logger.debug "base_action writing to : #{output}"
        File.open(output, 'wb') {|f| f.write(content) }
      else
        logger.debug "base_action writing to STDOUT"
        puts content
      end
      return 0
    end

    # assets will be passed these options
    def asset_options
      {}
    end

    # items to be rendered, defaults to assets
    #
    # @return [Array] of items to be rendered
    def items
      assets(asset_options)
    end

    # Render items result to a string
    #
    # @return [String] suitable for displaying on STDOUT or writing to a file
    def render
      logger.debug "base_action rendering"
      result = ""
      if template
        logger.debug "base_action rendering with template : #{template}"
        view = AppView.new(items)
        view.template = template
        result = view.render
      else
        items.each do |item|
          result += item.name.green + ":\n"
          if item.respond_to?(:attributes)
            attributes = item.attributes.dup
            result += attributes.to_yaml.gsub(/\s+$/, '') # strip trailing whitespace from YAML
            result += "\n"
          end
        end
      end
      result
    end

    # Convert method comments block to help text
    #
    # @return [String] suitable for displaying on STDOUT
    def help(help_options={})
      comment_starting_with = help_options[:comment_starting_with] || ""
      located_in_file = help_options[:located_in_file] || __FILE__
      text = File.read(located_in_file)

      result = text.match(/(^\s*#\s*#{comment_starting_with}.*)^\s*class .* AppAction/m)
      result = $1
      result = result.gsub(/ @example/, '')
      result = result.gsub(/ @return \[Number\]/, ' Exit code:')
      result = result.gsub(/ @return .*/, '')
      result = result.gsub(/ @see .*$/, '')

      # strip the leading whitespace, the '#' and space
      result = result.gsub(/^\s*# ?/, '')

      # strip surrounding whitespace
      result.strip

      if configuration[:general_options_summary]
        result += "\n"
        result += "General options:\n"
        result += configuration[:general_options_summary].to_s
      end

      result
    end

  end
end

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

    attr_reader :options

    attr_reader :configuration

    attr_reader :args

    def initialize(args=[], configuration={})
      @configuration = configuration
      @options = configuration[:options] || {}
      @args = args
    end

    # Parse generic action options for all decendant actions
    #
    # @return [OptionParser] for use by decendant actions
    def parse_options
      option_parser = OptionParser.new do |opts|
        opts.banner = help + "\n\nOptions:"

        opts.on("--template [NAME]", "Use a template to render output. (Default=default.slim)") do |template|
          options[:template] = template.nil? ? "DEFAULT" : template
        end

        opts.on("--output FILENAME", "Render output directly to a file") do |filename|
          options[:output] = filename
        end

      end
      option_parser
    end

    def execute
      parse_options
      output = render

      filename = options[:output]
      if filename
        File.open(filename, 'wb') {|f| f.write(output) }
      else
        puts output
      end
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
      template = options[:template]
      result = ""
      if template
        view = AppView.new(items)
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

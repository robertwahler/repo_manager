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

    def parse_options
      # @abstract
    end

    # @abstract
    def execute
      parse_options
      render
    end

    def asset_options
      {}
    end

    def render
      assets(asset_options).each do |asset|
        attributes = asset.attributes.dup
        print asset.name.green
        puts ":"
        # strip trailing whitespace from YAML
        puts attributes.to_yaml.gsub(/\s+$/, '')
        puts ""
      end
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

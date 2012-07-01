####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################

require 'basic_app/assets/asset_manager'

module BasicApp

  # An abstract superclass for basic action functionality
  class BaseAction
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

    # numeric exit code set from return of process method
    attr_reader :exit_code

    # bin wrapper option parser object
    attr_accessor :option_parser

    def initialize(args=[], configuration={})
      @configuration = configuration
      @options = configuration[:options] || {}
      @args = args
      logger.debug "initialize with args: #{args.inspect}"
    end

    # Parse generic action options for all decendant actions
    #
    # @return [OptionParser] for use by decendant actions
    def parse_options(parser_configuration = {})
      raise_on_invalid_option = parser_configuration.has_key?(:raise_on_invalid_option) ? parser_configuration[:raise_on_invalid_option] : true
      parse_base_options = parser_configuration.has_key?(:parse_base_options) ? parser_configuration[:parse_base_options] : true
      logger.debug "base_action parsing args: #{args.inspect}, raise_on_invalid_option: #{raise_on_invalid_option}, parse_base_options: #{parse_base_options}"

      @option_parser ||= OptionParser.new

      option_parser.banner = help + "\n\nOptions:"

      if parse_base_options
        option_parser.on("--template [NAME]", "Use a template to render output. (default=default.slim)") do |t|
          options[:template] = t.nil? ? "default.slim" : t
          @template = options[:template]
        end

        option_parser.on("--output FILENAME", "Render output directly to a file") do |f|
          options[:output] = f
          @output = options[:output]
        end

        option_parser.on("--force", "Overwrite file output without prompting") do |f|
          options[:force] = f
        end

        option_parser.on("--asset a1,a2,a3", "--filter a1,a2,a3", Array, "List of regex asset name filters") do |list|
          options[:filter] = list
        end

        # NOTE: OptionParser will add short options, there is no way to stop '-m' from being the same as '--match'
        option_parser.on("--match [MODE]", "Asset filter match mode.  MODE=ALL (default), FIRST, EXACT, or ONE (fails if more than 1 match)") do |m|
          options[:match] = m || "ALL"
          options[:match].upcase!
          unless ["ALL", "FIRST", "EXACT", "ONE"].include?(options[:match])
            puts "invalid match mode option: #{options[:match]}"
            exit 1
          end
        end
      end

      # allow decendants to add options
      yield option_parser if block_given?

      # reprocess args for known options, see binary wrapper for first pass
      # (first pass doesn't know about action specific options), find all
      # action options that may come after the action/subcommand (options
      # before subcommand have already been processed) and its args
      logger.debug "(BaseAction) args before reprocessing: #{args.inspect}"
      begin
        option_parser.order!(args)
      rescue OptionParser::InvalidOption => e
        if raise_on_invalid_option
          puts "option error: #{e}"
          puts option_parser
          exit 1
        else
          # parse and consume until we hit an unknown option (not arg), put it back so it
          # can be shifted into the new array
          e.recover(args)
        end
      end
      logger.debug "(BaseAction) args before unknown collection: #{args.inspect}"

      unknown_args = []
      while unknown_arg = args.shift
        logger.debug "(BaseAction) unknown_arg: #{unknown_arg.inspect}"
        unknown_args << unknown_arg
        begin
          # consume options and stop at an arg
          option_parser.order!(args)
        rescue OptionParser::InvalidOption => e
          if raise_on_invalid_option
            puts "option error: #{e}"
            puts option_parser
            exit 1
          else
            # parse and consume until we hit an unknown option (not arg), put it back so it
            # can be shifted into the new array
            e.recover(args)
          end
        end
      end
      logger.debug "(BaseAction) args after unknown collection: #{args.inspect}"

      @args = unknown_args.dup
      logger.debug "(BaseAction) args after reprocessing: #{args.inspect}"

      option_parser
    end

    def execute
      before_execute
      parse_options
      @exit_code = process
      after_execute
      @exit_code
    end

    # handle "assets to items" transformations, if any, and write to output
    def process
      write_to_output(render)
    end

    # TODO: add exception handler and pass return values
    def write_to_output(content)
      if output
        logger.debug "write_to_output called with output : #{output}"
        if overwrite_output?
          logger.debug "writing output to : #{output}"
          File.open(output, 'wb') {|f| f.write(content) }
        else
          logger.info "existing file not overwritten.  To overwrite automatically, use the '--force' option."
        end
      else
        logger.debug "base_action writing to STDOUT"
        print content
      end
      return 0
    end

    # TODO: create items/app_item class with at least the 'name' accessor
    #
    # assets: raw configuration handling system for items
    def assets
      return @assets if @assets
      @assets = AssetManager.new(configuration).assets(asset_options)
    end

    # used by
    #   * asset factory to create assets
    #   * asset configuration to build attributes_key
    #   * asset configuration to determine the default asset configuration file name
    #
    # @return [Symbol] asset type
    def asset_type
      :app_asset
    end

    # used for
    #   * attributes_key in configuration files
    #   * folder name to asset configuration folders
    #
    # @return [Symbol] asset key
    def asset_key
      "#{asset_type.to_s}s".to_sym
    end

    # asset options separated from assets to make it easier to override assets
    def asset_options
      # include all base action options
      result = options.dup

      # anything left on the command line should be filters as all options have
      # been consumed, for pass through options, filters must be ignored by overwritting them
      filters = args.dup
      filters += result[:filter] if result[:filter]
      result = result.merge(:filter => filters) unless filters.empty?

      # asset type to create
      type = result[:type] || asset_type
      result = result.merge(:type => type)

      # optional key: :assets_folder, absolute path or relative to config file if :base_folder is specified
      result = result.merge(:asset_key => asset_key)
      result = result.merge(:assets_folder => configuration[:folders][asset_key]) if configuration[:folders]

      # optional key: :base_folder is the folder that contains the main config file
      result = result.merge(:base_folder => File.dirname(configuration[:configuration_filename])) if configuration[:configuration_filename]

      result
    end

    # items to be rendered, defaults to assets, override to suit
    #
    # @return [Array] of items to be rendered
    def items
      assets
    end

    # Render items result to a string
    #
    # @return [String] suitable for displaying on STDOUT or writing to a file
    def render(view_options=configuration)
      logger.debug "base_action rendering"
      result = ""
      if template
        logger.debug "base_action rendering with template : #{template}"
        view = AppView.new(items, view_options)
        view.template = template
        result = view.render
      else
        items.each_with_index do |item, index|
          result += "\n" unless index == 0
          result += item.name.green + ":\n"
          if item.respond_to?(:attributes)
            attributes = item.attributes.dup
            result += attributes.recursively_stringify_keys!.to_conf.gsub(/\s+$/, '') # strip trailing whitespace from YAML
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
    end

    # @return [Boolean] true if output doesn't exist or it is OK to overwrite
    def overwrite_output?
      return true unless File.exists?(output)

      if options[:force]
        logger.debug "overwriting output with --force option"
        return true
      end

      unless STDOUT.isatty
        logger.debug "TTY not detected, skipping overwrite prompt"
        return false
      end

      result = false
      print "File '#{output}' exists. Would you like overwrite? [y/n]: "
      case gets.strip
        when 'Y', 'y', 'yes'
          logger.debug "user answered yes to overwrite prompt"
          result = true
        else
          logger.debug "user answered no to overwrite prompt"
      end

      result
    end

    # callbacks
    def before_execute
      logger.debug "callback: before_execute"
    end

    def after_execute
      logger.debug "callback: after_execute"
    end

  end
end

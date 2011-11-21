require 'optparse'

module BasicApp

  # @group CLI actions
  #
  # List assets to the STDOUT
  #
  # @example Usage: basic_app list
  #
  # @example Filter by tags and sort by acquired date
  #
  #  basic_app list --tags=adventure,favorites --sort=ACQUIRED
  #
  # @example HTML output to a file
  #
  #  basic_app list --format=HTML >> tmp/aruba/index.html
  #
  # @return [Number] 0 if successful
  class ListAction < AppAction

    def execute

      OptionParser.new do |opts|
        opts.banner = help + "\n\nOptions:"

        opts.on("--list MODE", "Listing mode.  ALL, NAME") do |u|
          options[:list] = u
          options[:list].upcase!
          unless ["ALL", "NAME"].include?(options[:list])
            raise "invalid list mode '#{options[:list]}' for '--list' option"
          end
        end

        opts.on("--type ASSET_TYPE", "Asset type to list:  APP_ASSET (default)") do |t|
          options[:type] = t
          options[:type].upcase!
          unless ["APP_ASSET"].include?(options[:type])
            raise "unknown asset type '#{options[:type]}' for '--type' option"
          end
        end

        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          puts "option error: #{e}"
          puts opts
          exit 1
        end
      end

      list_mode = options[:list] || 'ALL'
      asset_options = {:type => :app_asset}
      asset_options.merge!(:type => options[:type].downcase) if options[:type]

      assets(asset_options).each do |asset|
        case list_mode
          when 'NAME'
            puts asset.name.green
          else
            attributes = asset.attributes.dup
            print asset.name.green
            puts ":"
            # strip trailing whitespace from YAML
            puts attributes.to_yaml.gsub(/\s+$/, '')
            puts ""
        end
      end

    end

    def help
      super :comment_starting_with => "List assets", :located_in_file => __FILE__
    end

  end

end

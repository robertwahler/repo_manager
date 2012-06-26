require 'optparse'

module BasicApp

  # @group CLI actions
  #
  # List assets to the screen or file with or without templates
  # using regular expression (regex) filtering.
  #
  # @example Usage: basic_app list
  #
  #     basic_app list
  #     basic_app list --list=NAME
  #     basic_app list --type=asset_type
  #     basic_app list --template ~/templates/myTemplate.slim
  #
  # @example Asset regex filtering:
  #
  #     basic_app list --filter=ass.t1,as.et2
  #
  # @example Equivalent asset filtering:
  #
  #     basic_app list --filter=asset1,asset2
  #     basic_app list --asset=asset1,asset2
  #     basic_app list asset1 asset2
  #
  # @example Equivalent usage, file writing:
  #
  #    basic_app list --template=default.slim --output=tmp/aruba/index.html
  #    basic_app list --template=default.slim >> tmp/aruba/index.html
  #
  # @example return just the first matching asset
  #
  #     basic_app list --match=FIRST
  #
  # @example Fail out if more than one matching asset
  #
  #     basic_app list --match=ONE
  #
  # @example Disable regex filter matching
  #
  #     basic_app list --match=EXACT
  #
  # @example Future usage (not implemented):
  #
  #     basic_app list --tags=adventure,favorites --group_by=tags --sort=ACQUIRED
  #
  # @return [Number] 0 if successful
  class ListAction < AppAction

    # Add action specific options
    def parse_options
      super do |opts|

        opts.on("--list MODE", "Listing mode.  ALL, NAME, SHORT, PATH") do |u|
          options[:list] = u
          options[:list].upcase!
          unless ["ALL", "NAME", "SHORT", "PATH"].include?(options[:list])
            raise "invalid list mode '#{options[:list]}' for '--list' option"
          end
        end

        # Most decendants of BaseAction will only handle one type of asset, the
        # list action is unique in that you can specify the type of asset to list
        opts.on("--type ASSET_TYPE", "Asset type to list:  app_asset (default)") do |t|
          options[:type] = t
          unless ["app_asset"].include?(options[:type])
            raise "unknown asset type '#{options[:type]}' for '--type' option"
          end
        end

      end
    end

    def render(view_options=configuration)
      # templates override all other modes, if no mode specified, allow super to handle
      list_mode = options[:template] || options[:list]
      result = ""
      case list_mode
        when 'NAME'
          items.each do |item|
            result += "#{item.name.green}\n"
          end
        else
          result = super(view_options)
      end
      result
    end

    def help
      super :comment_starting_with => "List assets", :located_in_file => __FILE__
    end

  end
end

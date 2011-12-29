require 'optparse'

module Repoman

  # @group CLI actions
  #
  # List repository information contained in the configuration file to STDOUT.
  # The actual repositories are not validated.  The list command operates only
  # on the config file.
  #
  # @example Usage: repo list
  #
  #     repo list
  #     repo list --list=NAME
  #     repo list --type=asset_type
  #     repo list --template ~/templates/myTemplate.slim
  #
  # @example Asset regex filtering:
  #
  #     repo list --filter=ass.t1,as.et2
  #
  # @example Equivalent asset filtering:
  #
  #     repo list --filter=asset1,asset2
  #     repo list --asset=asset1,asset2
  #     repo list asset1 asset2
  #
  # @example Equivalent usage, file writing:
  #
  #    repo list --template=default.slim --output=tmp/aruba/index.html
  #    repo list --template=default.slim >> tmp/aruba/index.html
  #
  # @example return just the first matching asset
  #
  #     repo list --match=FIRST
  #
  # @example Fail out if more than one matching asset
  #
  #     repo list --match=ONE
  #
  # @example Disable regex filter matching
  #
  #     repo list --match=EXACT
  #
  # @example Create a Bash 'alias' named 'rcd' to chdir to the folder of the repo
  #
  #     function rcd(){ cd "$(repo --match=ONE --no-color path $@)"; }
  #
  #     rcd my_repo_name
  #
  # @example Repo versions of Bash's pushd and popd
  #
  #     function rpushd(){ pushd "$(repo path --match=ONE --no-color $@)"; }
  #     alias rpopd="popd"
  #
  #     rcd my_repo_name
  #
  # @return [Number] 0 if successful
  class ListAction < AppAction

    def parse_options
      opts = super

      opts.on("--list MODE", "Listing mode.  ALL, NAME") do |u|
        options[:list] = u
        options[:list].upcase!
        unless ["ALL", "NAME"].include?(options[:list])
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

      begin
        opts.parse!(args)
      rescue OptionParser::InvalidOption => e
        puts "option error: #{e}"
        puts opts
        exit 1
      end
    end

    def asset_options
      result = super
      result = result.merge(:type => :app_asset) unless options[:type]
      result
    end

    def render
      # templates override all other modes, if no mode specified, allow super to handle
      list_mode = options[:template] || options[:list]
      result = ""
      case list_mode
        when 'NAME'
          assets(asset_options).each do |asset|
            result += "#{asset.name.green}\n"
          end
        when 'SHORT'
          result += repo.name.green
          result += ": #{repo.path}\n"
        when 'PATH'
          result += "#{repo.path}\n"
        else
          result = super
      end
      result
    end

    def help
      super :comment_starting_with => "List assets", :located_in_file => __FILE__
    end

  end
end

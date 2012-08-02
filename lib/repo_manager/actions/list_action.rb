require 'optparse'
require 'repo_manager/actions/action_helper'

module RepoManager

  # @group CLI actions
  #
  # List assets to the screen or file with or without templates
  # using regular expression (regex) filtering.
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
  # @example Future usage (not implemented):
  #
  #     repo list --tags=adventure,favorites --group_by=tags --sort=ACQUIRED
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
    include RepoManager::ActionHelper

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

        opts.on("--short", "List summary status only, alias for '--list=SHORT'") do |s|
          options[:list] = 'SHORT'
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
        when 'SHORT'
          items.each do |item|
            result += item.name.green
            result += ": #{relative_path(item.path)}\n"
          end
        when 'PATH'
          items.each do |item|
            result += "#{item.path}\n"
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

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

      opts.on("--list MODE", "Listing mode.  ALL, NAME, SHORT, PATH") do |u|
        options[:list] = u
        options[:list].upcase!
        unless ["ALL", "NAME", "SHORT", "PATH"].include?(options[:list])
          raise "invalid list mode '#{options[:list]}' for '--list' option"
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

    def render
      # templates override all other modes, if no mode specified, allow super to handle
      list_mode = options[:template] || options[:list]
      result = ""
      case list_mode
        when 'NAME'
          items.each do |repo|
            result += "#{repo.name.green}\n"
          end
        when 'SHORT'
          items.each do |repo|
            result += repo.name.green
            result += ": #{repo.path}\n"
          end
        when 'PATH'
          items.each do |repo|
            result += "#{repo.path}\n"
          end
        else
          result = super
      end
      result
    end

    def help
      super :comment_starting_with => "List repo", :located_in_file => __FILE__
    end

  end
end

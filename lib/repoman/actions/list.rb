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
  #   repo list
  #   repo list --listing ALL
  #   repo list --listing SHORT
  #   repo list --listing=NAME
  #   repo list --listing=PATH
  #
  # @example Equivalent filtering
  #
  #   repo list --filter=test1
  #   repo list test1
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

    def execute

      OptionParser.new do |opts|
        opts.banner = help + "\n\nOptions:"
        opts.on("--listing MODE", "Listing format.  ALL, SHORT, NAME, PATH") do |u|
          options[:listing] = u
          options[:listing].upcase!
          unless ["ALL", "SHORT", "NAME", "PATH"].include?(options[:listing])
            raise "invalid lising mode '#{options[:listing]}' for '--listing' option"
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

      listing_mode = options[:listing] || 'ALL'
      filters = args.dup
      filters += options[:filter] if options[:filter]

      repos(filters).each do |repo|
        case listing_mode
          when 'SHORT'
            print repo.name.green
            puts ": #{repo.path}"
          when 'NAME'
            puts repo.name.green
          when 'PATH'
            puts repo.path
          else
            attributes = repo.attributes.dup
            base_dir = attributes.delete(:base_dir)
            name = attributes.delete(:name)
            print name.green
            puts ":"
            puts attributes.to_yaml
            puts ""
        end
      end
    end

    def help
      super :comment_starting_with => "List repository information", :located_in_file => __FILE__
    end

  end

end

require 'optparse'
require 'repoman/actions/action_helper'

module Repoman

  # @group CLI actions
  #
  # Native 'git' command pass-through
  #
  # @example Usage: repo [options] git args [options]
  #
  #   repo ls-files
  #   repo git ls-files
  #
  #   repo add .
  #   repo add . --filter=test
  #   repo git add . --filter=test
  #
  # @return [Numeric] pass through of 'git' result code
  class GitAction < AppAction
    include Repoman::ActionHelper

    # allow pass through of unknown options
    def parse_options(parser_configuration = {:raise_on_invalid_option => false})
      super parser_configuration
    end

    def asset_options
      result = super

      # to allow pass through options, argument based filters must be ignored,
      # delete the arg based filters and recreate from the --filter option
      result.delete(:filter)
      result = result.merge(:filter => options[:filter]) if options[:filter]

      result
    end

    def process
      logger.debug "process() args: #{args.inspect}"
      logger.debug "process() asset_options: #{asset_options.inspect}"

      # the first arg is optionally 'git'
      unless args.empty?
        args.shift if args[0] == 'git'
      else
        raise "no git command given" if args.empty?
      end

      command = args.shift
      st = 0
      result = 0
      output = ""

      unless configuration.commands.include?(command)
        raise "git command '#{command}' is not enabled, see #{configuration[:configuration_filename]}"
      end

      # args should not match a repo name
      if ((!args.empty?) && (!options[:filter]))
        repos.each do |repo|
          raise "repo name '#{repo.name}' cannot be used as a filter for git native commands, use --r, --repos, or --filter switches instead" if args.include?(repo.name)
        end
      end

      repos.each do |repo|
        begin
          st = repo.status.bitfield
        rescue InvalidRepositoryError => e
          st = 0 #Status::INVALID
        rescue NoSuchPathError => e
          st = Status::NOPATH
        end

        case st
          when (Status::NOPATH)
            output += repo.name.red
            output += ": #{relative_path(repo.path)}"
            output += " [no such path]\n"
          else
            git_output = ''
            begin
              git = Git::Lib.new(:working_directory => repo.path, :repository => File.join(repo.path, '.git'))
              git_output = git.native(command, args)
              result |= $?.exitstatus unless ($?.exitstatus == 0)
            rescue Git::CommandFailed => e
              result |= e.exitstatus
              git_output = e.error
            end
            if git_output != ''
              output += repo.name.green + "\n"
              output += git_output + "\n"
            end
        end
      end

      write_to_output(output)

      # numeric return
      result
    end

    def help
      super(:comment_starting_with => "Native 'git' command", :located_in_file => __FILE__) +
        "\n" +
        "\n" +
        "Git commands are whitelisted.  The following git commands enabled in #{configuration[:configuration_filename]}:\n" +
        "\n" +
        configuration.commands.join(',')
    end

  end
end

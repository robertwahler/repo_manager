require 'optparse'
require 'repoman/actions/action_helper'

module Repoman

  # @group CLI actions
  #
  # Show simplified summary status of repos. The exit code is a bitfield
  # that collects simplified status codes. The Repoman status simplifies
  # Git's porcelain output by combining Git status X and Y and boiling
  # down status returns to just five types,
  #
  #   M ? A D U
  #
  # From git 1.7+ documentation
  #
  #   X          Y     Meaning
  #   -------------------------------------------------
  #             [MD]   not updated
  #   M        [ MD]   updated in index
  #   A        [ MD]   added to index
  #   D        [ MD]   deleted from index
  #   R        [ MD]   renamed in index
  #   C        [ MD]   copied in index
  #   [MARC]           index and work tree matches
  #   [ MARC]     M    work tree changed since index
  #   [ MARC]     D    deleted in work tree
  #   -------------------------------------------------
  #   D           D    unmerged, both deleted
  #   A           U    unmerged, added by us
  #   U           D    unmerged, deleted by them
  #   U           A    unmerged, added by them
  #   D           U    unmerged, deleted by us
  #   A           A    unmerged, both added
  #   U           U    unmerged, both modified
  #   -------------------------------------------------
  #   ?           ?    untracked
  #   -------------------------------------------------
  #
  # @example Usage: repo status
  #
  #   repo status
  #   repo status --short
  #   repo status repo1 --unmodified DOTS
  #   repo status repo1 repo2 --unmodified DOTS
  #
  # @example Equivalent filtering
  #
  #   repo status --filter=test2 --unmodified DOTS
  #   repo status test2 --unmodified DOTS
  #
  # @example Alternatively, run the native git status command
  #
  #   repo git status
  #
  # @return [Number] bitfield with combined repo status
  #
  # @see Status bitfield return values
  class StatusAction < AppAction
    include Repoman::ActionHelper

    # Add action specific options
    def parse_options
      super do |opts|

        opts.on("-u", "--unmodified [MODE]", "Show unmodified repos.  MODE=SHOW (default), DOTS, or HIDE") do |u|
          options[:unmodified] = u || "SHOW"
          options[:unmodified].upcase!
        end

        opts.on("--short", "Summary status only, do not show individual file status") do |s|
          options[:short] = s
        end

      end
    end

    def process
      st = 0
      result = 0
      count_unmodified = 0
      need_lf = false
      output = ""
      unmodified_mode = options[:unmodified] || 'HIDE'

      repos.each do |repo|
        # M ? A D I X
        begin
          st = repo.status.bitfield
        rescue InvalidRepositoryError => e
          st = Status::INVALID # I
        rescue NoSuchPathError => e
          st = Status::NOPATH # X
        end

        result |= st unless (st == 0)

        case st

          when Status::CLEAN
            count_unmodified += 1
            case unmodified_mode
              when "HIDE"
                # do nothing
              when "SHOW"
                output += "\t#{repo.name}\n"
              when "DOTS"
                output += ".".green
                need_lf = true
              else
                raise "invalid mode '#{unmodified_mode}' for '--unmodified' option"
            end

          when Status::NOPATH
            output += "\n" if need_lf
            output += "X\t#{repo.name}: #{relative_path(repo.path)}"
            output += " [no such path]".red + "\n"
            need_lf = false

          when Status::INVALID
            output += "\n" if need_lf
            output += "I\t#{repo.name}: #{relative_path(repo.path)}"
            output += " [not a valid repo]".red + "\n"
            need_lf = false

          else
            output += "\n" if need_lf

            # print M?ADU status letters
            output += (st & Status::CHANGED == Status::CHANGED) ? "M".red : " "
            output += (st & Status::UNTRACKED == Status::UNTRACKED) ? "?".blue.bold : " "
            output += (st & Status::ADDED == Status::ADDED) ? "A".green : " "
            output += (st & Status::DELETED == Status::DELETED) ? "D".yellow : " "
            output += (st & Status::UNMERGED == Status::UNMERGED) ? "U".red.bold : " "

            output += "\t#{repo.name}\n"
            need_lf = false

            unless options[:short]
              # modified (M.red)
              repo.status.changed.sort.each do |k, f|
                output += "\t  modified: #{f.path}".red + "\n"
              end

              # untracked (?.blue.bold)
              repo.status.untracked.sort.each do |k, f|
                output += "\t  untracked: #{f.path}".blue.bold + "\n"
              end

              # added (A.green)
              repo.status.added.sort.each do |k, f|
                output += "\t  added: #{f.path}".green + "\n"
              end

              # deleted (D.yellow)
              repo.status.deleted.sort.each do |k, f|
                output += "\t  deleted: #{f.path}".yellow + "\n"
              end

              # unmerged (U.red.bold)
              repo.status.unmerged.sort.each do |k, f|
                output += "\t  unmerged: #{f.path}".red.bold + "\n"
              end
            end
        end
        write_to_output(output)
        output = ""
      end

      output = "\n" if need_lf

      # summary
      output += "no modified repositories, all working folders are clean\n" if (count_unmodified == repos.size)

      write_to_output(output)

      # numeric return
      result
    end

    def help
      super :comment_starting_with => "Show simplified summary status", :located_in_file => __FILE__
    end

  end
end

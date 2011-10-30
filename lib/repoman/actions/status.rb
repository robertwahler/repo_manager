module Repoman

  # @group CLI actions
  #
  # Show simplified summary status of repos. The exit code is a bitfield that
  # collects simplified status codes.
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
  #
  class StatusAction < AppAction


    def execute
      OptionParser.new do |opts|

        help_text = help
        opts.banner = help_text + "\n\nOptions:"

        opts.on("-u", "--unmodified [MODE]", "Show unmodified repos.  MODE=SHOW (default), DOTS, or HIDE") do |u|
          @options[:unmodified] = u || "SHOW"
          @options[:unmodified].upcase!
        end
        opts.on("--short", "Summary status only, do not show individual file status") do |s|
          @options[:short] = s
        end

        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          puts "option error: #{e}"
          puts opts
          exit 1
        end
      end

      filters = args.dup
      filters += @options[:filter] if @options[:filter]

      st = 0
      result = 0
      count_unmodified = 0
      need_lf = false

      repos(filters).each do |repo|

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
            case @options[:unmodified]
              when "HIDE"
                # do nothing
              when "SHOW"
                puts "\t#{repo.name}"
              when "DOTS"
                print ".".green
                need_lf = true
              else
                raise "invalid mode '#{@options[:unmodified]}' for '--unmodified' option"
            end

          when Status::NOPATH
            puts "" if need_lf
            print "X\t#{repo.name}: #{repo.path}"
            puts " [no such path]".red
            need_lf = false

          when Status::INVALID
            puts "" if need_lf
            print "I\t#{repo.name}: #{repo.path}"
            puts " [not a valid repo]".red
            need_lf = false

          else
            puts "" if need_lf

            # print M?ADU status letters
            print (st & Status::CHANGED == Status::CHANGED) ? "M".red : " "
            print (st & Status::UNTRACKED == Status::UNTRACKED) ? "?".blue.bold : " "
            print (st & Status::ADDED == Status::ADDED) ? "A".green : " "
            print (st & Status::DELETED == Status::DELETED) ? "D".yellow : " "
            print (st & Status::UNMERGED == Status::UNMERGED) ? "U".red.bold : " "

            puts "\t#{repo.name}"
            need_lf = false

            unless @options[:short]
              # modified (M.red)
              repo.status.changed.sort.each do |k, f|
                puts "\t  modified: #{f.path}".red
              end

              # untracked (?.blue.bold)
              repo.status.untracked.sort.each do |k, f|
                puts "\t  untracked: #{f.path}".blue.bold
              end

              # added (A.green)
              repo.status.added.sort.each do |k, f|
                puts "\t  added: #{f.path}".green
              end

              # deleted (D.yellow)
              repo.status.deleted.sort.each do |k, f|
                puts "\t  deleted: #{f.path}".yellow
              end

              # unmerged (U.red.bold)
              repo.status.unmerged.sort.each do |k, f|
                puts "\t  unmerged: #{f.path}".red.bold
              end
            end
        end
      end

      puts "" if need_lf

      # summary
      puts "no modified repositories, all working folders are clean" if (count_unmodified == repos.size)

      # numeric return
      result
    end

    def help
      super :comment_starting_with => "Show simplified summary status", :located_in_file => __FILE__
    end

  end
end

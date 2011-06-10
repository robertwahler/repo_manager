require 'git'

module Repoman

  # Simplified version of ruby-git's class that uses Git porcelain commands.
  #
  # Porcelain commands are useful since they handle ignored files and ignore
  # non-commitable changes.  Speed is not a big concern.  There is only one
  # call needed to the Git binary. No plumbing commands are used.
  class Status
    include Enumerable

    # repo status unchanged/clean
    CLEAN = 0

    # bitfields for status
    NOPATH = 1
    INVALID = 2
    CHANGED = 4
    ADDED =  8
    DELETED =  16
    UNTRACKED =  32

    attr_reader :files

    def initialize(repo)
      @files = {}
      @repo = repo
      construct_status
    end

    # @return [Numeric] 0 if CLEAN or bitfield with status: CHANGED | UNTRACKED | ADDED | DELETED
    def bitfield
      # M ? A D
      (changed? ? CHANGED : 0) |
      (untracked? ? UNTRACKED : 0) |
      (added? ? ADDED : 0) |
      (deleted? ? DELETED : 0)
    end

    def changed
      @files.select { |k, f| f.type == 'M' }
    end

    def added
      @files.select { |k, f| f.type == 'A' }
    end

    def deleted
      @files.select { |k, f| f.type == 'D' }
    end

    def untracked
      @files.select { |k, f| f.type == '?' }
    end

    # @return [Boolean] false unless a file has been modified/changed
    def changed?
      !changed.empty?
    end

    # @return [Boolean] false unless a file has added
    def added?
      !added.empty?
    end

    # @return [Boolean] false unless a file has been deleted
    def deleted?
      !deleted.empty?
    end

    # @return [Boolean] false unless there is a new/untracked file
    def untracked?
      !untracked.empty?
    end

    def [](file)
      @files[file]
    end

    def each
      @files.each do |k, file|
        yield file
      end
    end

    class StatusFile
      attr_accessor :path, :type

      def initialize(hash)
        @path = hash[:path]
        @type = hash[:type]
      end
    end

    private

      def construct_status
        # XY filename
        # Y = working tree
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
        #
        # simplify:
        #   combine X and Y and boil down status returns to just four types,
        #   M ? A D
        #
        # example output:
        # output = [" M .gitignore", "R  testing s.txt", "test space.txt", "?? new_file1.txt"]
        output = @repo.lib.native('status', ['--porcelain', '-z']).split("\000")
        while line = output.shift
          file_hash = nil
          st, filename = line.split(" ")

          case st
            when /\?/
              file_hash = {:type => '?', :path => filename}
            when /R/
              file_hash = {:type => 'A', :path => filename}
              # renamed files 'to -> from', 'from' will be on the next line,
              # shift it off as we don't track this
              output.shift
            when /A/
              file_hash = {:type => 'A', :path => filename}
            when /M/
              file_hash = {:type => 'M', :path => filename}
            when /D/
              file_hash = {:type => 'D', :path => filename}
            else
              raise "fatal error: unknown status condition: '#{st}'"
          end

          @files[filename] = StatusFile.new(file_hash) if (file_hash && filename)
        end
      end

  end
end

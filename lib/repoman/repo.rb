require 'grit'

module Repoman

  # wrapper class for a source code repository
  class Repo

    # repo status unchanged/clean
    CLEAN = 0
    NOPATH = 1
    INVALID = 2

    # bitfields for status
    CHANGED = 4 #1
    ADDED =  8 #2
    DELETED =  16 #4
    UNTRACKED =  32 #8

    attr_accessor :name
    attr_accessor :path
    attr_reader :base_dir

    def initialize(name, attributes={})
      @name = name
      @path = attributes[:path] || name
      @base_dir = attributes[:base_dir]
    end

    # @return [Numeric] 0 if CLEAN or bitfield with status: CHANGED | UNTRACKED | ADDED | DELETED
    def status
      begin
        # M U A D I X
        (changed? ? CHANGED : 0) |
        (untracked? ? UNTRACKED : 0) |
        (added? ? ADDED : 0) |
        (deleted? ? DELETED : 0)
      rescue Grit::InvalidGitRepositoryError => e
        # I
        INVALID
      rescue Grit::NoSuchPathError => e
        # X
        NOPATH
      end
    end

    # @return [Boolean] false unless a file has been modified/changed
    def changed?
      !repo.status.changed.empty?
    end

    # @return [Boolean] false unless a file has added
    def added?
      !repo.status.added.empty?
    end

    # @return [Boolean] false unless a file has been deleted
    def deleted?
      !repo.status.deleted.empty?
    end

    # @return [Boolean] false unless there is a new/untracked file
    def untracked?
      !repo.status.untracked.empty?
    end

    # @return [Array] of changed/modified files
    def changed
      repo.status.changed
    end

    # @return [Array] of added files
    def added
      repo.status.added
    end

    # @return [Array] of deleted files
    def deleted
      repo.status.deleted
    end

    # @return [Array] of new/untracked files
    def untracked
      repo.status.untracked
    end

  private

    def repo
      return @repo if @repo
      @repo = Grit::Repo.new(fullpath)
    end

    def in_repo_dir(&block)
      Dir.chdir(fullpath, &block)
    end

    def fullpath
      if absolute_path?(path)
        path
      else
        File.expand_path(path, @base_dir)
      end
    end

    # Test if root dir (T/F)
    #
    # @param [String] dir directory to test
    #
    # @return [Boolean] true if dir is root directory
    def root_dir?(dir)
      if WINDOWS
        dir == "/" || dir == "\\" || dir =~ %r{\A[a-zA-Z]+:(\\|/)\Z}
      else
        dir == "/"
      end
    end

    # Test if absolute path (T/F)
    #
    # @param [String] dir path to test
    #
    # @return [Boolean] true if dir is an absolute path
    def absolute_path?(dir)
      if WINDOWS
        dir =~ %r{\A([a-zA-Z]+:)?(/|\\)}
      else
        dir =~ %r{\A/}
      end
    end

  end

end

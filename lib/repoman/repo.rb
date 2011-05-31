require 'grit'

module Repoman

  # wrapper class for a source code repository
  class Repo

    # bitfields for status
    CLEAN = 0
    CHANGED = 1
    ADDED =  2
    DELETED =  4
    UNTRACKED =  8

    attr_accessor :name
    attr_accessor :path

    def initialize(base_dir, path, name, options={})
      @base_dir = base_dir
      @path = path
      @name = name
      @options = options
      if @options[:verbose]
        puts "Repo initialize".cyan
        puts "@base_dir: #{@base_dir}".cyan
        puts "@path: #{@path}".cyan
        puts "@name: #{@name}".cyan
        puts "@options: #{@options.inspect}".cyan
      end
    end

    # Debugging information
    #
    # @return [String]
    def inspect
      "name: #{name}\npath #"
    end

    def status
      changed? ? CHANGED : 0
    end

    # @return [Boolean] false unless a file has been modified/changed
    def changed?
      !repo.status.changed.empty?
    end

    # @return [Array] of changed/modified files
    def changed
      repo.status.changed
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

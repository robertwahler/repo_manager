require 'grit'
require 'pathname'

module Repoman

  # wrapper class for a source code repository
  class Repo

    attr_reader :name
    attr_reader :path
    attr_reader :base_dir
    attr_reader :attributes

    def initialize(path, attributes={})
      @attributes = attributes
      @path = path || @attributes[:path] || @attributes[:name]
      raise ArgumentError("path must be specified or included in attributes hash") unless @path

      @name = @attributes[:name] || Pathname.new(@path).basename
      @base_dir = @attributes[:base_dir]

      # normalize attributes hash
      @attributes = @attributes.merge(:path => @path)
      @attributes = @attributes.merge(:name => @name)
    end

    def status
      @status ||= Repoman::Status.new(repo)
    end

  private

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

    def repo
      return @repo if @repo
      raise NoSuchPathError unless File.exists?(fullpath)

      git_folder_path = File.join(fullpath, '.git')
      raise InvalidRepositoryError unless File.exists?(git_folder_path)

      @repo = Grit::Repo.new(fullpath)
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

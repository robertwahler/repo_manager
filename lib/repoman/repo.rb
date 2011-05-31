require 'grit'

module Repoman

  # wrapper class for a source code repository
  class Repo

    attr_accessor :name
    attr_accessor :path

    def initialize(base_dir, path, name, options={})
      @base_dir = base_dir
      @path = path
      @name = name
      @options = options
    end

    # Debugging information
    #
    # @return [String]
    def inspect
      "name: #{name}\npath #"
    end

    def status
      in_repo_dir do
        puts repo.status
      end
      exit(0)
    end

  private

    def repo
      return @repo if @repo
      in_repo_dir do
        @repo = Grit::Repo.new(fullpath)
      end
    end

    def in_repo_dir(&block)
      Dir.chdir(fullpath, &block)
    end

    def fullpath
      #TODO: check path, if absolute, don't join with base_dir
      File.join(@base_dir, path)
    end

  end

end

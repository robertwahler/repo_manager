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
      "name: #{name}\npath #{path}"
    end

  end

end

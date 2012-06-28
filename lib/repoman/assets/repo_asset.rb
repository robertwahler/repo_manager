require 'pathname'

module Repoman

  # wrapper class for a source code repository configuration
  class RepoAsset < AppAsset

    # The asset_key, if defined, will be used as key to asset attributes when
    # loading from YAML, if not defined, the entire YAML file will load.
    #
    # Override in decendants.
    #
    # @ return [Symbol] or nil
    def asset_key
      :repo
    end

    # path to working folder
    def path
      p = attributes[:path] || attributes[:name]
      raise ArgumentError("path must be specified or included in attributes hash") unless p
      p
    end
    def path=(value)
      attributes[:path] = value
    end

    def status
      @status ||= Repoman::Status.new(scm)
    end

    # version control system wrapper
    def scm
      return @scm if @scm
      raise NoSuchPathError unless File.exists?(fullpath)
      raise InvalidRepositoryError unless File.exists?(File.join(fullpath, '.git'))
      @scm = Git.open(fullpath)
    end

    def fullpath
      if Pathname.new(path).absolute?
        path
      else
        File.expand_path(path)
      end
    end

  end

end

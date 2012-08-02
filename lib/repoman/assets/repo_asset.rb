module RepoManager

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

    def status
      @status ||= RepoManager::Status.new(scm)
    end

    # version control system wrapper
    def scm
      return @scm if @scm
      raise NoSuchPathError unless File.exists?(path)
      raise InvalidRepositoryError unless File.exists?(File.join(path, '.git'))
      @scm = Git.open(path)
    end

  end

end

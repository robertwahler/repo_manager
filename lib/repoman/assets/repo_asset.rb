require 'pathname'

module Repoman

  # wrapper class for a source code repository configuration
  class RepoAsset < AppAsset

    # path to working folder
    def path
      p = attributes[:path] || attributes[:name]
      raise ArgumentError("path must be specified or included in attributes hash") unless p
      p
    end
    def path=(value)
      attributes[:path] = value
    end

    # TODO: base_dir is obsolete, remove getter and  setter, use configuration file location
    def base_dir
      attributes[:base_dir]
    end
    def base_dir=(value)
      attributes[:base_dir] = value
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
        File.expand_path(path, @base_dir)
      end
    end

  end

end

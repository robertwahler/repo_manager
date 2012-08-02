require 'git'

module RepoManager
  module RepoApi

    def repo_exists?(folder)
      File.exists?(File.join(current_dir, folder, '.git'))
    end

    def repo_init(folder)
      create_dir(folder) unless repo_exists?(folder)
      repo_path = fullpath(folder)
      Git.init(repo_path)
    end

    def repo_add_all(folder)
      repo_path = fullpath(folder)
      repo = Git.init(repo_path)
      in_path(repo_path) do
        repo.add('.').should be_true
      end
    end

    def repo_add_file(filename, folder)
      repo_path = fullpath(folder)
      repo = Git.init(repo_path)
      repo.add(filename).should be_true
    end

    def repo_commit_all(folder)
      repo_path = fullpath(folder)
      repo = Git.init(repo_path)
      repo.commit_all("cucumber commit").should be_true
    end

    def repo_file_exists?(folder, filename)
      File.exists?(File.join(current_dir, folder, filename))
    end

  end
end

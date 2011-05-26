require 'grit'
def in_path(path, &block)
  Dir.chdir(path, &block)
end

Given /^a repo named "([^"]*)"$/ do |repo_name|
  create_dir(repo_name)
  repo_path = File.join(current_dir, repo_name)
  repo = Grit::Repo.init(repo_path)

  # need some content
  create_file(File.join(repo_name, '.gitignore'), "")

  # relative paths for adding files
  in_path(repo_path) do
    repo.add '.gitignore'
  end

  # commit
  repo.commit_all("initial commit").should be_true

end

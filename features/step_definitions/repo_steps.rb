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

  # grit commands must be done in the repo working folder 
  in_path(repo_path) do
    repo.add '.gitignore'
    # commit
    repo.commit_all("initial commit").should be_true
  end

end

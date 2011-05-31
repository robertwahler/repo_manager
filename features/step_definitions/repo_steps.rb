require 'grit'
def in_path(path, &block)
  Dir.chdir(path, &block)
end

Given /^a repo named "([^"]*)" in folder "([^"]*)"$/ do |repo_name, folder|
  create_dir(folder)
  repo_path = File.join(current_dir, folder)
  repo = Grit::Repo.init(repo_path)

  # need some content
  create_file(File.join(folder, '.gitignore'), "")

  # grit commands must be done in the repo working folder
  in_path(repo_path) do
    repo.add '.gitignore'
    # commit
    repo.commit_all("initial commit").should be_true
  end

end

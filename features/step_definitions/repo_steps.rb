require 'grit'
require 'fileutils'

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

Given /^I add all to repo in folder "([^"]*)"$/ do |folder|
  repo_path = File.join(current_dir, folder)
  repo = Grit::Repo.init(repo_path)

  # grit commands must be done in the repo working folder
  in_path(repo_path) do
    repo.add('.').should be_true
  end
end

Given /^I add the file "([^"]*)" to repo in folder "([^"]*)"$/ do |filename, folder|
  repo_path = File.join(current_dir, folder)
  repo = Grit::Repo.init(repo_path)

  # grit commands must be done in the repo working folder
  in_path(repo_path) do
    repo.add(filename).should be_true
  end
end

Given /^I commit all to repo in folder "([^"]*)"$/ do |folder|
  repo_path = File.join(current_dir, folder)
  repo = Grit::Repo.init(repo_path)

  # grit commands must be done in the repo working folder
  in_path(repo_path) do
    # commit
    repo.commit_all("cucumber commit").should be_true
  end

end

Given /^I delete the file "([^"]*)" in folder "([^"]*)"$/ do |filename, folder|
  path = File.join(current_dir, folder)
  FileUtils.rm(File.join(path, filename))
end

Given /^I delete the file "([^"]*)"$/ do |filename|
  FileUtils.rm(File.join(current_dir, filename))
end


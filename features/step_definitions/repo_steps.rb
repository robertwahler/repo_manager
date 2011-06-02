require 'grit'
require 'fileutils'

def in_path(path, &block)
  Dir.chdir(path, &block)
end

def repo_exists?(folder)
  File.exists?(File.join(current_dir, folder, '.git'))
end

def repo_init(folder)
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

Given /^a repo in folder "([^"]*)"$/ do |folder|
  repo_init(folder)
end

Given /^a repo in folder "([^"]*)" with the following:$/ do |folder, table|
  repo_init(folder) unless repo_exists?(folder)

  table.hashes.each do |hash|
    filename = hash[:filename]
    status = hash[:status]
    content = hash[:content]

    status.split("").each do |st|
      case st
        when "U"
          create_file(File.join(folder, filename), content)
      end
    end

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


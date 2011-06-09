require 'git'
require 'fileutils'

def in_path(path, &block)
  Dir.chdir(path, &block)
end

def repo_exists?(folder)
  File.exists?(File.join(current_dir, folder, '.git'))
end

def repo_init(folder)
  create_dir(folder)
  repo_path = fullpath(folder)
  repo = Git.init(repo_path)
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

  # git commands must be done in the repo working folder
  #in_path(repo_path) do
    # commit
    repo.commit_all("cucumber commit").should be_true
  #end
end

def repo_file_exists?(folder, filename)
  File.exists?(File.join(current_dir, folder, filename))
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
        when "?"
          create_file(File.join(folder, filename), content)
        when "A"
          create_file(File.join(folder, filename), content)
          repo_add_file(filename, folder)
        when "M"
          raise "create file '#{filename}' before modifying it" unless repo_file_exists?(folder, filename)
          append_to_file(File.join(folder, filename), content)
        when "C"
          unless repo_file_exists?(folder, filename)
            create_file(File.join(folder, filename), content)
          end
          repo_add_file(filename, folder)
          repo_commit_all(folder)
        when "D"
          unless repo_file_exists?(folder, filename)
            create_file(File.join(folder, filename), content)
            repo_add_file(filename, folder)
            repo_commit_all(folder)
          end
          FileUtils.rm(File.join(File.join(current_dir, folder), filename))
      end
    end

  end
end

Given /^I add all to repo in folder "([^"]*)"$/ do |folder|
  repo_add_all(folder)
end

Given /^I add the file "([^"]*)" to repo in folder "([^"]*)"$/ do |filename, folder|
  repo_add_file(filename, folder)
end

Given /^I commit all to repo in folder "([^"]*)"$/ do |folder|
  repo_commit_all(folder)
end

Given /^I delete the file "([^"]*)" in folder "([^"]*)"$/ do |filename, folder|
  FileUtils.rm(File.join(File.join(current_dir, folder), filename))
end

Given /^I delete the file "([^"]*)"$/ do |filename|
  FileUtils.rm(File.join(current_dir, filename))
end

Given /^I delete the folder "([^"]*)"$/ do |folder|
  in_current_dir do
    FileUtils.rm_rf(folder)
  end
end

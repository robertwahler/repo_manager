require 'git'
require 'fileutils'

def in_path(path, &block)
  Dir.chdir(path, &block)
end

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

Given /^a repo in folder "([^"]*)"$/ do |folder|
  repo_init(folder)
end

Given /^(?:a|the) repo in folder "([^"]*)" has a remote named "([^"]*)" in folder "([^"]*)"$/ do |repo_folder, remote_name, remote_folder|
  repo_init(repo_folder)
  repo_path = fullpath(repo_folder)
  remote_path = fullpath(remote_folder)

  Dir.chdir repo_path do
    `git remote add origin #{remote_path}`
    raise "git remote add failed" unless $?.exitstatus == 0
    `git config branch.master.remote origin`
    raise "git config origin failed" unless $?.exitstatus == 0
    `git config branch.master.merge refs/heads/master`
    raise "git config refs failed" unless $?.exitstatus == 0
    `git clone --bare #{repo_path} #{remote_path}`
    raise "git clone failed" unless $?.exitstatus == 0
  end

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
          write_file(File.join(folder, filename), content)
        when "A"
          write_file(File.join(folder, filename), content)
          repo_add_file(filename, folder)
        when "M"
          raise "create file '#{filename}' before modifying it" unless repo_file_exists?(folder, filename)
          append_to_file(File.join(folder, filename), content)
        when "C"
          unless repo_file_exists?(folder, filename)
            write_file(File.join(folder, filename), content)
          end
          repo_add_file(filename, folder)
          repo_commit_all(folder)
        when "D"
          unless repo_file_exists?(folder, filename)
            write_file(File.join(folder, filename), content)
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

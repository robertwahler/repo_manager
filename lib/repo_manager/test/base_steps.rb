require 'fileutils'
require 'chronic'
require 'repo_manager/test/test_api'

World(RepoManager::TestApi)

# Given PENDING: some reason
Given /^PENDING/ do
  pending
end

Then /^its output should contain "([^"]*)"$/ do |expected|
  assert_partial_output(expected, output_from(@commands.last))
end

Then /^its output should not contain "([^"]*)"$/ do |expected|
  assert_no_partial_output(expected, output_from(@commands.last))
end

Then /^its output should contain:$/ do |expected|
  assert_partial_output(expected, output_from(@commands.last))
end

Then /^its output should not contain:$/ do |expected|
  assert_no_partial_output(expected, output_from(@commands.last))
end

# "the output should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
Then /^its output should match \/([^\/]*)\/$/ do |expected|
  assert_matching_output(expected, output_from(@commands.last))
end

Then /^its output should not match \/([^\/]*)\/$/ do |expected|
  output_from(@commands.last).should_not =~ /#{expected}/
end

Then /^its output should match:$/ do |expected|
  assert_matching_output(expected, output_from(@commands.last))
end

Then /^its output should not match:$/ do |expected|
  output_from(@commands.last).should_not =~ /#{expected}/
end

Then /^the normalized output should contain:$/ do |partial_output|
  str = process_regex_tokens(Regexp.escape(normalize(partial_output)))
  normalize(all_output).should =~ Regexp.compile(str)
end

Then /^the normalized output should not contain:$/ do |partial_output|
  str = process_regex_tokens(Regexp.escape(normalize(partial_output)))
  normalize(all_output).should_not =~ Regexp.compile(str)
end

Then /^the normalized output should contain exactly:$/ do |partial_output|
  normalize(all_output).should == normalize(partial_output)
end

Then /^the normalized output should match \/([^\/]*)\/$/ do |partial_output|
  normalize(all_output).should =~ /#{normalize(partial_output)}/
end

Then /^the normalized output should not match \/([^\/]*)\/$/ do |partial_output|
  normalize(all_output).should_not =~ /#{normalize(partial_output)}/
end

Then /^the normalized output should match:$/ do |partial_output|
  normalize(all_output).should =~ /#{normalize(partial_output)}/m
end

Then /^the normalized output should not match:$/ do |partial_output|
  normalize(all_output).should_not =~ /#{normalize(partial_output)}/m
end

Then /^the file "([^"]*)" should contain:$/ do |file, partial_content|
  process_and_check_file_content(fullpath(file), partial_content, true)
end

Then /^the file "([^"]*)" should not contain:$/ do |file, partial_content|
  process_and_check_file_content(fullpath(file), partial_content, false)
end

Then /^the file "([^"]*)" should match:$/ do |file, partial_content|
  check_file_content(fullpath(file),/#{partial_content}/, true)
end

Then /^the file "([^"]*)" should not match:$/ do |file, partial_content|
  check_file_content(fullpath(file),/#{partial_content}/, false)
end

Then /^the file "([^"]*)", within (\d+) seconds, should contain:$/ do |file, seconds, partial_content|
  seconds = seconds.to_i

  lambda {

    timeout(seconds) do
      begin
        sleep 0.2 unless (seconds == 0)
      end until (seconds == 0 || File.exists?(fullpath(file)))
    end

  }.should_not raise_exception

  process_and_check_file_content(fullpath(file), partial_content, true)
end

Given /^the fixture "([^"]*)" is copied to "([^"]*)"$/ do |source, destination|
  in_current_dir do
    source = File.join("../../spec/fixtures/", source)
    _mkdir(File.dirname(destination))
    FileUtils.cp(source, destination)
  end
end

# | filename   | mtime | content |
Given /^the folder "([^"]*)" with the following files:$/ do |folder, table|
  create_dir(folder) unless File.exists?(File.join(current_dir, folder))
  table.hashes.each do |hash|
    filename = hash[:filename]
    content = hash[:content]
    filename = File.join(folder,filename)
    mtime = hash[:mtime] ? Chronic.parse(hash[:mtime]) : Time.now
    write_file(filename, content)
    File.utime(mtime, mtime, fullpath(filename))
  end
end

# | filename   | mtime | content |
Given /^the folder "([^"]*)" with the following binary files:$/ do |folder, table|
  create_dir(folder) unless File.exists?(File.join(current_dir, folder))
  table.hashes.each do |hash|
    filename = hash[:filename]
    filename = File.join(folder,filename)
    mtime = hash[:mtime] ? Chronic.parse(hash[:mtime]) : Time.now
    filesize = hash[:size] || 10
    write_fixed_size_file(filename, filesize.to_i)
    File.utime(mtime, mtime, fullpath(filename))
  end
end

Given /^the following empty files:$/ do |files|
  files.raw.map do |file_row|
    write_file(file_row[0], '')
  end
end

Given /^a (\d+) byte file named "([^"]*)"$/ do |file_size, file_name|
  write_fixed_size_file(file_name, file_size.to_i)
end

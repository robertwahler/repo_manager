def expand_tabs(data, indent=8)
  data.gsub(/([^\t\n]*)\t/) {
    $1 + " " * (indent - ($1.size % indent))
  }
end

def normalize(str)
  # convert/normalize DOS CRLF endings
  str.gsub!(/\r\n/, "\n") if str.match("\r\n")
  if str.match("\t")
    str = expand_tabs(str)
  end
  str
end

def process_and_check_file_content(file, partial_content, expect_match)
  str = process_regex_tokens(Regexp.escape(partial_content))
  content = IO.read(file)
  if expect_match
    content.should =~ Regexp.compile(str)
  else
    content.should_not =~ Regexp.compile(str)
  end
end

# substitute back in each tokenized regexp after all text has been escaped
def process_regex_tokens(str)
  str = str.gsub(/<%NUMBER[^%]*%>/, '\d+')
  str = str.gsub(/<%PK[^%]*%>/, '\d+')
  str = str.gsub(/<%STRING[^%]*%>/, '.+')
  str
end

# Given PENDING: some reason
Given /^PENDING/ do
  pending
end

Then /^its output should contain "([^"]*)"$/ do |expected|
  assert_partial_output(expected, output_from(@commands.last))
end

Then /^its output should contain:$/ do |expected|
  assert_partial_output(expected, output_from(@commands.last))
end

# "the output should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
Then /^the last output should match \/([^\/]*)\/$/ do |expected|
  assert_matching_output(expected, output_from(@commands.last))
end

Then /^the last output should match:$/ do |expected|
  assert_matching_output(expected, output_from(@commands.last))
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

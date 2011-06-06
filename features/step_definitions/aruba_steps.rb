
def normalize(str)
  # convert/normalize DOS CRLF endings
  str.gsub!(/\r\n/, "\n") if str.match("\r\n")
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

# substitute back in each tokenized regexp after all
# text has been escaped
def process_regex_tokens(str)
  str = str.gsub(/<%NUMBER[^%]*%>/, '\d+')
  str = str.gsub(/<%PK[^%]*%>/, '\d+')
  #str = str.gsub(/<%[ ]*STRING[^%]*%>/, '.+')
  str = str.gsub(/<%STRING[^%]*%>/, '.+')
  str
end

Then /^the normalized output should contain:$/ do |partial_output|
  unless @no_fail
    str = process_regex_tokens(Regexp.escape(normalize(partial_output)))
    normalize(combined_output).should =~ Regexp.compile(str)
  end
end

Then /^the normalized output should not contain:$/ do |partial_output|
  unless @no_fail
    str = process_regex_tokens(Regexp.escape(normalize(partial_output)))
    normalize(combined_output).should_not =~ Regexp.compile(str)
  end
end

Then /^the normalized output should contain exactly:$/ do |partial_output|
  unless @no_fail
    normalize(combined_output).should == normalize(partial_output)
  end
end

Then /^the normalized output should match \/([^\/]*)\/$/ do |partial_output|
  unless @no_fail
    normalize(combined_output).should =~ /#{normalize(partial_output)}/
  end
end

Then /^the normalized output should not match \/([^\/]*)\/$/ do |partial_output|
  unless @no_fail
    normalize(combined_output).should_not =~ /#{normalize(partial_output)}/
  end
end

Then /^the normalized output should match:$/ do |partial_output|
  unless @no_fail
    normalize(combined_output).should =~ /#{normalize(partial_output)}/m
  end
end

Then /^the normalized output should not match:$/ do |partial_output|
  unless @no_fail
    normalize(combined_output).should_not =~ /#{normalize(partial_output)}/m
  end
end

Then /^the file "([^"]*)" should contain:$/ do |file, partial_content|
  unless @no_fail
    process_and_check_file_content(fullpath(file), partial_content, true)
  end
end

Then /^the file "([^"]*)" should not contain:$/ do |file, partial_content|
  unless @no_fail
    process_and_check_file_content(fullpath(file), partial_content, false)
  end
end

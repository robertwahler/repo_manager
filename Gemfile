source "http://rubygems.org"

# Specify your gem's dependencies in the .gemspec file
gemspec

# Linux only supplement to .gemspec
group :development do
  gem "libnotify" if RUBY_PLATFORM.downcase.include?("linux")
end

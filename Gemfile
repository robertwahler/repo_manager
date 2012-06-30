source "http://rubygems.org"

# Specify your gem's dependencies in the .gemspec file
gemspec

group :development do
  gem 'libnotify', :platforms => :ruby    # MRI, Rubinius but not Windows
end

# Platform specific supplement to .gemspec
gem "win32console", :platforms => [:mingw, :mswin]
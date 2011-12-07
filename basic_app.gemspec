# -*- encoding: utf-8 -*-
#
#
Gem::Specification.new do |s|

  # avoid shelling out to run git every time the gemspec is evaluated
  #
  # @see spec/gemspec_spec.rb
  #
  gemfiles_cache = File.join(File.dirname(__FILE__), '.gemfiles')
  if File.exists?(gemfiles_cache)
    gemfiles = File.open(gemfiles_cache, "r") {|f| f.read}
    # normalize EOL
    gemfiles.gsub!(/\r\n/, "\n")
  else
    # .gemfiles missing, run 'rake gemfiles' to create it
    # falling back to 'git ls-files'"
    gemfiles = `git ls-files`
  end

  s.name        = "basic_app"
  s.version     = File.open(File.join(File.dirname(__FILE__), 'VERSION'), "r") { |f| f.read }
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/basic_app"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "basic_app"

  s.add_dependency 'term-ansicolor', '>= 1.0.4'
  s.add_dependency 'logging', '>= 1.6.1'

  s.add_development_dependency "bundler", ">= 1.0.14"
  s.add_development_dependency "rspec", ">= 2.6.0"
  s.add_development_dependency "cucumber", "~> 1.0"
  s.add_development_dependency "aruba", "= 0.4.5"
  s.add_development_dependency "rake", ">= 0.8.7"

  # doc generation
  s.add_development_dependency "yard", ">= 0.7.4"
  s.add_development_dependency "yard-cucumber", ">= 2.1.7"
  s.add_development_dependency "redcarpet", ">= 1.17.2"

  s.files        = gemfiles.split("\n")
  s.executables  = gemfiles.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_paths = ["lib"]

  s.rdoc_options     = [
                         '--title', 'BasicApp Documentation',
                         '--main', 'README.markdown',
                         '--line-numbers',
                         '--inline-source'
                       ]
end

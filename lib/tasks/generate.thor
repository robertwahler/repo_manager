#!/usr/bin/env ruby

module Repoman

  # @example Generate a repo config
  #
  #     thor repoman:generate:config config.yml --name=test_me --path=tmp/aruba/test1 -r='//peach/data/repos' --force
  #
  class Generate < Thor
    include Thor::Actions

    # where to start looking, required by the template method
    def self.source_root
      File.dirname(__FILE__)
    end

    desc "config [FILE]", "generate repoman config file for a single repo"
    method_option :force, :type => :boolean, :desc => "Force overwrite of existing config file"
    method_option :path, :type => :string, :required =>true, :aliases => "-p", :desc => "Full path to repo working folder, i.e. c:/dat/repo1"
    method_option :name, :type => :string, :required => true, :aliases => "-n", :desc => "Repo name, i.e. 'my_repo_name'", :banner => "repo_name"
    method_option :remote, :type => :string, :required => true, :aliases => "-r", :desc => "Repo remote origin, i.e.  'git@somehost.git' or '//smb/path/to", :banner => "//smb/remote/path/to"
    def config(file)
      @name = options[:name]
      @path = options[:path]
      @remote = options[:remote]

      template_name = "templates/repo.erb"

      FileUtils.rm(file) if options[:force] && File.exist?(file)

      if File.exist?(file)
        say "Skipping #{file} because it already exists. Use --force to overwrite", :red
      else
        template template_name, file
      end

    end

  end
end


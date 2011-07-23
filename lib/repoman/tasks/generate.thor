module Repoman

  module ThorHelper
    def do_config(file, options = {})
      @name = options[:name]
      @path = options[:path]
      @remote = options[:remote]

      template_name = "templates/repo.erb"

      FileUtils.rm(file) if options[:force] && File.exist?(file)

      if File.exist?(file)
        say "Skipping #{file} because it already exists. Use --force to overwrite", :red
      else
        say "Creating repoman configuration file"
        template template_name, file
      end
    end
  end

  # @example Generate a repo config
  #
  #   thor repoman:generate:config tmp/config.yml --name=test_me --path='tmp/aruba/test1' -r='//peach/data/repos' --force
  #
  class Generate < Thor
    include Thor::Actions
    include Repoman::ThorHelper

    class_option :force, :type => :boolean, :desc => "Force overwrite of existing config file"

    method_option :path, :type => :string, :required =>true, :aliases => "-p", :desc => "Full path to working folder"
    method_option :name, :type => :string, :required => true, :aliases => "-n", :desc => "Repo name", :banner => "repo_name"
    method_option :remote, :type => :string, :required => true, :aliases => "-r", :desc => "Repo remote origin, i.e.  'git@host.git' or '//smb/path", :banner => "//smb/remote/path"
    desc "config FILE", "generate repoman config file for a single repo"
    def config(file)
      do_config(file, options)
    end

    private

    # where to start looking, required by the template method
    def self.source_root
      File.dirname(__FILE__)
    end

  end
end

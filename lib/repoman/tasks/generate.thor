require 'repoman'

module Repoman

  module GenerateHelper

    def do_config(name, options = {})

      @name = name

      file = options[:file]
      @path = options[:path]
      @remote = options[:remote]

      unless file && @path && @remote
        say "reading repo config file..."
        configuration = ::Repoman::Settings.new(FileUtils.pwd).to_hash
        puts configuration.inspect
        raise "unable to find repo config file" unless configuration[:repo_configuration_filename]
      end

      unless file
        glob =  configuration[:repo_configuration_glob]
        puts glob
        config_folder =  File.dirname(glob) if glob
        unless config_folder
          say "repo_configuration_glob key not specified or invalid in repo.conf, please set key or specify '--file=' on the command line"
          exit 1
        end
        file = File.join(config_folder, "#{name}.yml")
      end

      unless @remote
        defaults = configuration[:defaults] || {}
        remote_dirname = defaults[:remote_dirname]
        unless remote_dirname
          say "[:defaults][:remote_dirname] not found in repo.conf, please set key or specify '--remote=' on the command line"
          exit 1
        end
        @remote = "#{File.join(remote_dirname, @name + '.git')}"
      end

      @path ||= FileUtils.pwd

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
  #   thor repoman:generate:config tmp/config.yml --name=test_me --path='tmp/aruba/test1' \
  #                                -r='//peach/data/repos' --force
  #
  class Generate < Thor
    include Thor::Actions
    include Repoman::ThorHelper
    include Repoman::GenerateHelper

    class_option :force, :type => :boolean, :desc => "Force overwrite of existing config file"

    method_option :path, :type => :string, :aliases => "-p", :desc => "Full path to working folder"
    method_option :file, :type => :string, :desc => "Repo config file name", :banner => "filename"
    method_option :remote, :type => :string, :aliases => "-r", :desc => "Repo remote origin, i.e.  'git@host.git' or '//smb/path", :banner => "//smb/remote/path"
    desc "config REPO_NAME", "generate repoman config file for a single repo"
    def config(name)
      do_config(name, options)
    end

    private

    # where to start looking, required by the template method
    def self.source_root
      File.dirname(__FILE__)
    end

  end
end

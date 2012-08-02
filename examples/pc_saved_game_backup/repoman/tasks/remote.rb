require 'fileutils'

module RepoManager

  class Generate < Thor

    # full path to the remote folder
    REMOTE = File.expand_path('remote')

    # Create, add, and commit the contents of the current working directory and
    # then push it to a predefined remote folder
    #
    # @example From the repo working
    #
    #   cd ~/my_repo_name
    #   repo generate:remote my_repo_name
    #
    # @example Specify the path to the working folder
    #
    #   repo generate:remote my_repo_name --path=/path/to/my_repo_name

    method_option :remote, :type => :string, :desc => "remote folder or git host, defaults to '#{REMOTE}'"
    method_option :path, :type => :string, :desc => "path to working folder, defaults to CWD"

    desc "remote REPO_NAME", "init a git repo in CWD and push to remote '#{REMOTE}'"
    def remote(name)
      path = options[:path] || FileUtils.pwd
      remote = options[:remote] || "#{File.join(REMOTE, name + '.git')}"

      Dir.chdir path do
        run("git init")

        # core config with windows in mind but works fine on POSIX
        run("git config core.autocrlf false")
        run("git config core.filemode false")
        exit $?.exitstatus if ($?.exitstatus > 1)

        # add everthing and commit
        run("git add .")
        run("git commit --message #{shell_quote('initial commit')}")
        exit $?.exitstatus if ($?.exitstatus > 1)

        # remove old origin first, if it exists
        run("git remote add origin #{remote}")
        run("git config branch.master.remote origin")
        run("git config branch.master.merge refs/heads/master")
        exit $?.exitstatus if ($?.exitstatus > 1)
      end

      run("git clone --bare #{shell_quote(path)} #{remote}")
      exit $?.exitstatus if ($?.exitstatus > 1)

      say "init done on '#{name}'", :green
    end

  end
end

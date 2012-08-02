require 'git'

module Git

  class CommandFailed < StandardError
    attr_reader :command
    attr_reader :exitstatus
    attr_reader :error

    def initialize(command, exitstatus, error='')
      @command = command
      @exitstatus = exitstatus
      @error = error
      super "Command exited with #{exitstatus}: #{command}"
    end
  end

  class Lib

    # need 'git status --porcelain'
    def required_command_version
      [1, 7, 0, 0]
    end

    # validatation once and only once with warning to STDERR
    def validate
      return if defined? @@validated
      unless meets_required_version?
        $stderr.puts "[WARNING] The repo_manager gem requires git #{required_command_version.join('.')} or later for the status command functionality, but only found #{current_command_version.join('.')}. You should probably upgrade."
      end
      @@validated = true
    end

    # liberate the ruby-git's private command method with a few tweaks
    def native(cmd, opts = [], chdir = true, redirect = '', &block)
      validate

      ENV['GIT_DIR'] = @git_dir
      ENV['GIT_INDEX_FILE'] = @git_index_file
      ENV['GIT_WORK_TREE'] = @git_work_dir
      path = @git_work_dir || @git_dir || @path

      opts = [opts].flatten.map {|s| escape(s) }.join(' ')
      git_cmd = "git #{cmd} #{opts} #{redirect} 2>&1"

      out = nil
      if chdir && (Dir.getwd != path)
        Dir.chdir(path) { out = run_command(git_cmd, &block) }
      else
        out = run_command(git_cmd, &block)
      end

      if @logger
        @logger.info(git_cmd)
        @logger.debug(out)
      end

      if $?.exitstatus > 0
        if $?.exitstatus == 1 && out == ''
          return ''
        end
        raise Git::CommandFailed.new(git_cmd, $?.exitstatus, out.to_s)
      end
      out
    end

  end

end

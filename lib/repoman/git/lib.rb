require 'git'

module Git

  # This error class lifted from the Grit gem
  # Raised when a native git command exits with non-zero.
  class CommandFailed < StandardError
    # The full git command that failed as a String.
    attr_reader :command

    # The integer exit status.
    attr_reader :exitstatus

    # Everything output on the command's stderr as a String.
    attr_reader :err

    def initialize(command, exitstatus, err='')
      @command = command
      @exitstatus = exitstatus
      @err = err
      super "Command exited with #{exitstatus}: #{command}"
    end
  end

  class Lib

    # liberate the ruby-git's private command method with a few tweaks
    # ala Grit's error handling.
    def native(cmd, opts = [], chdir = true, redirect = '', &block)
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


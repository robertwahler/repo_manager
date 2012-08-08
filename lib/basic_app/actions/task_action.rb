module BasicApp

  # @group CLI actions
  #
  # Invoke external tasks, normally Thor tasks
  #
  # @example Usage: basic_app task TASK [args]
  #
  #      basic_app task basic_app:sweep:screenshots /to/some/folder
  #      basic_app basic_app:sweep:screenshots /to/some/folder
  #
  # @example General task help:
  #
  #      basic_app help task
  #
  # @example Help for specific task
  #
  #      basic_app task help basic_app:sweep:screenshots
  #      basic_app help basic_app:sweep:screenshots
  #
  # @example Display a list of tasks
  #
  #      basic_app task -T
  #      basic_app  -T
  #
  #      basic_app task --tasks
  #      basic_app --tasks
  #
  # @return [Number] exit code from task
  class TaskAction < AppAction

    # Add action specific options
    def parse_options
      super(:raise_on_invalid_option => false, :parse_base_options => false) do |opts|

      opts.on("-T", "--tasks", "List tasks") do |t|
        options[:tasks] = t
      end

      opts.on("--bare", "List task names for CLI completion, implies '--tasks'") do |b|
        options[:bare] = b
        options[:tasks] = true if b
      end

      end
    end

    def process
      # Thor actions can include toxic side effects,
      # keep the namespace clean until needed
      require 'basic_app/tasks/task_manager'
      task_manager = BasicApp::TaskManager.new(configuration)

      if options[:tasks]
        if options[:bare]
          task_manager.list_bare_tasks
        else
          task_manager.list_tasks
        end
        return 0
      end

      raise "task name required" if args.empty?

      target = args.shift

      if target == "help"
        target = args.shift
        task_manager.task_help(target)
      else
        task_manager.invoke(target, args)
      end
    end

    def help
      super(:comment_starting_with => "Invoke", :located_in_file => __FILE__)
    end

  end
end

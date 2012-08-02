module RepoManager

  # @group CLI actions
  #
  # Invoke external tasks, normally Thor tasks
  #
  # @example Usage: repo task TASK [args]
  #
  #      repo task repoman:sweep:screenshots /to/some/folder
  #      repo repoman:sweep:screenshots /to/some/folder
  #
  # @example General task help:
  #
  #      repo help task
  #
  # @example Help for specific task
  #
  #      repo task help repoman:sweep:screenshots
  #      repo help repoman:sweep:screenshots
  #
  # @example Display a list of tasks
  #
  #      repo task -T
  #      repo  -T
  #
  #      repo task --tasks
  #      repo --tasks
  #
  # @return [Number] exit code from task
  class TaskAction < AppAction

    # Add action specific options
    def parse_options
      super(:raise_on_invalid_option => false, :parse_base_options => false) do |opts|

      opts.on("-T", "--tasks", "List tasks") do |t|
        options[:tasks] = t
      end

      end
    end

    def process
      # Thor actions can include toxic side effects,
      # keep the namespace clean until needed
      require 'repoman/tasks/task_manager'
      task_manager = RepoManager::TaskManager.new(configuration)

      if options[:tasks]
        task_manager.list_tasks
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

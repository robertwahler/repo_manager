require 'thor'
require 'thor/core_ext/file_binary_read'
require 'thor/util'

# embed Thor engine to allow extendable tasks
module BasicApp
  class TaskManager

    attr_accessor :configuration

    def initialize(configuration=nil)
      @configuration = configuration.dup
      options = @configuration[:options]
      self.color = options ? options[:color] : true
    end

    # @examples:
    #
    #     find_by_namespace(sweep:screenshots)
    #     find_by_namespace(basic_app:sweep:screenshots)
    #
    #     returns:
    #
    #         BasicApp::Sweep, screenshots
    #
    # @return [Class, String] the Thor class and the task
    def find_by_namespace(name)
      names = name.to_s.split(':')
      raise "invalid task namespace" unless names.any?

      namespace = names.join(":")

      #puts "searching for task #{namespace}"
      klass, task = ::Thor::Util.find_class_and_task_by_namespace(namespace, fallback = false)
    end

    #
    # @examples:
    #
    #     invoke(sweep:screenshots)
    #     invoke(update:models)
    #     invoke(generate:init, ["."], nil)
    #
    def invoke(name, args=ARGV)
      logger.debug "invoke name: #{name}, args #{args.inspect}, configuration defined: #{configuration ? 'yes' : 'no'}"
      args = args.dup
      load_tasks

      logger.debug "find_by_namespace: #{name}"
      klass, task  = find_by_namespace(name)

      if klass
        config = {}
        config[:shell] ||= shell
        klass.send(:dispatch, task, args, nil, config) do |instance|
          if defined?(instance.configuration)
            instance.configuration = configuration.dup
          end
        end
        logger.debug "after invoke"
        result = 0
      else
        puts "Could not find task #{name}"
        result = 1
      end
      result
    end

    # load all the tasks in this gem plus the user's own basic_app task folder
    #
    # NOTE: doesn't load any default tasks or non-BasicApp tasks
    def load_tasks
      return if @loaded

      # By convention, the '*_helper.rb' files are helpers and need to be loaded first. Load
      # them into the Thor::Sandbox namespace
      Dir.glob( File.join(File.dirname(__FILE__), '**', '*.rb')  ).each do |task|
        if task.match(/_helper\.rb$/)
          #logger.debug "load_thorfile helper: #{task}"
          ::Thor::Util.load_thorfile task
        end
      end

      # Now load the thor files
      Dir.glob( File.join(File.dirname(__FILE__), '**', '*.rb')  ).each do |task|
        unless task.match(/_helper\.rb$/)
          #logger.debug "load_thorfile: #{task}"
          ::Thor::Util.load_thorfile task
        end
      end

      # load user tasks
      if user_tasks_folder
        Dir.glob( File.join([user_tasks_folder, '**', '*.{rb,thor}'])  ).each { |task| ::Thor::Util.load_thorfile task if task.match(/_helper\.rb$/) }
        Dir.glob( File.join([user_tasks_folder, '**', '*.{rb,thor}'])  ).each { |task| ::Thor::Util.load_thorfile task unless task.match(/_helper\.rb$/) }
      end

      @loaded = true
    end

    def user_tasks_folder
      return unless configuration

      folder = configuration[:folders] ?  configuration[:folders][:tasks] : nil
      return unless folder
      return folder if Pathname.new(folder).absolute?

      if configuration[:configuration_filename]
        base_folder = File.dirname(configuration[:configuration_filename])
        folder = File.join(base_folder, folder)
      end
    end

    def color
      @color
    end

    def color=(value)
      @color = value
      if value
        ::Thor::Base.shell = Thor::Shell::Color
      else
        ::Thor::Base.shell = Thor::Shell::Basic
      end
    end

    def shell
      return @shell if @shell

      @shell = @color ? ::Thor::Shell::Color.new : ::Thor::Shell::Basic.new
    end

    # display help for the given task
    #
    def task_help(name)
      load_tasks

      klass, task  = find_by_namespace(name)

      # set '$thor_runner' to true to display full namespace
      $thor_runner = true

      klass.task_help(shell , task)
    end

    # display a list of tasks for user display
    def list_tasks
      load_tasks

      # set '$thor_runner' to true to display full namespace
      $thor_runner = true

      list = [] #Thor.printable_tasks(all = true, subcommand = true)
      Thor::Base.subclasses.each do |klass|
        list += klass.printable_tasks(false) unless klass == Thor
      end
      list.sort!{ |a,b| a[0] <=> b[0] }

      title = "basic_app tasks"
      shell.say shell.set_color(title, :blue, bold=true)
      shell.say "-" * title.size
      shell.print_table(list, :ident => 2, :truncate => true)
    end

    # display a list of tasks for CLI completion
    def list_bare_tasks
      load_tasks

      Thor::Base.subclasses.each do |klass|
        unless klass == Thor
          klass.tasks.each do |t|
            puts "#{klass.namespace}:#{t[0]}"
          end
        end
      end
    end

  end
end

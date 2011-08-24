require 'thor/util'

# By convention, the '*.rb' files are helpers and need to be loaded first. Load
# them into the Thor::Sandbox namespace
Dir.glob( File.join(File.dirname(__FILE__), 'tasks', '**', '*.rb')  ).each do |task|
  Thor::Util.load_thorfile task
end

# Now load the thor files
Dir.glob( File.join(File.dirname(__FILE__), 'tasks', '**', '*.thor')  ).each do |task|
  Thor::Util.load_thorfile task
end

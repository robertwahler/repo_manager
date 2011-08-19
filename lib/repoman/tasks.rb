require 'thor/util'

Dir.glob( File.join(File.dirname(__FILE__), 'tasks', '**', '*.thor')  ).each do |task|
  Thor::Util.load_thorfile task
end

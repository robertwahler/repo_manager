$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'basic_app'
require 'spec'
require 'spec/autorun'
require 'aruba/api'

# aruba helper, returns to full path to files
# in the aruba tmp folder
def fullpath(filename)
  File.expand_path(File.join(current_dir, filename))
end

Spec::Runner.configure do |config|
   config.include Aruba::Api
end

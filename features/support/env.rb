require 'basic_app'
require 'aruba/cucumber'
require 'rspec/expectations'

Before do
  @aruba_timeout_seconds = 10
end

Before('@slow_process') do
  @aruba_io_wait_seconds = 2
end

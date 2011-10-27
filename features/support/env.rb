require 'repoman'
require 'aruba/cucumber'
require 'rspec/expectations'
require File.expand_path(File.dirname(__FILE__) + '/../../spec/aruba_helper')

Before do
  @aruba_timeout_seconds = 10
end

Before('@slow_process') do
  @aruba_io_wait_seconds = 2
end

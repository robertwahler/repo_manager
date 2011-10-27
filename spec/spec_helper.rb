require 'repoman'
require 'rspec/core'
require 'aruba/api'
require 'aruba_helper'

RSpec.configure do |config|
  config.include Aruba::Api
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

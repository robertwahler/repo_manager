require 'aruba'
require 'fileutils'

APP_BIN_PATH = File.join(ENV['PWD'], 'bin', 'repo')

module Aruba
  module Api

   alias_method :old_run, :run

    # override aruba
    def run(cmd, fail_on_error=true)

      # run development version in verbose mode
      cmd = cmd.gsub(/^repo/, "ruby -S #{APP_BIN_PATH} --verbose")

      # run original aruba 'run'
      old_run(cmd, fail_on_error)
    end
  end
end

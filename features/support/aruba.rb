require 'aruba/api'
require 'fileutils'

APP_BIN_PATH = File.join(FileUtils.pwd, 'bin', 'basic_app')

module Aruba
  module Api

   alias_method :old_run_simple, :run_simple

    # override aruba
    def run_simple(cmd, fail_on_error=true)

      # run development version in verbose mode
      cmd = cmd.gsub(/^basic_app/, "ruby -S #{APP_BIN_PATH} --verbose")

      # run original aruba 'run'
      old_run_simple(cmd, fail_on_error)
    end
  end
end

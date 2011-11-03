require 'aruba/api'
require 'fileutils'

APP_BIN_PATH = File.join(FileUtils.pwd, 'bin', 'repo')

module Aruba
  module Api

   alias_method :old_detect_ruby, :detect_ruby

    # override aruba
    def detect_ruby(cmd)
      cmd = cmd.gsub(/^repo/, "ruby -S #{APP_BIN_PATH}")
      # run original aruba 'detect_ruby'
      old_detect_ruby(cmd)
    end
  end
end

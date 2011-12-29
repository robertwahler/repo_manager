require 'aruba/api'
require 'fileutils'

APP_BIN_PATH = File.join(FileUtils.pwd, 'bin', 'repo')

module Aruba
  module Api

    # override aruba avoid 'current_ruby' call and make sure
    # that binary run on Win32 without the binstubs
    def detect_ruby(cmd)
      cmd = cmd.gsub(/^repo/, "ruby -S #{APP_BIN_PATH}")
    end
  end
end

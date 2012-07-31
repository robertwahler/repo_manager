require 'aruba/api'
require 'fileutils'

module Aruba
  module Api

    # override aruba avoid 'current_ruby' call and make sure
    # that binary run on Win32 without the binstubs
    def detect_ruby(cmd)
      wrapper = which('repo')
      cmd = cmd.gsub(/^repo/, "ruby -S #{wrapper}") if wrapper
      cmd
    end
  end
end

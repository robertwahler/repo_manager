require 'pathname'
require 'rbconfig'
require 'fileutils'

module Repoman
  module ActionHelper

    def shell_quote(string)
      return "" if string.nil? or string.empty?
      if windows?
        %{"#{string}"}
      else
        string.split("'").map{|m| "'#{m}'" }.join("\\'")
      end
    end

    def windows?
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw/i
    end

    # @return[String] the relative path from the CWD
    def relative_path(path)
      path = Pathname.new(File.expand_path(path, FileUtils.pwd)).relative_path_from(Pathname.new(FileUtils.pwd))
      path = "./#{path}" unless path.absolute? || path.to_s.match(/^\./)
      path.to_s
    end

  end
end

require 'rbconfig'

module Repoman
  module ThorHelper

    def shell_quote(string)
      return "" if string.nil? or string.empty?
      if windows?
        %{"#{string}"}
      else
        string.split("'").map{|m| "'#{m}'" }.join("\\'")
      end
    end

    def windows?
      Config::CONFIG['host_os'] =~ /mswin|mingw/i
    end
  end
end

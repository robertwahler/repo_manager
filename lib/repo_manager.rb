# require all files here
require 'rbconfig'
require 'repo_manager/core'
require 'repo_manager/errors'
require 'repo_manager/assets'
require 'repo_manager/views'
require 'repo_manager/actions'
require 'repo_manager/git'
require 'repo_manager/app'
require 'repo_manager/settings'
require 'repo_manager/logger'


# Master namespace
module RepoManager

  # Contents of the VERSION file
  #
  # Example format: 0.0.1
  #
  # @return [String] the contents of the version file in #.#.# format
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read.strip
    end
  end

  # Platform constants
  unless defined?(RepoManager::WINDOWS)
    WINDOWS = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/i
    CYGWIN = RbConfig::CONFIG['host_os'] =~ /cygwin/i
  end

end


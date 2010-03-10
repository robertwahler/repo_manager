$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require 'rubygems'

module BasicApp

  # return the contents of the VERSION file
  # VERSION format: 0.0.0
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read
    end 
  end
  
end

require 'basic_app/app'

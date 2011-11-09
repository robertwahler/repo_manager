####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
module BasicApp

  # An abstract superclass for basic asset functionality specific to an
  # application implementation.  Put application specific code here.
  class AppAsset < BaseAsset

    def path
      attributes[:path]
    end

    def path=(value)
      attributes[:path] = value
    end

  private

    def in_asset_folder(&block)
      Dir.chdir(path, &block)
    end

  end
end

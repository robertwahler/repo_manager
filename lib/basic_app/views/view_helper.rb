module BasicApp

  module ViewHelper

    # path_to returns absolute installed path to various folders packaged with
    # the BasicApp gem
    #
    # @example manually require and include before use
    #
    #     require 'basic_app/views/view_helper'
    #     include BasicApp::ViewHelper
    #
    # @example default to basic_app root
    #
    #     path_to("views/templates/bla.rb")
    #
    # @example basic_app root
    #
    #     path_to(:basic_app, "views/templates/bla.rb")
    #
    # @example :bootstrap
    #
    #     path_to(:bootstrap, "bootstrap/css/bootstrap.css")
    #
    # @overload path_to(*args)
    #   @param [Symbol] base_path which gem folder should be root
    #   @param [String] file_asset path to file asset parented in the given folder
    #
    # @return [String] absolute path to asset
    def path_to(*args)

      case
        when args.length == 1
          base_path = :basic_app
          asset = args
        when args.length == 2
          base_path, asset = *args
        when args.length  > 2
          raise ArgumentError, "Too many arguments"
        else
          raise ArgumentError, "Specify at least the file asset"
      end

      case base_path
        when :basic_app
          root = File.expand_path('../../../../', __FILE__)
        else
          raise "unknown base_path"
      end

      File.join(root, asset)
    end

  end
end

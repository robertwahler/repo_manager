module Repoman

  module ViewHelper

    # path_to returns absolute installed path to various folders packaged with
    # the Repoman gem
    #
    # @example manually require and include before use
    #
    #     require 'repoman/views/view_helper'
    #     include Repoman::ViewHelper
    #
    # @example default to repoman root
    #
    #     path_to("views/templates/bla.rb")
    #
    # @example repoman root
    #
    #     path_to(:repoman, "views/templates/bla.rb")
    #
    # @example :bootstrap
    #
    #     path_to(:bootstrap, "bootstrap/css/bootstrap.css")
    #
    # @param [Symbol] (:repoman) which gem folder should be root
    # @param [String] path to file asset parented in the given folder
    #
    # @return [String] absolute path to asset
    def path_to(*args)

      case
        when args.length == 1
          base_path = :repoman
          asset = args
        when args.length == 2
          base_path, asset = *args
        when args.length  > 2
          raise ArgumentError, "Too many arguments"
        else
          raise ArgumentError, "Specify at least the file asset"
      end

      case base_path
        when :repoman
          root = File.expand_path('../../../../', __FILE__)
        else
          raise "unknown base_path"
      end

      File.join(root, asset)
    end

  end
end

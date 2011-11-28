####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################

require 'slim'

module BasicApp

  # An abstract superclass for basic view/reporting functionality
  # using templates
  class BaseView

    attr_accessor :template

    def initialize(items)
      @items = items
      @template = File.expand_path('../templates/default.slim', __FILE__)
    end

    def items
      @items
    end

    def title
      @title || "Default Title"
    end

    def title=(value)
      @title = value
    end

    # TODO: ERB binding
    def get_binding
      binding
    end

    # TODO: render based on file ext
    def render
      Slim::Template.new(template, {:pretty => true}).render(self)
    end

  end
end

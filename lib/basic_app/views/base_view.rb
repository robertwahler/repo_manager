####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################

require 'pathname'
require 'slim'
require 'chronic'

module BasicApp

  # An abstract superclass for basic view/reporting functionality
  # using templates
  class BaseView

    attr_accessor :template
    attr_accessor :options

    def initialize(items, options={})
      @options = options
      @items = items
      @template = File.expand_path('../templates/default.slim', __FILE__)
    end

    def items
      @items
    end

    def title
      @title || options[:title] || "Default Title"
    end

    def title=(value)
      @title = value
    end

    def date
      return @date if @date

      if options[:date]
        @date = Chronic.parse(options[:date])
        return @date if @date
      end
      @date = Date.today
    end

    def date=(value)
      @date = value
    end

    # TODO: for ERB binding
    def get_binding
      binding
    end

    # TODO: render based on file ext
    def render
      filename = template
      filename = File.expand_path(File.join('../templates', filename), __FILE__) unless Pathname.new(filename).absolute?
      raise "unable to find template file: #{filename}" unless File.exists?(filename)
      Slim::Template.new(filename, {:pretty => true}).render(self)
    end

  end
end

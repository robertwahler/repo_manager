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

module Repoman

  # An abstract superclass for basic view/reporting functionality
  # using templates
  class BaseView

    attr_accessor :options

    def initialize(items, options={})
      @options = options
      @items = items
      @template = File.expand_path('../templates/default.slim', __FILE__)
    end

    def items
      @items
    end

    def template
      return @template if @template.nil? || Pathname.new(@template).absolute?

      # try relative to PWD
      fullpath = File.expand_path(File.join(FileUtils.pwd, @template))
      return fullpath if File.exists?(fullpath)

      # try built in template folder
      fullpath = File.expand_path(File.join('../templates', @template), __FILE__)
    end

    def template=(value)
      @template = value
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

    # render a partial
    #
    # filename: unless absolute, it will be relative to the main template
    #
    # @example slim escapes HTML, use '=='
    #
    #   head
    #   == render 'mystyle.css'
    #
    # @return [String] of non-escaped textual content
    def partial(filename)
      filename = partial_path(filename)
      raise "unable to find partial file: #{filename}" unless File.exists?(filename)
      contents = File.open(filename, "rb") {|f| f.read}
      # TODO: detect template EOL and match it to the partial's EOL
      # force unix eol
      contents.gsub!(/\r\n/, "\n") if contents.match("\r\n")
      contents
    end

    # TODO: render based on file ext
    def render
      raise "unable to find template file: #{template}" unless File.exists?(template)
      Slim::Template.new(template, {:pretty => true}).render(self)
    end

  private

    # full expanded path to the given partial
    #
    def partial_path(filename)
      return filename if filename.nil? || Pathname.new(filename).absolute?

      # try relative to template
      if template
        base_folder = File.dirname(template)
        filename = File.expand_path(File.join(base_folder, filename))
        return filename if File.exists?(filename)
      end

      # try relative to PWD
      filename = File.expand_path(File.join(FileUtils.pwd, filename))
      return filename if File.exists?(filename)

      # try built in template folder
      filename = File.expand_path(File.join('../templates', filename), __FILE__)
    end

  end
end

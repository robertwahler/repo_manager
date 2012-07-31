module Repoman
  module TestApi

    # cross platform `which` command
    def which(binary)
      separator = Repoman::WINDOWS ? ';' : ':'
      paths = ENV['PATH'].split(separator)
      paths.each do |path|
        fullpath = File.join(path, binary)
        return fullpath if File.exists?(fullpath)
      end
      return nil
    end

    def in_path(path, &block)
      Dir.chdir(path, &block)
    end

    def expand_tabs(data, indent=8)
      data.gsub(/([^\t\n]*)\t/) {
        $1 + " " * (indent - ($1.size % indent))
      }
    end

    def normalize(str)
      # convert/normalize DOS CRLF endings
      str.gsub!(/\r\n/, "\n") if str.match("\r\n")
      if str.match("\t")
        str = expand_tabs(str)
      end
      str
    end

    def process_and_check_file_content(file, partial_content, expect_match)
      str = process_regex_tokens(Regexp.escape(partial_content))
      content = IO.read(file)
      if expect_match
        content.should =~ Regexp.compile(str)
      else
        content.should_not =~ Regexp.compile(str)
      end
    end

    # substitute back in each tokenized regexp after all text has been escaped
    def process_regex_tokens(str)
      str = str.gsub(/<%NUMBER[^%]*%>/, '\d+')
      str = str.gsub(/<%PK[^%]*%>/, '\d+')
      str = str.gsub(/<%STRING[^%]*%>/, '.+')
      str
    end

    def write_fixed_size_file(file_name, file_size)
      _create_fixed_size_file(file_name, file_size, false)
    end

    def _create_fixed_size_file(file_name, file_size, check_presence)
      in_current_dir do
        raise "expected #{file_name} to be present" if check_presence && !File.file?(file_name)
        _mkdir(File.dirname(file_name))
        File.open(file_name, "wb"){ |f| f.seek(file_size - 1); f.write("\0") }
      end
    end

    # @return full path to files in the aruba tmp folder
    def fullpath(filename)
      path = File.expand_path(File.join(current_dir, filename))
      #if path.match(/^\/cygdrive/)
      #  # match /cygdrive/c/path/to and return c:\\path\\to
      #  path = `cygpath -w #{path}`.chomp
      #elsif path.match(/.\:/)
      #  # match c:/path/to and return c:\\path\\to
      #  path = path.gsub(/\//, '\\')
      #end
      path
    end

    # @return the contents of "filename" in the aruba tmp folder
    def get_file_contents(filename)
      in_current_dir do
        IO.read(filename)
      end
    end

  end
end

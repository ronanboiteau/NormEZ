class String

  def add_style(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def black
    add_style(31)
  end

  def red
    add_style(31)
  end

  def green
    add_style(32)
  end

  def yellow
    add_style(33)
  end

  def blue
    add_style(34)
  end

  def magenta
    add_style(35)
  end

  def cyan
    add_style(36)
  end

  def grey
    add_style(37)
  end

  def bold
    add_style(1)
  end

  def italic
    add_style(3)
  end

  def underline
    add_style(4)
  end

end

class FileManager

  attr_accessor :path

  def initialize(path)
    @path = path
  end

  def get_content
    file = File.open(@path)
    content = file.read
    file.close
    content
  end

end

class FilesRetriever

  def initialize
    @files = Dir['**/*{.c,.h}'].select { |f| File.file?(f) }
    @nb_files = @files.size
    @index = 0
  end

  def get_next_file
    if @index >= @nb_files
      return nil
    end
    file = FileManager.new(@files[@index])
    @index += 1
    file
  end

  def check_forbidden_files
    files = Dir['**/*{[!.c|.h|Makefile]}'].select { |f| File.file?(f) }
    files.each do |file|
      msg_brackets = "[" + file + "]"
      msg_error = " Forbidden file. Do not forget to remove it before your final push."
      puts msg_brackets.bold.magenta + msg_error.bold
    end
  end

end

class CodingStyleChecker

  def initialize(file_manager)
    @file_path = file_manager.path
    @file = file_manager.get_content
    check_file
  end

  def check_file
    check_too_many_columns
    check_too_broad_filename
  end

  def check_too_many_columns
    line_nb = 1
    @file.each_line do |line|
      if line.length - 1 > 80
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Too many columns (" + (line.length - 1).to_s + " > 80)."
        puts msg_brackets.bold.magenta + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_too_broad_filename
    if /(.*\/|^)(string.c|str.c|my_string.c|my_str.c|algorithm.c|my_algorithm.c|algo.c|my_algo.c|program.c|my_program.c|prog.c|my_prog.c)$/.match(@file_path)
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Too broad filename. You should rename this file."
      puts msg_brackets.bold.magenta + msg_error.bold
    end
  end

end

files_retriever = FilesRetriever.new
files_retriever.check_forbidden_files
while (next_file = files_retriever.get_next_file)
  CodingStyleChecker.new(next_file)
end

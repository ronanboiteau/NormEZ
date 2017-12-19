class String

  def each_char
    self.split("").each { |i| yield i }
  end

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
      puts msg_brackets.bold.red + msg_error.bold
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
    check_header
    check_function_lines
    check_several_semicolons
    check_forbidden_keyword_func
    check_too_many_else_if
  end

  def check_too_many_columns
    line_nb = 1
    @file.each_line do |line|
      if line.length - 1 > 80
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Too many columns (" + (line.length - 1).to_s + " > 80)."
        puts msg_brackets.bold.red + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_too_broad_filename
    if @file_path =~ /(.*\/|^)(string.c|str.c|my_string.c|my_str.c|algorithm.c|my_algorithm.c|algo.c|my_algo.c|program.c|my_program.c|prog.c|my_prog.c)$/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Too broad filename. You should rename this file."
      puts msg_brackets.bold.red + msg_error.bold
    end
  end

  def check_header
    if @file !~ /\/\*\n\*\* EPITECH PROJECT, [0-9]{4}\n\*\* .*\n\*\* File description:\n\*\* .*\n\*\/\n.*/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Missing or corrupted header."
      puts msg_brackets.bold.red + msg_error.bold
    end
  end

  def check_function_lines
    count = 0
    line_nb = function_start = 1
    @file.each_line do |line|
      if line =~ /^}.*/
        if count > 20
          msg_brackets = "[" + @file_path + ":" + function_start.to_s + "]"
          msg_error = " Function contains more than 20 lines (" + count.to_s + " > 20)."
          puts msg_brackets.bold.red + msg_error.bold
        end
      end
      if line =~ /^{.*/
        count = 0
        function_start = line_nb
      else
        count += 1
      end
      line_nb += 1
    end
  end

  def check_several_semicolons
    line_nb = 1
    @file.each_line do |line|
      inside_str = assignment = false
      line.each_char do |char|
        if assignment and !(["\n", " ", "\t"]).include?(char)
          msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
          msg_error = " Several semicolons on the same line."
          puts msg_brackets.bold.red + msg_error.bold
          return
        end
        if char == "'" or char == '"'
          inside_str = !inside_str
        end
        if char == ";" and !inside_str
          assignment = true
        end
      end
      line_nb += 1
    end
  end

  def check_forbidden_keyword_func
    line_nb = 1
    @file.each_line do |line|
      inside_str = false
      while line[0]
        if line[0] == "'" or line[0] == '"'
          inside_str = !inside_str
        end
        if line =~ /^[^0-9a-zA-Z_](?<forbidden>printf|dprintf|fprintf|vprintf|sprintf|snprintf|vprintf|vfprintf|vsprintf|vsnprintf|asprintf|scranf|memcpy|memset|memmove|strcat|strchar|strcpy|atoi|strlen|strstr|strncat|strncpy|strcasestr|strncasestr|strcmp|strncmp|strtok|strnlen|strdup|realloc)[^0-9a-zA-Z]/ and !inside_str
          msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
          msg_error = " Are you sure that this function is allowed: '".bold
          msg_error += (Hash[$~.names.collect{|x| [x.to_sym, $~[x]]}][:forbidden]).bold.red
          msg_error += "'?".bold
          puts msg_brackets.bold.red + msg_error
        elsif line =~ /^[^0-9a-zA-Z_](?<forbidden>goto)[^0-9a-zA-Z]/ and !inside_str
          msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
          msg_error = " Are you sure that this keyword is allowed: '".bold
          msg_error += (Hash[$~.names.collect{|x| [x.to_sym, $~[x]]}][:forbidden]).bold.red
          msg_error += "'?".bold
          puts msg_brackets.bold.red + msg_error
        end
        line[0] = ''
      end
      line_nb += 1
    end
  end

  def check_too_many_else_if
    line_nb = condition_start = 1
    count = 0
    @file.each_line do |line|
      while ([" ", "\t"]).include?(line[0])
        line[0] = ''
      end
      if line =~ /^if \(/
        condition_start = line_nb
        count = 1
      elsif line =~ /^else if \(/ or line =~ /^else \(/
        count += 1
        if count > 3
          msg_brackets = "[" + @file_path + ":" + condition_start.to_s + "]"
          msg_error = " Too many \"else if\" statements."
          puts msg_brackets.bold.red + msg_error.bold
        end
      end
      line_nb += 1
    end
  end

end

files_retriever = FilesRetriever.new
files_retriever.check_forbidden_files
while (next_file = files_retriever.get_next_file)
  CodingStyleChecker.new(next_file)
end

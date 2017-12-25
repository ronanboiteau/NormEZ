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

module FileType
  MAKEFILE = 0
  HEADER = 1
  SOURCE = 2
end

class FileManager

  attr_accessor :path
  attr_accessor :type

  def initialize(path)
    @path = path
    if @path =~ /Makefile$/
      @type = FileType::MAKEFILE
    elsif @path =~ /[.]h$/
      @type = FileType::HEADER
    elsif @path =~ /[.]c$/
      @type = FileType::SOURCE
    end
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
    @files = Dir['**/*[{.c|.h|Makefile}]'].select { |f| File.file?(f) }
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
    @type = file_manager.type
    check_file
  end

  def check_file
    check_trailing_spaces_tabs
    check_spaces_in_indentation
    if @type != FileType::MAKEFILE
      check_filename
      check_too_many_columns
      check_too_broad_filename
      check_header
      check_several_assignments
      check_forbidden_keyword_func
      check_too_many_else_if
      check_empty_parenthesis
      check_too_many_parameters
      check_space_after_keywords
      check_misplaced_pointer_symbol
      if @type == FileType::SOURCE
        check_functions_per_file
        check_function_lines
        check_misplaced_comments
      end
      if @type == FileType::HEADER
        check_macro_used_as_constant
      end
    elsif @type == FileType::MAKEFILE
      check_header_makefile
    end
  end

  def check_filename
    filename = File.basename(@file_path)
    if filename !~ /^[a-z0-9_]+[.][ch]$/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Filenames should respect the snake_case naming convention."
      puts msg_brackets.bold.red + msg_error.bold
    end
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
    count = level = 0
    line_nb = function_start = 1
    @file.each_line do |line|
      if line =~ /{[ \t]*$/
        if level == 0
          function_start = line_nb
          count = -1
        end
        level += 1
      elsif line =~ /^[ \t]*}[ \t]*$/
        level -= 1
        if level == 0 and count > 20
          msg_brackets = "[" + @file_path + ":" + function_start.to_s + "]"
          msg_error = " Function contains more than 20 lines (" + count.to_s + " > 20)."
          puts msg_brackets.bold.red + msg_error.bold
        end
      end
      count += 1
      line_nb += 1
    end
  end

  def check_several_assignments
    line_nb = 1
    @file.each_line do |line|
      if line =~ /^[ \t]*for ?\(/
        line_nb += 1
        next
      end
      assignments = 0
      line.each_char do |char|
        if char == ";"
          assignments += 1
        end
      end
      if assignments > 1
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Several assignments on the same line."
        puts msg_brackets.bold.red + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_forbidden_keyword_func
    line_nb = 1
    @file.each_line do |line|
      line.scan(/^(printf|dprintf|fprintf|vprintf|sprintf|snprintf|vprintf|vfprintf|vsprintf|vsnprintf|asprintf|scranf|memcpy|memset|memmove|strcat|strchar|strcpy|atoi|strlen|strstr|strncat|strncpy|strcasestr|strncasestr|strcmp|strncmp|strtok|strnlen|strdup|realloc)[^0-9a-zA-Z]/) do |match|
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Are you sure that this function is allowed: '".bold
        msg_error += $1.bold.red
        msg_error += "'?".bold
        puts msg_brackets.bold.red + msg_error
      end
      while line[0]
        line.scan(/^[^0-9a-zA-Z_](printf|dprintf|fprintf|vprintf|sprintf|snprintf|vprintf|vfprintf|vsprintf|vsnprintf|asprintf|scranf|memcpy|memset|memmove|strcat|strchar|strcpy|atoi|strlen|strstr|strncat|strncpy|strcasestr|strncasestr|strcmp|strncmp|strtok|strnlen|strdup|realloc)[^0-9a-zA-Z]/) do |match|
          msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
          msg_error = " Are you sure that this function is allowed: '".bold
          msg_error += $1.bold.red
          msg_error += "'?".bold
          puts msg_brackets.bold.red + msg_error
        end
        line.scan(/^[^0-9a-zA-Z_](goto)[^0-9a-zA-Z]/) do |match|
          msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
          msg_error = " Are you sure that this keyword is allowed: '".bold
          msg_error += $1.bold.red
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
      if line =~ /^if ?\(/
        condition_start = line_nb
        count = 1
      elsif line =~ /^else if ?\(/ or line =~ /^else ?\(/
        count += 1
        if count > 3
          msg_brackets = "[" + @file_path + ":" + condition_start.to_s + "]"
          msg_error = " Too many \"else if\" statements."
          puts msg_brackets.bold.green + msg_error.bold
        end
      end
      line_nb += 1
    end
  end

  def check_trailing_spaces_tabs
    line_nb = 1
    @file.each_line do |line|
      if line =~ / $/
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Trailing space(s) at the end of the line."
        puts msg_brackets.bold.green + msg_error.bold
      elsif line =~ /\t$/
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Trailing tabulation(s) at the end of the line."
        puts msg_brackets.bold.green + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_spaces_in_indentation
    line_nb = 1
    @file.each_line do |line|
      indent = 0
      while line[0] == "\t"
        line[0] = ""
        indent += 1
      end
      if line[0] == " "
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Wrong indentation: spaces are not allowed."
        puts msg_brackets.bold.green + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_functions_per_file
    functions = 0
    @file.each_line do |line|
      if line =~ /^{/
        functions += 1
      end
    end
    if functions > 5
      msg_brackets = "[" + @file_path + "]"
      msg_error = " More than 5 functions in the same file (" + functions.to_s + " > 5)."
      puts msg_brackets.bold.red + msg_error.bold
    end
  end

  def check_empty_parenthesis
    line_nb = 1
    missing_bracket = false
    @file.each_line do |line|
      if missing_bracket
        if line =~ /^{$/
          msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
          msg_error = " This function takes no parameter, it should take 'void' as argument."
          puts msg_brackets.bold.red + msg_error.bold
        elsif line !~ /^[\t ]*$/
          missing_bracket = false
        end
      elsif line =~ /\(\)[\t ]*{$/
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " This function takes no parameter, it should take 'void' as argument."
        puts msg_brackets.bold.red + msg_error.bold
      elsif line =~ /\(\)[ \t]*$/
        missing_bracket = true
      end
      line_nb += 1
    end
  end

  def check_too_many_parameters
    @file.scan(/\(([^(),]*,){4,}[^()]*\)[ \t\n]+{/).each do |match|
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Function shouldn't take more than 4 arguments."
      puts msg_brackets.bold.red + msg_error.bold
    end
  end

  def check_space_after_keywords
    line_nb = 1
    @file.each_line do |line|
      line.scan(/(return|if|else if|else|while|for)\(/) do |match|
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Missing space after keyword '" + match[0] + "'."
        puts msg_brackets.bold.green + msg_error.bold
      end
      line.scan(/(return|if|else if|else|while|for);/) do |match|
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Missing space after keyword '" + match[0] + "'."
        puts msg_brackets.bold.green + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_misplaced_pointer_symbol
    line_nb = 1
    @file.each_line do |line|
      line.scan(/([^(\t ]+_t|int|signed|unsigned|char|long|short|float|double|void|const|struct [^ ]+)\*/) do |match|
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Misplaced pointer symbol after '" + match[0] + "'."
        puts msg_brackets.bold.green + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_macro_used_as_constant
    line_nb = 1
    @file.each_line do |line|
      if line =~ (/#define [^ ]+ [0-9]+([.][0-9]+)?/)
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Macros should not be used for constants."
        puts msg_brackets.bold.green + msg_error.bold
      end
      line_nb += 1
    end
  end

  def check_header_makefile
    if @file !~ /##\n## EPITECH PROJECT, [0-9]{4}\n## .*\n## File description:\n## .*\n##\n.*/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Missing or corrupted header."
      puts msg_brackets.bold.red + msg_error.bold
    end
  end

  def check_misplaced_comments
    level = 0
    line_nb = 1
    @file.each_line do |line|
      if line =~ /{[ \t]*$/
        level += 1
      elsif line =~ /^[ \t]*}[ \t]*$/
        level -= 1
      end
      if level != 0 and (line =~ /\/\*/ or line =~ /\/\//)
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Misplaced comment."
        puts msg_brackets.bold.green + msg_error.bold
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

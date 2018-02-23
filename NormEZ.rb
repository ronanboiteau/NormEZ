#!/usr/bin/ruby
# NormEZ_v1.4.0
# Changelog: Added options to ignore forbidden files (-f) & forbidden functions (-m) or both (-i) / -nu option is now -u

require 'optparse'

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
  UNKNOWN = 0
  DIRECTORY = 1
  MAKEFILE = 2
  HEADER = 3
  SOURCE = 4
end

class FileManager

  attr_accessor :path
  attr_accessor :type

  def initialize(path, type)
    @path = path
    @type = type
    if @type == FileType::UNKNOWN
      @type = get_file_type
    end
  end

  def get_file_type
    if @path =~ /Makefile$/
      @type = FileType::MAKEFILE
    elsif @path =~ /[.]h$/
      @type = FileType::HEADER
    elsif @path =~ /[.]c$/
      @type = FileType::SOURCE
    else
      @type = FileType::UNKNOWN
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
    @files = Dir['**/*'].select{ |f| File.file? f }
    @nb_files = @files.size
    @idx_files = 0

    @dirs = Dir['**/*'].select{ |d| File.directory? d }
    @nb_dirs = @dirs.size
    @idx_dirs = 0
  end

  def get_next_file
    if @idx_files < @nb_files
      file = FileManager.new(@files[@idx_files], FileType::UNKNOWN)
      @idx_files += 1
      return file
    elsif @idx_dirs < @nb_dirs
      file = FileManager.new(@dirs[@idx_dirs], FileType::DIRECTORY)
      @idx_dirs += 1
      return file
    end
    nil
  end

end

class CodingStyleChecker

  def initialize(file_manager)
    @file_path = file_manager.path
    @type = file_manager.type
    @file = nil
    if @type != FileType::UNKNOWN and @type != FileType::DIRECTORY
      @file = file_manager.get_content
    end
    check_file
  end

  def check_file
    if @type == FileType::UNKNOWN
      if !($options.include? :ignorefiles)
        msg_brackets = "[" + @file_path + "]"
        msg_error = " This is probably a forbidden file. You might not want to commit it."
        puts(msg_brackets.bold.red + msg_error.bold)
      end
      return
    end
    if @type == FileType::DIRECTORY
      check_dirname
      return
    end
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
      check_comma_missing_space
      check_misplaced_comments
      check_operators_spaces
      check_condition_assignment
      if @type == FileType::SOURCE
        check_functions_per_file
        check_function_lines
      end
      if @type == FileType::HEADER
        check_macro_used_as_constant
      end
    elsif @type == FileType::MAKEFILE
      check_header_makefile
    end
  end

  def check_dirname
    filename = File.basename(@file_path)
    if filename !~ /^[a-z0-9]+([a-z0-9_]+[a-z0-9]+)*$/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Directory names should respect the snake_case naming convention."
      puts(msg_brackets.bold.red + msg_error.bold)
    end
  end

  def check_filename
    filename = File.basename(@file_path)
    if filename !~ /^[a-z0-9]+([a-z0-9_]+[a-z0-9]+)*[.][ch]$/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Filenames should respect the snake_case naming convention."
      puts(msg_brackets.bold.red + msg_error.bold)
    end
  end

  def check_too_many_columns
    line_nb = 1
    @file.each_line do |line|
      length = 0
      line.each_char do |char|
        if char == "\t"
          length += 8
        else
          length += 1
        end
      end
      if length - 1 > 80
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Too many columns (" + (length - 1).to_s + " > 80)."
        puts(msg_brackets.bold.red + msg_error.bold)
      end
      line_nb += 1
    end
  end

  def check_too_broad_filename
    if @file_path =~ /(.*\/|^)(string.c|str.c|my_string.c|my_str.c|algorithm.c|my_algorithm.c|algo.c|my_algo.c|program.c|my_program.c|prog.c|my_prog.c)$/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Too broad filename. You should rename this file."
      puts(msg_brackets.bold.red + msg_error.bold)
    end
  end

  def check_header
    if @file !~ /\/\*\n\*\* EPITECH PROJECT, [0-9]{4}\n\*\* .*\n\*\* File description:\n(\*\* .*\n)+\*\/\n.*/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Missing or corrupted header."
      puts(msg_brackets.bold.red + msg_error.bold)
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
          puts(msg_brackets.bold.red + msg_error.bold)
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
        puts(msg_brackets.bold.red + msg_error.bold)
      end
      line_nb += 1
    end
  end

  def check_forbidden_keyword_func
    line_nb = 1
    @file.each_line do |line|
      line.scan(/(^|[^0-9a-zA-Z_])(printf|dprintf|fprintf|vprintf|sprintf|snprintf|vprintf|vfprintf|vsprintf|vsnprintf|asprintf|scranf|memcpy|memset|memmove|strcat|strchar|strcpy|atoi|strlen|strstr|strncat|strncpy|strcasestr|strncasestr|strcmp|strncmp|strtok|strnlen|strdup|realloc)[^0-9a-zA-Z]/) do
        if !($options.include? :ignorefunctions)
          msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
          msg_error = " Are you sure that this function is allowed: '".bold
          msg_error += $2.bold.red
          msg_error += "'?".bold
          puts(msg_brackets.bold.red + msg_error)
        end
      end
      line.scan(/(^|[^0-9a-zA-Z_])(goto)[^0-9a-zA-Z]/) do
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Are you sure that this keyword is allowed: '".bold
        msg_error += $2.bold.red
        msg_error += "'?".bold
        puts(msg_brackets.bold.red + msg_error)
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
          puts(msg_brackets.bold.green + msg_error.bold)
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
        puts(msg_brackets.bold.green + msg_error.bold)
      elsif line =~ /\t$/
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Trailing tabulation(s) at the end of the line."
        puts(msg_brackets.bold.green + msg_error.bold)
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
        puts(msg_brackets.bold.green + msg_error.bold)
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
      puts(msg_brackets.bold.red + msg_error.bold)
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
          puts(msg_brackets.bold.red + msg_error.bold)
        elsif line !~ /^[\t ]*$/
          missing_bracket = false
        end
      elsif line =~ /\(\)[\t ]*{$/
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " This function takes no parameter, it should take 'void' as argument."
        puts(msg_brackets.bold.red + msg_error.bold)
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
      puts(msg_brackets.bold.red + msg_error.bold)
    end
  end

  def check_space_after_keywords
    line_nb = 1
    @file.each_line do |line|
      line.scan(/(return|if|else if|else|while|for)\(/) do |match|
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Missing space after keyword '" + match[0] + "'."
        puts(msg_brackets.bold.green + msg_error.bold)
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
        puts(msg_brackets.bold.green + msg_error.bold)
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
        puts(msg_brackets.bold.green + msg_error.bold)
      end
      line_nb += 1
    end
  end

  def check_header_makefile
    if @file !~ /##\n## EPITECH PROJECT, [0-9]{4}\n## .*\n## File description:\n## .*\n##\n.*/
      msg_brackets = "[" + @file_path + "]"
      msg_error = " Missing or corrupted header."
      puts(msg_brackets.bold.red + msg_error.bold)
    end
  end

  def check_misplaced_comments
    level = 0
    line_nb = 1
    @file.each_line do |line|
      level += line.count "{"
      level -= line.count "}"
      if level != 0 and (line =~ /\/\*/ or line =~ /\/\//)
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Comment inside a function."
        puts(msg_brackets.bold.green + msg_error.bold)
      end
      line_nb += 1
    end
  end

  def check_comma_missing_space
    line_nb = 1
    @file.each_line do |line|
      line.scan(/,[^ \n]/) do
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Missing space after comma."
        puts(msg_brackets.bold.green + msg_error.bold)
      end
      line_nb += 1
    end
  end

  def put_error_sign(sign, line_nb)
    msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
    msg_error = " Misplaced space(s) around '" + sign + "' sign."
    puts(msg_brackets.bold.green + msg_error.bold)
  end

  def check_operators_spaces
    line_nb = 1
    @file.each_line do |line|
      # A space on both ends
      line.scan(/([^\t&|=^><+\-*%\/! ]=[^=]|[^&|=^><+\-*%\/!]=[^= \n])/) do
        put_error_sign("=", line_nb)
      end
      line.scan(/([^\t ]==|==[^ \n])/) do
        put_error_sign("==", line_nb)
      end
      line.scan(/([^\t ]!=|!=[^ \n])/) do
        put_error_sign("!=", line_nb)
      end
      line.scan(/([^\t <]<=|[^<]<=[^ \n])/) do
        put_error_sign("<=", line_nb)
      end
      line.scan(/([^\t >]>=|[^>]>=[^ \n])/) do
        put_error_sign(">=", line_nb)
      end
      line.scan(/([^\t ]&&|&&[^ \n])/) do
        put_error_sign("&&", line_nb)
      end
      line.scan(/([^\t ]\|\||\|\|[^ \n])/) do
        put_error_sign("||", line_nb)
      end
      line.scan(/([^\t ]\+=|\+=[^ \n])/) do
        put_error_sign("+=", line_nb)
      end
      line.scan(/([^\t ]-=|-=[^ \n])/) do
        put_error_sign("-=", line_nb)
      end
      line.scan(/([^\t ]\*=|\*=[^ \n])/) do
        put_error_sign("*=", line_nb)
      end
      line.scan(/([^\t ]\/=|\/=[^ \n])/) do
        put_error_sign("/=", line_nb)
      end
      line.scan(/([^\t ]%=|%=[^ \n])/) do
        put_error_sign("%=", line_nb)
      end
      line.scan(/([^\t ]&=|&=[^ \n])/) do
        put_error_sign("&=", line_nb)
      end
      line.scan(/([^\t ]\^=|\^=[^ \n])/) do
        put_error_sign("^=", line_nb)
      end
      line.scan(/([^\t ]\|=|\|=[^ \n])/) do
        put_error_sign("|=", line_nb)
      end
      line.scan(/([^\t |]\|[^|]|[^|]\|[^ =|\n])/) do
        # Minifix for Matchstick
        line.scan(/([^']\|[^'])/) do
          put_error_sign("|", line_nb)
        end
      end
      line.scan(/([^\t ]\^|\^[^ =\n])/) do
        put_error_sign("^", line_nb)
      end
      line.scan(/([^\t ]>>[^=]|>>[^ =\n])/) do
        put_error_sign(">>", line_nb)
      end
      line.scan(/([^\t ]<<[^=]|<<[^ =\n])/) do
        put_error_sign("<<", line_nb)
      end
      line.scan(/([^\t ]>>=|>>=[^ \n])/) do
        put_error_sign(">>=", line_nb)
      end
      line.scan(/([^\t ]<<=|<<=[^ \n])/) do
        put_error_sign("<<=", line_nb)
      end
      # No space after
      line.scan(/([^!]! )/) do
        put_error_sign("!", line_nb)
      end
      line.scan(/([^a-zA-Z0-9]sizeof )/) do
        put_error_sign("sizeof", line_nb)
      end
      line.scan(/([^a-zA-Z)]\+\+[^(*a-zA-Z])/) do
        put_error_sign("++", line_nb)
      end
      line.scan(/([^a-zA-Z)]--[^(*a-zA-Z])/) do
        put_error_sign("--", line_nb)
      end
      line_nb += 1
    end
  end

  def check_condition_assignment
    line_nb = 1
    @file.each_line do |line|
      line.scan(/(if.*[^&|=^><+\-*%\/!]=[^=].*==.*)|(if.*==.*[^&|=^><+\-*%\/!]=[^=].*)/) do
        msg_brackets = "[" + @file_path + ":" + line_nb.to_s + "]"
        msg_error = " Condition and assignment on the same line."
        puts(msg_brackets.bold.green + msg_error.bold)
      end
      line_nb += 1
    end
  end

end

class UpdateManager

  def initialize(script_path)
    path = File.dirname(script_path)
    @script_path = script_path
    @remote = system("curl -s https://raw.githubusercontent.com/ronanboiteau/NormEZ/master/NormEZ.rb > #{path}/remote")
    @remote_path = "#{path}/remote"
    @backup_path = "#{path}/backup"
  end

  def clean_update_files
    system("rm -rf #{@backup_path}")
    system("rm -rf #{@remote_path}")
  end

  def can_update
    if not @remote
      clean_update_files
      return false
    end
    @current = %x(cat #{@script_path} | grep 'NormEZ_v' | cut -c 11- | head -1 | tr -d '.')
    @latest = %x(cat #{@remote_path} | grep 'NormEZ_v' | cut -c 11- | head -1 | tr -d '.')
    @latest_disp = %x(cat #{@remote_path} | grep 'NormEZ_v' | cut -c 11- | head -1)
    if @current < @latest
      return true
    end
    clean_update_files
    false
  end

  def update
    if @current < @latest
      update_msg = %x(cat #{@remote_path} | grep 'Changelog: ' | cut -c 14- | head -1 | tr -d '.')
      print("A new version is available: NormEZ v#{@latest_disp}".bold.yellow)
      print(" => Changelog: ".bold)
      print("#{update_msg}".bold.blue)
      response = nil
      Kernel.loop do
        print("Update NormEZ? [Y/n]: ")
        response = gets.chomp
        break if ["N", "n", "no", "Y", "y", "yes", ""].include?(response)
      end
      if ["N", "n", "no"].include?(response)
        puts("Update skipped. You can also use the --no-update (or -u) option to prevent auto-updating.".bold.blue)
        clean_update_files
        return
      end
      puts("Downloading update...")
      system("cat #{@script_path} > #{@backup_path}")
      exit_code = system("cat #{@remote_path} > #{@script_path}")
      if not exit_code
        print("Error while updating! Cancelling...".bold.red)
        system("cat #{@backup_path} > #{@script_path}")
        clean_update_files
        Kernel.exit(false)
      end
      clean_update_files
      puts("NormEZ has been successfully updated!".bold.green)
      Kernel.exit(true)
    end
  end

end

$options = {}
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: `ruby " + $0 + " [-ufmi]`"
  opts.on("-u", "--no-update", "Don't check for updates") do |o|
    $options[:noupdate] = o
  end
  opts.on("-f", "--ignore-files", "Ignore forbidden files") do |o|
    $options[:ignorefiles] = o
  end
  opts.on("-m", "--ignore-functions", "Ignore forbidden functions") do |o|
    $options[:ignorefunctions] = o
  end
  opts.on("-i", "--ignore-all", "Ignore forbidden files & forbidden functions (same as `-fm`)") do |o|
    $options[:ignorefiles] = o
    $options[:ignorefunctions] = o
  end
end

begin
  opt_parser.parse!
rescue OptionParser::InvalidOption => e
  puts("Error: " + e.to_s)
  puts(opt_parser.banner)
  Kernel.exit(false)
end
  
if !($options.include?(:noupdate))
  updater = UpdateManager.new($0)
  if updater.can_update
    updater.update
  end
end

files_retriever = FilesRetriever.new
while (next_file = files_retriever.get_next_file)
  CodingStyleChecker.new(next_file)
end

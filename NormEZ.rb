#!/usr/bin/ruby
# NormEZ_v2.0.0
# Changelog: Add support for Haskell + Add coding style infraction codes to the output

require 'optparse'
require 'tmpdir'

class String
  def each_char
    split('').each { |i| yield i }
  end

  def add_style(color_code)
    if $options.include? :colorless
      self
    else
      "\e[#{color_code}m#{self}\e[0m"
    end
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
  UNKNOWN   = 0
  DIRECTORY = 1
  MAKEFILE  = 2
  HEADER    = 3
  SOURCE    = 4
  HSOURCE   = 5
end

class FileManager
  attr_accessor :path
  attr_accessor :type

  def initialize(path, type)
    @path = path
    @type = type
    @type = file_type if @type == FileType::UNKNOWN
  end

  def file_type
    @type = if @path =~ /Makefile$/
              FileType::MAKEFILE
            elsif @path =~ /[.]h$/
              FileType::HEADER
            elsif @path =~ /[.]c$/
              FileType::SOURCE
            elsif @path =~ /[.]hs$/
              FileType::HSOURCE
            else
              FileType::UNKNOWN
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
  @@ignore = nil

  def initialize
    @files = ARGV.select { |f| File.file? f }
    @files = Dir['**/*'].select { |f| File.file? f } if @files.count.zero?

    if File.file?('.gitignore')
      gitignore = FileManager.new('.gitignore', FileType::UNKNOWN).get_content
      gitignore.gsub!(/\r\n?/, "\n")
      @@ignore = []
      gitignore.each_line do |line|
        line.start_with?('#') && line !~ /^\s*$/ || @@ignore.push(line.chomp)
      end
    end
    @nb_files = @files.size
    @idx_files = 0

    @dirs = Dir['**/*'].select { |d| File.directory? d }
    @nb_dirs = @dirs.size
    @idx_dirs = 0
  end

  def is_ignored_file(file)
    @@ignore.each do |ignored_file|
      if file.include?(ignored_file) || file.include?(ignored_file.tr('*', ''))
        return true
      end
    end
    false
  end

  def get_next_file
    if @idx_files < @nb_files
      file = FileManager.new(@files[@idx_files], FileType::UNKNOWN)
      @idx_files += 1
      file = get_next_file if !@@ignore.nil? && is_ignored_file(file.path)
      return file
    elsif @idx_dirs < @nb_dirs
      file = FileManager.new(@dirs[@idx_dirs], FileType::DIRECTORY)
      @idx_dirs += 1
      file = get_next_file if !@@ignore.nil? && is_ignored_file(file.path)
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
    if (@type != FileType::UNKNOWN) && (@type != FileType::DIRECTORY)
      @file = file_manager.get_content
    end
    check_file
  end

  def check_file
    if @type == FileType::UNKNOWN
      unless $options.include? :ignorefiles
        msg_brackets = "[#{@file_path}]"
        msg_error = ' This is probably a forbidden file. You might not want to commit it.'
        puts(msg_brackets.bold.red + msg_error.bold + ' (O1)'.grey)
      end
      return
    end
    if @type == FileType::DIRECTORY
      check_dirname
      return
    end
    check_trailing_spaces_tabs
    @type == FileType::HSOURCE || check_indentation
    if @type != FileType::MAKEFILE
      check_too_many_columns
      check_comma_missing_space
      if @type == FileType::SOURCE || @type == FileType::HEADER
        check_filename_c
        check_header
        check_several_assignments
        check_forbidden_keyword_func
        check_too_many_else_if
        check_empty_parenthesis
        check_too_many_parameters
        check_space_after_keywords
        check_misplaced_pointer_symbol
        check_operators_spaces
        check_misplaced_comments
        check_condition_assignment
      end
      if @type == FileType::SOURCE
        check_too_broad_filename
        check_functions_per_file
        check_function_lines_c
        check_empty_line_between_functions
      end
      if @type == FileType::HSOURCE
        check_filename_hs
        check_function_lines_hs
        check_conditional_branching
        check_mutable_variables
        check_bindings
        check_guards
        check_useless_do
      end
      @type == FileType::HEADER && check_macro_used_as_constant
    else
      check_header_makefile
    end
  end

  def check_dirname
    filename = File.basename(@file_path)
    return if filename =~ /^[a-z0-9]+([a-z0-9_]+[a-z0-9]+)*$/

    msg_brackets = "[#{@file_path}]"
    msg_error = ' Directory names should respect the snake_case naming convention.'
    puts(msg_brackets.bold.red + msg_error.bold + ' (O4)'.grey)
  end

  def check_filename_c
    filename = File.basename(@file_path)
    return if filename =~ /^[a-z0-9]+([a-z0-9_]+[a-z0-9]+)*[.][ch]$/

    msg_brackets = "[#{@file_path}]"
    msg_error = ' Filenames should respect the snake_case naming convention.'
    puts(msg_brackets.bold.red + msg_error.bold + ' (O4)'.grey)
  end

  def check_filename_hs
    filename = File.basename(@file_path)
    return if filename =~ /^([A-Z][a-z0-9]+)+[.]hs$/

    msg_brackets = "[#{@file_path}]"
    msg_error = ' Filenames should respect the UpperCamelCase naming convention.'
    puts(msg_brackets.bold.red + msg_error.bold + ' (O4)'.grey)
  end

  def check_too_many_columns
    line_nb = 1
    @file.each_line do |line|
      length = 0
      line.each_char do |char|
        length += char == "\t" ? 8 : 1
      end
      if length - 1 > 80
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = " Too many columns (#{length - 1} > 80)."
        puts(msg_brackets.bold.red + msg_error.bold + ' (F3)'.grey)
      end
      line_nb += 1
    end
  end

  def check_too_broad_filename
    unless @file_path =~ %r{(.*/|^)(string.c|str.c|my_string.c|my_str.c|algorithm.c|my_algorithm.c|algo.c|my_algo.c|program.c|my_program.c|prog.c|my_prog.c)$}
      return
    end

    msg_brackets = "[#{@file_path}]"
    msg_error = ' Too broad filename. You should rename this file.'
    puts(msg_brackets.bold.red + msg_error.bold + ' (O4)'.grey)
  end

  def check_header
    return unless @file !~ %r{/\*\n\*\* EPITECH PROJECT, [0-9]{4}\n\*\* .*\n\*\* File description:\n(\*\* .*\n)+\*/\n.*}

    msg_brackets = "[#{@file_path}]"
    msg_error = ' Missing or corrupted header.'
    puts(msg_brackets.bold.red + msg_error.bold + ' (G1)'.grey)
  end

  def check_function_lines_c
    count = level = 0
    line_nb = function_start = 1
    @file.each_line do |line|
      case line
      when /{[ \t]*$/
        if level.zero?
          function_start = line_nb
          count = -1
        end
        level += 1
      when /^[ \t]*}[ \t]*$/
        level -= 1
        if level.zero? && (count > 20)
          msg_brackets = "[#{@file_path}: #{function_start}]"
          msg_error = " Function contains more than 20 lines (#{count} > 20)."
          puts(msg_brackets.bold.red + msg_error.bold + ' (F4)'.grey)
        end
      end
      count += 1
      line_nb += 1
    end
  end

  def check_function_lines_hs
    count = 0
    line_nb = function_start = 1
    @file.each_line do |line|
      if (line =~ /^[\t ]*$/ || line =~ /^[A-Za-z]/) && count > 10
        msg_brackets = "[#{@file_path}: #{function_start}]"
        msg_error = " Function contains more than 10 lines (#{count} > 10)."
        puts(msg_brackets.bold.red + msg_error.bold + ' (F1)'.grey)
      end
      if line =~ /^[A-Za-z]/
        function_start = line_nb
        count = 0
      end
      line =~ /^[ \t]/ && count += 1
      line_nb += 1
    end
    return unless count > 10

    msg_brackets = "[#{@file_path}: #{function_start}]"
    msg_error = " Function contains more than 10 lines (#{count} > 10)."
    puts(msg_brackets.bold.red + msg_error.bold + ' (F1)'.grey)
  end

  def check_conditional_branching
    line_nb = 1
    @file.each_line do |line|
      if line =~ /[\t ]if[\t ].+[\t ]if[\t ]/ || line =~ /[\t ]else[\t ].+[\t ]if[\t ]/
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = " Nested 'if' statements are strictly forbidden."
        puts(msg_brackets.bold.red + msg_error.bold + ' (C1)'.grey)
      end
      line_nb += 1
    end
  end

  def check_guards
    line_nb = 1
    new_guard = true
    @file.each_line do |line|
      if line =~ /[\t ]\|[\t ].*==/ && new_guard
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Can this guard be expressed as a pattern matching?'
        puts(msg_brackets.bold.yellow + msg_error.bold + ' (C2)'.grey)
        new_guard = false
      end
      line =~ /^$/ && new_guard = true
      line_nb += 1
    end
  end

  def check_useless_do
    line_nb = 1
    in_do_block = false
    useless = true
    @file.each_line do |line|
      case line
      when /\sdo\s/
        in_do_block = true
      when /\s<-\s/
        in_do_block && useless = false
      when /^$/
        if useless && in_do_block
          msg_brackets = "[#{@file_path}:#{line_nb}]"
          msg_error = " the 'do' notation is forbidden unless it contains a generator: '<-'"
          puts(msg_brackets.bold.red + msg_error.bold + ' (D1)'.grey)
        end
        in_do_block = false
        useless = true
      end
      line_nb += 1
    end
    return unless useless && in_do_block

    msg_brackets = "[#{@file_path}:#{line_nb}]"
    msg_error = " the 'do' notation is forbidden unless it contains a generator: '<-'"
    puts(msg_brackets.bold.red + msg_error.bold + ' (D1)'.grey)
  end

  def check_mutable_variables
    line_nb = 1
    @file.each_line do |line|
      if line =~ /(Data.IORef|Data.STRef|Control.Concurrent.STM.TVar)/
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Mutable variables are strictly forbidden.'
        puts(msg_brackets.bold.red + msg_error.bold + ' (M1)'.grey)
      end
      line_nb += 1
    end
  end

  def check_bindings
    line_nb = 1
    bound_functions = []
    @file.each_line do |line|
      case line
      when /^(type|class)/
        next
      when /^[A-Za-z].*::/
        bound_functions.push(line.split(' ')[0])
      when /^[A-Za-z].*=[^:]/
        unless bound_functions.include? line.split(' ')[0]
          msg_brackets = "[#{@file_path}:#{line_nb}]"
          msg_error = ' All top level bindings must have an accompanying type signature.'
          puts(msg_brackets.bold.red + msg_error.bold + ' (T1)'.grey)
        end
      end
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
        assignments += 1 if char == ';'
      end
      if assignments > 1
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Several assignments on the same line.'
        puts(msg_brackets.bold.red + msg_error.bold + ' (L5)'.grey)
      end
      line_nb += 1
    end
  end

  def check_forbidden_keyword_func
    line_nb = 1
    @file.each_line do |line|
      line.scan(/(^|[^0-9a-zA-Z_])(printf|dprintf|fprintf|vprintf|sprintf|snprintf|vprintf|vfprintf|vsprintf|vsnprintf|asprintf|scranf|memcpy|memset|memmove|strcat|strchar|strcpy|atoi|strlen|strstr|strncat|strncpy|strcasestr|strncasestr|strcmp|strncmp|strtok|strnlen|strdup|realloc)[^0-9a-zA-Z]/) do
        unless $options.include? :ignorefunctions
          msg_brackets = "[#{@file_path}:#{line_nb}]"
          msg_error = " Are you sure that this function is allowed: '".bold
          msg_error += Regexp.last_match(2).bold.red
          msg_error += "'?".bold
          puts(msg_brackets.bold.red + msg_error)
        end
      end
      line.scan(/(^|[^0-9a-zA-Z_])(goto)[^0-9a-zA-Z]/) do
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = " Are you sure that this keyword is allowed: '".bold
        msg_error += Regexp.last_match(2).bold.red
        msg_error += "'?".bold
        puts(msg_brackets.bold.red + msg_error)
      end
      line_nb += 1
    end
  end

  def check_too_many_else_if
    line_nb = condition_start = previous_condition_start = 1
    count = 0
    @file.each_line do |line|
      line[0] = '' while [' ', "\t"].include?(line[0])
      if line =~ /^if ?\(/
        condition_start = line_nb
        count = 1
      elsif line =~ /^else if ?\(/ || line =~ /^else ?\(/
        count += 1
        if count > 3 && previous_condition_start != condition_start
          msg_brackets = "[#{@file_path}: #{condition_start}]"
          msg_error = ' Too many "else if" statements.'
          puts(msg_brackets.bold.green + msg_error.bold + ' (C1)'.grey)
          previous_condition_start = condition_start
        end
      end
      line_nb += 1
    end
  end

  def check_trailing_spaces_tabs
    line_nb = 1
    @file.each_line do |line|
      case line
      when / $/
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Trailing space(s) at the end of the line.'
        puts(msg_brackets.bold.green + msg_error.bold)
      when /\t$/
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Trailing tabulation(s) at the end of the line.'
        puts(msg_brackets.bold.green + msg_error.bold)
      end
      line_nb += 1
    end
  end

  def check_indentation
    line_nb = 1
    if @type == FileType::MAKEFILE
      valid_indent = '\t'
      bad_indent_regexp = /^ +.*$/
      bad_indent_name = 'space'
    else
      valid_indent = ' '
      bad_indent_regexp = /^\t+.*$/
      bad_indent_name = 'tabulation'
    end
    @file.each_line do |line|
      indent = 0
      while line[indent] == valid_indent
        indent += 1
      end
      if line =~ bad_indent_regexp
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = " Wrong indentation: #{bad_indent_name}s are not allowed."
        puts(msg_brackets.bold.green + msg_error.bold + ' (L2)'.grey)
      elsif indent % 4 != 0
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Wrong indentation.'
        puts(msg_brackets.bold.green + msg_error.bold + ' (L2)'.grey)
      end
      line_nb += 1
    end
  end

  def check_functions_per_file
    functions = 0
    @file.each_line do |line|
      functions += 1 if line =~ /^{/
    end
    return unless functions > 5

    msg_brackets = "[#{@file_path}]"
    msg_error = " More than 5 functions in the same file (#{functions} > 5)."
    puts(msg_brackets.bold.red + msg_error.bold + ' (O3)'.grey)
  end

  def check_empty_parenthesis
    line_nb = 1
    missing_bracket = false
    @file.each_line do |line|
      if missing_bracket
        if line =~ /^{$/
          msg_brackets = "[#{@file_path}:#{line_nb}]"
          msg_error = " This function takes no parameter, it should take 'void' as argument."
          puts(msg_brackets.bold.red + msg_error.bold + ' (F5)'.grey)
        elsif line !~ /^[\t ]*$/
          missing_bracket = false
        end
      elsif line =~ /\(\)[\t ]*{$/
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = " This function takes no parameter, it should take 'void' as argument."
        puts(msg_brackets.bold.red + msg_error.bold + ' (F5)'.grey)
      elsif line =~ /\(\)[ \t]*$/
        missing_bracket = true
      end
      line_nb += 1
    end
  end

  def check_too_many_parameters
    @file.scan(/\(([^(),]*,){4,}[^()]*\)[ \t\n]+{/).each do |_match|
      msg_brackets = "[#{@file_path}]"
      msg_error = " Function shouldn't take more than 4 arguments."
      puts(msg_brackets.bold.red + msg_error.bold + ' (F5)'.grey)
    end
  end

  def check_space_after_keywords
    line_nb = 1
    @file.each_line do |line|
      line.scan(/(return|if|else if|else|while|for)\(/) do |match|
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = " Missing space after keyword '#{match[0]}'."
        puts(msg_brackets.bold.green + msg_error.bold + ' (L3)'.grey)
      end
      line_nb += 1
    end
  end

  def check_misplaced_pointer_symbol
    line_nb = 1
    @file.each_line do |line|
      line.scan(/([^(\t ]+_t|int|signed|unsigned|char|long|short|float|double|void|const|struct [^ ]+)\*/) do |match|
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = " Misplaced pointer symbol after '#{match[0]}'."
        puts(msg_brackets.bold.green + msg_error.bold + ' (V3)'.grey)
      end
      line_nb += 1
    end
  end

  def check_macro_used_as_constant
    line_nb = 1
    @file.each_line do |line|
      if line =~ /#define [^ ]+ [0-9]+([.][0-9]+)?/
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Macros should not be used for constants.'
        puts(msg_brackets.bold.green + msg_error.bold + ' (H3)'.grey)
      end
      line_nb += 1
    end
  end

  def check_header_makefile
    return if @file != /##\n## EPITECH PROJECT, [0-9]{4}\n## .*\n## File description:\n## .*\n##\n.*/

    msg_brackets = "[#{@file_path}]"
    msg_error = ' Missing or corrupted header.'
    puts(msg_brackets.bold.red + msg_error.bold + ' (G1)'.grey)
  end

  def check_misplaced_comments
    level = 0
    line_nb = 1
    @file.each_line do |line|
      level += line.count '{'
      level -= line.count '}'
      if (level != 0) && (line =~ %r{/\*} || line =~ %r{//})
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Comment inside a function.'
        puts(msg_brackets.bold.green + msg_error.bold + ' (F6)'.grey)
      end
      line_nb += 1
    end
  end

  def check_comma_missing_space
    line_nb = 1
    @file.each_line do |line|
      line.scan(/,[^ \n]/) do
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Missing space after comma.'
        puts(msg_brackets.bold.green + msg_error.bold + ' (L3)'.grey)
      end
      line_nb += 1
    end
  end

  def put_error_sign(sign, line_nb)
    msg_brackets = "[#{@file_path}:#{line_nb}]"
    msg_error = " Misplaced space(s) around '#{sign}' sign."
    puts(msg_brackets.bold.green + msg_error.bold + ' (L3)'.grey)
  end

  def check_operators_spaces
    line_nb = 1
    @file.each_line do |line|
      # A space on both ends
      line.scan(%r{([^\t&|=^><+\-*%/! ]=[^=]|[^&|=^><+\-*%/!]=[^= \n])}) do
        put_error_sign('=', line_nb)
      end
      line.scan(/([^\t ]==|==[^ \n])/) do
        put_error_sign('==', line_nb)
      end
      line.scan(/([^\t ]!=|!=[^ \n])/) do
        put_error_sign('!=', line_nb)
      end
      line.scan(/([^\t <]<=|[^<]<=[^ \n])/) do
        put_error_sign('<=', line_nb)
      end
      line.scan(/([^\t >]>=|[^>]>=[^ \n])/) do
        put_error_sign('>=', line_nb)
      end
      line.scan(/([^\t ]&&|&&[^ \n])/) do
        put_error_sign('&&', line_nb)
      end
      line.scan(/([^\t ]\|\||\|\|[^ \n])/) do
        put_error_sign('||', line_nb)
      end
      line.scan(/([^\t ]\+=|\+=[^ \n])/) do
        put_error_sign('+=', line_nb)
      end
      line.scan(/([^\t ]-=|-=[^ \n])/) do
        put_error_sign('-=', line_nb)
      end
      line.scan(/([^\t ]\*=|\*=[^ \n])/) do
        put_error_sign('*=', line_nb)
      end
      line.scan(%r{([^\t ]/=|/=[^ \n])}) do
        put_error_sign('/=', line_nb)
      end
      line.scan(/([^\t ]%=|%=[^ \n])/) do
        put_error_sign('%=', line_nb)
      end
      line.scan(/([^\t ]&=|&=[^ \n])/) do
        put_error_sign('&=', line_nb)
      end
      line.scan(/([^\t ]\^=|\^=[^ \n])/) do
        put_error_sign('^=', line_nb)
      end
      line.scan(/([^\t ]\|=|\|=[^ \n])/) do
        put_error_sign('|=', line_nb)
      end
      line.scan(/([^\t |]\|[^|]|[^|]\|[^ =|\n])/) do
        # Minifix for Matchstick
        line.scan(/([^']\|[^'])/) do
          put_error_sign('|', line_nb)
        end
      end
      line.scan(/([^\t ]\^|\^[^ =\n])/) do
        put_error_sign('^', line_nb)
      end
      line.scan(/([^\t ]>>[^=]|>>[^ =\n])/) do
        put_error_sign('>>', line_nb)
      end
      line.scan(/([^\t ]<<[^=]|<<[^ =\n])/) do
        put_error_sign('<<', line_nb)
      end
      line.scan(/([^\t ]>>=|>>=[^ \n])/) do
        put_error_sign('>>=', line_nb)
      end
      line.scan(/([^\t ]<<=|<<=[^ \n])/) do
        put_error_sign('<<=', line_nb)
      end
      # No space after
      line.scan(/([^!]! )/) do
        put_error_sign('!', line_nb)
      end
      line.scan(/([^a-zA-Z0-9]sizeof )/) do
        put_error_sign('sizeof', line_nb)
      end
      line.scan(/([^a-zA-Z)\]]\+\+[^(\[*a-zA-Z])/) do
        put_error_sign('++', line_nb)
      end
      line.scan(/([^a-zA-Z)\]]--[^\[(*a-zA-Z])/) do
        put_error_sign('--', line_nb)
      end
      line_nb += 1
    end
  end

  def check_condition_assignment
    line_nb = 1
    @file.each_line do |line|
      line.scan(%r{(if.*[^&|=^><+\-*%/!]=[^=].*==.*)|(if.*==.*[^&|=^><+\-*%/!]=[^=].*)}) do
        msg_brackets = "[#{@file_path}:#{line_nb}]"
        msg_error = ' Condition and assignment on the same line.'
        puts(msg_brackets.bold.green + msg_error.bold + ' (L1)'.grey)
      end
      line_nb += 1
    end
  end

  def check_empty_line_between_functions
    @file.scan(/\n{3,}^[^ \n\t]+ [^ \n\t]+\([^\n\t]*\)/).each do |_match|
      msg_brackets = "[#{@file_path}]"
      msg_error = ' Too many empty lines between functions.'
      puts(msg_brackets.bold.green + msg_error.bold + ' (G2)'.grey)
    end
    @file.scan(/[^\n]\n^[^ \n\t]+ [^ \n\t]+\([^\n\t]*\)/).each do |_match|
      msg_brackets = "[#{@file_path}]"
      msg_error = ' Missing empty line between functions.'
      puts(msg_brackets.bold.green + msg_error.bold + ' (G2)'.grey)
    end
  end
end

class UpdateManager
  def initialize(script_path)
    path = File.dirname(script_path)
    tmp_dir = Dir.tmpdir
    @script_path = script_path
    @remote_path = "#{tmp_dir}/__normez_remote"
    @backup_path = "#{tmp_dir}/__normez_backup"
    @remote = system("curl -s https://raw.githubusercontent.com/ronanboiteau/NormEZ/master/NormEZ.rb > #{@remote_path}")
  end

  def clean_update_files
    system("rm -rf #{@backup_path}")
    system("rm -rf #{@remote_path}")
  end

  def can_update
    unless @remote
      clean_update_files
      return false
    end
    @current = `cat #{@script_path} | grep 'NormEZ_v' | cut -c 11- | head -1 | tr -d '.'`
    @latest = `cat #{@remote_path} | grep 'NormEZ_v' | cut -c 11- | head -1 | tr -d '.'`
    @latest_disp = `cat #{@remote_path} | grep 'NormEZ_v' | cut -c 11- | head -1`
    return true if @current < @latest

    clean_update_files
    false
  end

  def update
    return unless @current < @latest

    update_msg = `cat #{@remote_path} | grep 'Changelog: ' | cut -c 14- | head -1 | tr -d '.'`
    print("A new version is available: NormEZ v#{@latest_disp}".bold.yellow)
    print(' => Changelog: '.bold)
    print(update_msg.to_s.bold.blue)
    response = nil
    Kernel.loop do
      print('Update NormEZ? [Y/n]: ')
      response = gets.chomp
      break if ['N', 'n', 'no', 'Y', 'y', 'yes', ''].include?(response)
    end
    if %w[N n no].include?(response)
      puts('Update skipped. You can also use the --no-update (or -u) option to prevent auto-updating.'.bold.blue)
      clean_update_files
      return
    end
    puts('Downloading update...')
    system("cat #{@script_path} > #{@backup_path}")
    exit_code = system("cat #{@remote_path} > #{@script_path}")
    unless exit_code
      print('Error while updating! Cancelling...'.bold.red)
      system("cat #{@backup_path} > #{@script_path}")
      clean_update_files
      Kernel.exit(false)
    end
    clean_update_files
    puts('NormEZ has been successfully updated!'.bold.green)
    Kernel.exit(true)
  end
end

$options = {}
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: `ruby #{$PROGRAM_NAME} [-ufmi]`"
  opts.on('-u', '--no-update', "Don't check for updates") do |o|
    $options[:noupdate] = o
  end
  opts.on('-f', '--ignore-files', 'Ignore forbidden files') do |o|
    $options[:ignorefiles] = o
  end
  opts.on('-m', '--ignore-functions', 'Ignore forbidden functions') do |o|
    $options[:ignorefunctions] = o
  end
  opts.on('-i', '--ignore-all', 'Ignore forbidden files & forbidden functions (same as `-fm`)') do |o|
    $options[:ignorefiles] = o
    $options[:ignorefunctions] = o
  end
  opts.on('-c', '--colorless', 'Disable output styling') do |o|
    $options[:colorless] = o
  end
end

begin
  opt_parser.parse!
rescue OptionParser::InvalidOption => e
  puts("Error: #{e}")
  puts(opt_parser.banner)
  Kernel.exit(false)
end

unless $options.include?(:noupdate)
  updater = UpdateManager.new($PROGRAM_NAME)
  updater.update if updater.can_update
end

files_retriever = FilesRetriever.new
while (next_file = files_retriever.get_next_file)
  CodingStyleChecker.new(next_file)
end

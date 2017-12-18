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

class ArgumentsManager

  def initialize
    @files = Dir['**/*.c'] + Dir['**/*.h']
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

end

class CodingStyleChecker

  def initialize(file_manager)
    @file_path = file_manager.path
    @file = file_manager.get_content
    check_file
  end

  def check_file
    check_too_many_columns
  end

  def check_too_many_columns
    line_nb = 1
    @file.each_line do |line|
      if line.length - 1 > 80
        puts "[" + @file_path + ":" + line_nb.to_s + "] Too many columns (" + (line.length - 1).to_s + " > 80)"
      end
      line_nb += 1
    end
  end

end

arg_manager = ArgumentsManager.new
while (next_file = arg_manager.get_next_file)
  CodingStyleChecker.new(next_file)
end

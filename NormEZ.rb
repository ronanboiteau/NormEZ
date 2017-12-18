class ArgumentsManager

  def initialize(args)
    @args = args
    @index = 0
  end

  def get_next_file
    if @index >= @args.length
      return nil
    end
    file = File.open(@args[@index])
    content = file.read
    file.close
    @index += 1
    content
  end

end

class CodingStyleChecker

  def initialize(file_content)
    @file = file_content
    check_file
  end

  def check_file
    idx = 0
    @file.each_line do |line|
      if line.length > 80
        puts "[Line " + idx.to_s + "] " + "Too many columns (> 80)"
      end
      idx += 1
    end
  end

end

arg_manager = ArgumentsManager.new(ARGV)
while (next_file = arg_manager.get_next_file)
  CodingStyleChecker.new(next_file)
end


# puts ARGV.length
# ARGV.each do |arg|
#   puts "Argument: #{arg}"
# end

# file = File.open("test.c","r")
# puts file.read()
# file.close()

require "csv"

class Main

  MATCH_TYPE = {
    email_address: 1,
    phone_number: 2,
    email_address_and_phone_number: 3
  }.freeze
  MATCH_TYPE.values.each(&:freeze) # Freeze the values as well
    
  def self.run
      puts "=== Matching Program ==="
      file_path = prompt_for_file_path()
      match_type = prompt_for_match_type()

      lines = read_file_lines(file_path, match_type)     
  end

  def self.get_phone_number_from_string(phone_string)
    return nil if phone_string.nil?
    phone_string.gsub(/[^0-9]/, '')
  end

  def self.add_to_hash(row, header_indices, my_hash, is_email, row_index)
    header_indices.each do |i|
      return if row[i].nil?
      key = row[i].strip.downcase

      if (is_email == false) 
        key = get_phone_number_from_string(key)
      end

      return if key.empty?

      if my_hash[key].nil?
        my_hash[key] = [ row_index ]
      else
        my_hash[key] << row_index
      end
    end
  end

  def self.read_file_lines(file_path, match_type)
    my_email_hash = {}
    my_phone_hash = {}
    lines = []
    email_header_indices = []
    phone_number_header_indices = []
    CSV.foreach(file_path).with_index do |row, i|
      if email_header_indices.empty? && phone_number_header_indices.empty?
        email_header_indices = row.each_index.select { |j| row[j].downcase.include?("email") }
        phone_number_header_indices = row.each_index.select { |j| row[j].downcase.include?("phone") }
        puts "Email header indices: #{email_header_indices}"
        puts "Phone number header indices: #{phone_number_header_indices}"
      else
        case match_type
        when MATCH_TYPE[:email_address]
          add_to_hash(row, email_header_indices, my_email_hash, true, i)
        when MATCH_TYPE[:phone_number]
          add_to_hash(row, phone_number_header_indices, my_phone_hash, false, i)
        when MATCH_TYPE[:email_address_and_phone_number]
          add_to_hash(row, email_header_indices, my_email_hash, true, i)
          add_to_hash(row, phone_number_header_indices, my_phone_hash, false, i)
        end
      end
      lines << row
    end
    puts "Email Hash: #{my_email_hash}"
    puts "Phone Hash: #{my_phone_hash}"
    lines
  end

  def self.prompt_for_file_path
    loop do
      print "Enter the path to the input file: "
      file_path = gets&.strip
      file_path = File.expand_path(file_path)

      return file_path if file_path && File.exist?(file_path)

      puts "File not found. Please try again."
    end
  end

  def self.prompt_for_match_type
    puts
    puts "Select the matching type:"
    puts "  1) Email Address"
    puts "  2) Phone Number"
    puts "  3) Email OR Phone Number"

    loop do
      print "Enter choice (1-3): "
      input = gets&.strip

      return input.to_i if %w[1 2 3].include?(input)

      puts "Invalid choice. Please enter 1, 2, or 3."
    end
  end
end


Main.run if __FILE__ == $0
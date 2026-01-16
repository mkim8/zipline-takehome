require "csv"
require_relative "union_find"

class Main

  MATCH_TYPE = {
    email_address: 1,
    phone_number: 2,
    email_address_and_phone_number: 3
  }.freeze
    
  def self.run
    # INPUT
    puts "=== Matching Program ==="
    puts
    file_path = prompt_for_file_path()
    match_type = prompt_for_match_type()

    # PROCESSING
    union_find = read_file_lines(file_path, match_type)     
    
    # OUTPUT
    generate_new_csv(file_path, union_find)
  end

  def self.generate_new_csv(file_path, union_find)
    output_file_path = file_path.sub(/(\.\w+)?$/, '_copy\1')
    CSV.open(output_file_path, 'w') do |csv|
      root_index_to_unique_id = {}
      next_unique_id = 1
      CSV.foreach(file_path).with_index do |row, i|
        if i == 0
          header = ['Unique ID'] + row
          csv << header
        else
          root_index = union_find.find_root(i)
          if root_index_to_unique_id[root_index].nil?
            root_index_to_unique_id[root_index] = next_unique_id
            next_unique_id += 1
          end
          unique_id = root_index_to_unique_id[root_index]
          csv << [unique_id] + row 
        end
      end
    end
    puts
    puts "Output written to: #{output_file_path}"
    puts
  end

  def self.get_phone_number_from_string(phone_string)
    return nil if phone_string.nil?
    phone_string.gsub(/[^0-9]/, '')
  end

  def self.determine_first_seen_row_index_for_keys_in_row( keys_header_indices, row, email_or_phone_number_type, row_index, union_find, first_row_seen_for_key)
    keys_header_indices.each do |i|
      next if row[i].nil?
      key = row[i].to_s.strip.downcase

      if (email_or_phone_number_type == MATCH_TYPE[:phone_number]) 
        key = get_phone_number_from_string(key)
      end

      next if key.empty?

      if first_row_seen_for_key[key].nil?
        first_row_seen_for_key[key] = row_index
      else 
        union_find.union(first_row_seen_for_key[key], row_index)
      end
    end
    union_find
  end

  def self.read_file_lines(file_path, match_type)
    email_header_indices = []
    phone_number_header_indices = []
    union_find = UnionFind.new
    first_row_seen_for_key = {}
    CSV.foreach(file_path).with_index do |row, i|
      if i == 0
        email_header_indices = row.each_index.select { |j| row[j]&.downcase&.include?("email") }
        phone_number_header_indices = row.each_index.select { |j| row[j]&.downcase&.include?("phone") }
      else
        case match_type
        when MATCH_TYPE[:email_address]
          union_find = determine_first_seen_row_index_for_keys_in_row( email_header_indices, row, MATCH_TYPE[:email_address], i,  union_find, first_row_seen_for_key)
        when MATCH_TYPE[:phone_number]
          union_find = determine_first_seen_row_index_for_keys_in_row( phone_number_header_indices, row, MATCH_TYPE[:phone_number], i,  union_find, first_row_seen_for_key)
        when MATCH_TYPE[:email_address_and_phone_number]
          union_find = determine_first_seen_row_index_for_keys_in_row( email_header_indices, row, MATCH_TYPE[:email_address], i,  union_find, first_row_seen_for_key)
          union_find = determine_first_seen_row_index_for_keys_in_row( phone_number_header_indices, row, MATCH_TYPE[:phone_number], i,  union_find, first_row_seen_for_key)
        end
          
      end
    end
    union_find
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
    puts

    loop do
      print "Enter choice (1-3): "
      input = gets&.strip

      return input.to_i if %w[1 2 3].include?(input)

      puts "Invalid choice. Please enter 1, 2, or 3."
    end
  end
end


Main.run if __FILE__ == $0
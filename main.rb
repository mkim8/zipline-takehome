require "csv"
require "set"

class Main

  MATCH_TYPE = {
    email_address: 1,
    phone_number: 2,
    email_address_and_phone_number: 3
  }.freeze
  MATCH_TYPE.values.each(&:freeze) # Freeze the values as well
    
  def self.run
    # INPUT
    puts "=== Matching Program ==="
    file_path = prompt_for_file_path()
    match_type = prompt_for_match_type()

    # PROCESSING
    my_hash, lines = read_file_lines(file_path, match_type)     
    row_index_to_unique_id_hash, last_index = determine_unique_ids(my_hash, match_type) 
    
    # OUTPUT
    generate_new_csv(file_path, lines, row_index_to_unique_id_hash, last_index)
  end

  def self.generate_new_csv(file_path, lines, row_index_to_unique_id_hash, last_index)
    output_file_path = file_path.sub(/(\.\w+)?$/, '_copy\1')
    CSV.open(output_file_path, 'w') do |csv|
      header = ['Unique ID'] + lines[0]
      csv << header
      lines.each_with_index do |row, i|
        if i == 0
          next
        end
        unique_id = row_index_to_unique_id_hash[i]
        if unique_id.nil?
            unique_id = last_index
            last_index += 1
        end
        csv << [unique_id] + row 
      end
    end
    puts "Output written to #{output_file_path}"
  end

  def self.determine_unique_ids(my_hash, match_type)
    row_index_to_matching_group = {}
    row_index_to_unique_id = {}
    row_index_to_matching_group = determine_matching_groups(my_hash)
    puts " Row index to matching group: #{row_index_to_matching_group}"

    unique_id = 1
    increment_unique_id = false
    row_index_to_matching_group.each do |row_index, matching_group|
      matching_group.each do |other_row_index|
        if row_index_to_unique_id[other_row_index].nil?
          row_index_to_unique_id[other_row_index] = unique_id
          increment_unique_id = true
        end
      end
      if increment_unique_id == true
        unique_id += 1
        increment_unique_id = false
      end
    end

    puts " Row index to unique ID: #{row_index_to_unique_id}"
    [ row_index_to_unique_id, unique_id]
  end

  def self.determine_matching_groups(my_hash)
    row_index_to_matching_group_hash = {}
    my_hash.each do |key, row_indices|
      if row_indices.length > 1
        current_set = Set.new(row_indices)
        row_indices.each do |row_index|
          if row_index_to_matching_group_hash[row_index].nil?
            row_index_to_matching_group_hash[row_index] = current_set
          else
                
            current_set = row_index_to_matching_group_hash[row_index].merge(current_set)
          end
        end
      end
    end
    row_index_to_matching_group_hash
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
    my_hash = {}
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
          add_to_hash(row, email_header_indices, my_hash, true, i)
        when MATCH_TYPE[:phone_number]
          add_to_hash(row, phone_number_header_indices, my_hash, false, i)
        when MATCH_TYPE[:email_address_and_phone_number]
          add_to_hash(row, email_header_indices, my_hash, true, i)
          add_to_hash(row, phone_number_header_indices, my_hash, false, i)
        end
      end
      lines << row
    end
    puts " Hash: #{my_hash}"
    [ my_hash, lines ]
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
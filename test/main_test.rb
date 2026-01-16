require_relative 'test_helper'

class MainTest < Minitest::Test
  def write_temp_csv(contents)
    f = Tempfile.new(['input', '.csv'])
    f.write(contents)
    f.flush
    f
  end

  def read_csv(path)
    CSV.read(path)
  end

  def close_and_delete_tempfiles(file, output_path)
    file&.close
    file&.unlink
    File.delete(output_path) if output_path && File.exist?(output_path)
  end

  def test_email_matching_groups
    input = <<~CSV
      Email,Phone,Name
      a@test.com,,Alice
      a@test.com,,Alice2
      b@test.com,,Bob
    CSV

    file = write_temp_csv(input)

    uf = Main.read_file_lines(file.path, Main::MATCH_TYPE[:email_address])
    output_path = Main.generate_new_csv(file.path, uf)

    out = read_csv(output_path)

    # test "Unique ID" has been added to the header
    assert_equal ['Unique ID', 'Email', 'Phone', 'Name'], out[0]

    id1 = out[1][0]
    id2 = out[2][0]
    id3 = out[3][0]

    assert_equal id1, id2
    refute_equal id1, id3
  ensure
    close_and_delete_tempfiles(file, output_path)
  end

  def test_phone_number_matching_groups
    input = <<~CSV
      Email,Phone,Name
      a@test.com,123-456-7890,Alice
      a@test.com,,Alice2
      b@test.com,(123) 456-7890,Bob
    CSV

    file = write_temp_csv(input)

    uf = Main.read_file_lines(file.path, Main::MATCH_TYPE[:phone_number])
    output_path = Main.generate_new_csv(file.path, uf)

    out = read_csv(output_path)

    id1 = out[1][0]
    id2 = out[2][0]
    id3 = out[3][0]

    assert_equal id1, id3
    refute_equal id1, id2
  ensure
    close_and_delete_tempfiles(file, output_path)
  end

  def test_email_or_phone_indirect_link
    input = <<~CSV
      Email,Phone,Name
      a@test.com,,Row1
      a@test.com,6045551234,Row2
      ,6045551234,Row3
    CSV

    file = write_temp_csv(input)

    uf = Main.read_file_lines(file.path, Main::MATCH_TYPE[:email_address_and_phone_number])
    output_path = Main.generate_new_csv(file.path, uf)

    out = read_csv(output_path)

    id1 = out[1][0]
    id2 = out[2][0]
    id3 = out[3][0]

    assert_equal id1, id2
    assert_equal id2, id3
  ensure
    close_and_delete_tempfiles(file, output_path)
  end
end

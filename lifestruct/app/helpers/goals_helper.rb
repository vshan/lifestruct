module GoalsHelper

  def format_datetime(datetime)
    datetime.strftime("%b %e, %a, %l:%M %p")
  end

  def decode_rep_code(rep_code)
    decode_map = {"1" => "Monday",
                  "2" => "Tuesday",
                  "3" => "Wednesday",
                  "4" => "Thursday",
                  "5" => "Friday",
                  "6" => "Saturday",
                  "7" => "Sunday",
                  "8" => "Month"}
    decoded_str = ""
    rep_code_len = rep_code.to_s.length
    index = 0
    rep_code.to_s.each_char do |char|
      index += 1
      if index == rep_code_len
        decoded_str = decoded_str + "and " + decode_map[char] + "."
      else 
        decoded_str = decoded_str + decode_map[char] + ", "
      end
    end
    decoded_str = (decode_map[rep_code.to_s] + ".") if rep_code_len == 1
    decoded_str
  end
end

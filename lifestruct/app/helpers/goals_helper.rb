module GoalsHelper

  def format_datetime(datetime)
    datetime.strftime("%b %e, %a, %l:%M %p")
  end

  def decode_rep_code(rep_code)
    decoded_str = ""
    rep_code_len = rep_code.to_s.length
    index = 0
    rep_code.to_s.each_char do |char|
      index += 1
      if index == rep_code_len
        decoded_str = decoded_str + "and " + Goal.DAY_MAP[char.to_i] + "."
      else 
        decoded_str = decoded_str + Goal.DAY_MAP[char.to_i] + ", "
      end
    end
    decoded_str = (Goal.DAY_MAP[rep_code] + ".") if rep_code_len == 1
    decoded_str
  end
end

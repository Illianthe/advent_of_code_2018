defmodule Day5 do
  def get_polymer(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)
    data |> String.trim()
  end

  def react(polymer) do
    pattern =
      ~r/aA|Aa|bB|Bb|cC|Cc|dD|Dd|eE|Ee|fF|Ff|gG|Gg|hH|Hh|iI|Ii|jJ|Jj|kK|Kk|lL|Ll|mM|Mm|nN|Nn|oO|Oo|pP|Pp|qQ|Qq|rR|Rr|sS|Ss|tT|Tt|uU|Uu|vV|Vv|wW|Ww|xX|Xx|yY|Yy|zZ|Zz/

    reacted_polymer = String.replace(polymer, pattern, "", [:global])

    if polymer === reacted_polymer,
      do: polymer |> String.to_charlist() |> Enum.count(),
      else: react(reacted_polymer)
  end
end

result1 = Day5.get_polymer() |> Day5.react()
IO.puts("Part 1: #{result1}")

# result2 = Day4.extract_records()
# IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day5Test do
  use ExUnit.Case
  import Day5

  test "react" do
    assert react("aa") == 2
    assert react("abBA") === 0
    assert react("aabAAB") === 6
    assert react("dabAcCaCBAcCcaDA") === 10
  end
end

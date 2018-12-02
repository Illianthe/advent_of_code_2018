defmodule ChronalCalibration do
  def calculate_resulting_frequency(frequency_changes) do
    frequency_changes
    |> Enum.sum()
  end

  def find_first_duplicate_frequency(frequency_changes) do
    find_duplicate_helper(frequency_changes)
  end

  def extract_frequency_changes_from_file(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)

    data
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp find_duplicate_helper(list, index \\ 0, acc \\ 0, found \\ %{0 => true}) do
    next_index = if index == length(list) - 1, do: 0, else: index + 1
    next_acc = acc + Enum.at(list, index)
    next_found = Map.put(found, next_acc, true)

    cond do
      found[next_acc] ->
        next_acc

      true ->
        find_duplicate_helper(list, next_index, next_acc, next_found)
    end
  end
end

IO.puts(
  "Part 1: #{
    ChronalCalibration.extract_frequency_changes_from_file()
    |> ChronalCalibration.calculate_resulting_frequency()
  }"
)

IO.puts(
  "Part 2: #{
    ChronalCalibration.extract_frequency_changes_from_file()
    |> ChronalCalibration.find_first_duplicate_frequency()
  }"
)

IO.puts("\n----------\n")

ExUnit.start()

defmodule ChronalCalibrationTest do
  use ExUnit.Case
  import ChronalCalibration

  test "calculate_resulting_frequency" do
    assert calculate_resulting_frequency([+1, +1, +1]) == 3
    assert calculate_resulting_frequency([+1, +1, -2]) == 0
    assert calculate_resulting_frequency([-1, -2, -3]) == -6
  end

  test "find_first_duplicate_frequency" do
    assert find_first_duplicate_frequency([+1, -1]) == 0
    assert find_first_duplicate_frequency([+3, +3, +4, -2, -4]) == 10
    assert find_first_duplicate_frequency([-6, +3, +8, +5, -6]) == 5
    assert find_first_duplicate_frequency([+7, +7, -2, -7, -4]) == 14
  end
end

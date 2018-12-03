defmodule Day3 do
  def extract_claims(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)
    data |> String.split("\n", trim: true)
  end

  def overlapping_squares(claims) do
    parsed_claims = Enum.map(claims, &parse_claim/1)

    parsed_claims
    |> Enum.map(&get_claimed_squares/1)
    |> get_overlapping_counts
    |> Enum.reduce(0, fn {_row, cols}, acc ->
      col_sum =
        Enum.reduce(cols, 0, fn {_col, count}, acc ->
          if count >= 2, do: acc + 1, else: acc
        end)

      acc + col_sum
    end)
  end

  def non_overlapping_claim(claims) do
    parsed_claims = Enum.map(claims, &parse_claim/1)

    counts =
      parsed_claims
      |> Enum.map(&get_claimed_squares/1)
      |> get_overlapping_counts

    parsed_claims
    |> Enum.reduce(%{}, fn claim, acc ->
      Map.put(acc, Map.get(claim, :id), get_claimed_squares(claim))
    end)
    |> Enum.reduce(nil, fn {id, claimed_squares}, acc ->
      result =
        claimed_squares
        |> Enum.reduce(%{}, fn {row, cols}, acc ->
          result =
            cols
            |> Map.keys()
            |> Enum.map(fn col ->
              if counts[row][col] === 1, do: true, else: false
            end)
            |> Enum.reduce(true, fn el, acc -> el && acc end)

          Map.put(acc, row, result)
        end)
        |> Map.values()
        |> Enum.reduce(true, fn el, acc -> el && acc end)

      if result, do: id, else: acc
    end)
  end

  defp parse_claim(claim) do
    [_, id, left, top, width, height] = Regex.run(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, claim)

    %{
      id: String.to_integer(id),
      left: String.to_integer(left),
      top: String.to_integer(top),
      width: String.to_integer(width),
      height: String.to_integer(height)
    }
  end

  defp get_claimed_squares(parsed_claim) do
    top = Map.get(parsed_claim, :top)
    bottom = top + Map.get(parsed_claim, :height) - 1
    left = Map.get(parsed_claim, :left)
    right = left + Map.get(parsed_claim, :width) - 1

    top..bottom
    |> Enum.to_list()
    |> Enum.reduce(%{}, fn row, acc ->
      cols =
        left..right
        |> Enum.to_list()
        |> Enum.reduce(%{}, fn col, acc ->
          Map.put(acc, col, 1)
        end)

      Map.put(acc, row, cols)
    end)
  end

  def get_overlapping_counts(claimed_squares) do
    claimed_squares
    |> Enum.reduce(%{}, fn claimed_square, acc ->
      Map.merge(acc, claimed_square, fn _row_k, row_v1, row_v2 ->
        Map.merge(row_v1, row_v2, fn _col_k, col_v1, col_v2 ->
          col_v1 + col_v2
        end)
      end)
    end)
  end
end

IO.puts("Part 1: #{Day3.extract_claims() |> Day3.overlapping_squares()}")

IO.puts("Part 2: #{Day3.extract_claims() |> Day3.non_overlapping_claim()}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule InventoryManagementTest do
  use ExUnit.Case
  import Day3

  test "overlapping_squares" do
    assert overlapping_squares([
             "#1 @ 1,3: 4x4",
             "#2 @ 3,1: 4x4",
             "#3 @ 5,5: 2x2"
           ]) === 4
  end

  test "non_overlapping_claim" do
    assert non_overlapping_claim([
             "#1 @ 1,3: 4x4",
             "#2 @ 3,1: 4x4",
             "#3 @ 5,5: 2x2"
           ]) === 3
  end
end

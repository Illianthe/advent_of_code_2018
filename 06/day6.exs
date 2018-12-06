defmodule Day6 do
  def parse_input(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)

    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn coordinates ->
      [x, y] = String.split(coordinates, ", ", trim: true)
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def largest_area(coordinates) do
    {left, right, top, bottom} = determine_boundaries(coordinates)

    for(x <- left..right, y <- top..bottom, do: {x, y})
    |> Enum.reduce(%{}, fn {loc_x, loc_y}, acc ->
      closest_coordinate = determine_closest_coordinate(loc_x, loc_y, coordinates)

      if closest_coordinate !== nil,
        do: Map.update(acc, closest_coordinate, 1, &(&1 + 1)),
        else: acc
    end)
    |> Enum.max_by(fn {_k, v} -> v end)
    |> elem(1)
  end

  def determine_closest_coordinate(x1, y1, coordinates) do
    lowest_coordinates =
      coordinates
      |> Enum.map(fn {x2, y2} ->
        distance = abs(x2 - x1) + abs(y2 - y1)
        {{x2, y2}, distance}
      end)
      |> Enum.reduce({nil, []}, fn
        {coordinate, distance}, acc when elem(acc, 0) === nil or distance < elem(acc, 0) ->
          {distance, [coordinate]}

        {coordinate, distance}, acc when distance === elem(acc, 0) ->
          {distance, [coordinate | elem(acc, 1)]}

        _, acc ->
          acc
      end)
      |> elem(1)

    if length(lowest_coordinates) === 1, do: List.first(lowest_coordinates), else: nil
  end

  def determine_boundaries(coordinates) do
    left = coordinates |> Enum.map(&elem(&1, 0)) |> Enum.min()
    right = coordinates |> Enum.map(&elem(&1, 0)) |> Enum.max()
    top = coordinates |> Enum.map(&elem(&1, 1)) |> Enum.min()
    bottom = coordinates |> Enum.map(&elem(&1, 1)) |> Enum.max()

    {left, right, top, bottom}
  end

  def find_encapsulating_region(coordinates, max_distance \\ 10000) do
    {left, right, top, bottom} = determine_boundaries(coordinates)

    for(x <- left..right, y <- top..bottom, do: {x, y})
    |> Enum.reduce(0, fn {loc_x, loc_y}, acc ->
      total_distance =
        coordinates
        |> Enum.map(fn {x, y} -> abs(loc_x - x) + abs(loc_y - y) end)
        |> Enum.sum()

      if total_distance < max_distance, do: acc + 1, else: acc
    end)
  end
end

result1 = Day6.parse_input() |> Day6.largest_area()
IO.puts("Part 1: #{result1}")

result2 = Day6.parse_input() |> Day6.find_encapsulating_region()
IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day6Test do
  use ExUnit.Case
  import Day6

  @coordinates [
    {1, 1},
    {1, 6},
    {8, 3},
    {3, 4},
    {5, 5},
    {8, 9}
  ]

  test "largest_area" do
    assert largest_area(@coordinates) === 17
  end

  test "determine_closest_coordinate" do
    assert determine_closest_coordinate(1, 2, @coordinates) === {1, 1}
  end

  test "find_encapsulating_region" do
    assert find_encapsulating_region(@coordinates, 32) === 16
  end
end

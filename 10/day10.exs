defmodule Day10 do
  def parse_input(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)

    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn point ->
      [_, x_pos, y_pos, x_velocity, y_velocity] =
        Regex.run(~r/position=< *(-?\d+), *(-?\d+)> velocity=< *(-?\d+), *(-?\d+)>/, point)

      {
        String.to_integer(x_pos),
        String.to_integer(y_pos),
        String.to_integer(x_velocity),
        String.to_integer(y_velocity)
      }
    end)
  end

  def determine_message(points, y_tolerance \\ 10) do
    rearrange(points, 1, y_tolerance)
  end

  # Keep rearranging until all the points are within the y tolerance range
  def rearrange(points, second, y_tolerance) do
    repositioned_points =
      points
      |> Enum.map(fn point ->
        {x_pos, y_pos, x_velocity, y_velocity} = point
        {x_pos + x_velocity, y_pos + y_velocity, x_velocity, y_velocity}
      end)

    {min_y, max_y} =
      repositioned_points
      |> Enum.min_max_by(&elem(&1, 1))
      |> (fn points ->
            {elem(elem(points, 0), 1), elem(elem(points, 1), 1)}
          end).()

    y_range = abs(min_y - max_y)

    if y_range <= y_tolerance do
      print_output(repositioned_points, second)
    else
      rearrange(repositioned_points, second + 1, y_tolerance)
    end
  end

  def print_output(points, second) do
    point_coordinates =
      points
      |> Enum.map(&{elem(&1, 0), elem(&1, 1)})

    {min_x, max_x} =
      point_coordinates
      |> Enum.min_max_by(&elem(&1, 0))
      |> (fn points ->
            {elem(elem(points, 0), 0), elem(elem(points, 1), 0)}
          end).()

    {min_y, max_y} =
      point_coordinates
      |> Enum.min_max_by(&elem(&1, 1))
      |> (fn points ->
            {elem(elem(points, 0), 1), elem(elem(points, 1), 1)}
          end).()

    for row <- min_y..max_y do
      for col <- min_x..max_x do
        if {col, row} in point_coordinates, do: "#", else: "."
      end
    end
    |> Enum.join("\n")
    |> IO.puts()

    "Found in #{second} seconds"
  end
end

result1 = Day10.parse_input() |> Day10.determine_message()
IO.puts("Part 1 & 2: #{result1}")

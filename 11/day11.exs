defmodule Day11 do
  def coord_largest_total_power(grid_serial_number) do
    power_grid = power_grid(grid_serial_number)

    for x <- 1..298, y <- 1..298 do
      {x, y}
    end
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      sum =
        for x2 <- x..(x + 2), y2 <- y..(y + 2) do
          power_grid[{x2, y2}]
        end
        |> Enum.sum()

      Map.put(acc, {x, y}, sum)
    end)
    |> Enum.max_by(fn {_coord, val} -> val end)
    |> (&elem(&1, 0)).()
  end

  def coord_largest_total_power_with_size(grid_serial_number) do
    power_grid = power_grid(grid_serial_number)

    max =
      Stream.flat_map(1..300, fn size ->
        Stream.flat_map(1..(300 - size + 1), fn x ->
          Stream.flat_map(1..(300 - size + 1), fn y ->
            [{x, y, size}]
          end)
        end)
      end)
      |> Stream.map(fn {x, y, size} ->
        sum =
          for x2 <- x..(x + size - 1), y2 <- y..(y + size - 1) do
            power_grid[{x2, y2}]
          end
          |> Enum.sum()

        IO.puts("#{x}, #{y}, #{size}")

        {x, y, size, sum}
      end)
      |> Enum.max_by(fn tuple -> elem(tuple, 3) end)

    {elem(max, 0), elem(max, 1), elem(max, 2)}
  end

  def power_grid(grid_serial_number) do
    for x <- 1..300, y <- 1..300 do
      {x, y}
    end
    |> Enum.reduce(%{}, fn coord, acc ->
      {x, y} = coord
      rack_id = x + 10
      power = Enum.at(Integer.digits((rack_id * y + grid_serial_number) * rack_id), -3, 0) - 5
      Map.put(acc, coord, power)
    end)
  end
end

result1 = Day11.coord_largest_total_power(9424)
IO.puts("Part 1: #{elem(result1, 0)},#{elem(result1, 1)}")

result2 = Day11.coord_largest_total_power_with_size(9424)
IO.puts("Part 2: #{elem(result2, 0)},#{elem(result2, 1)},#{elem(result2, 2)}")

IO.puts("\n----------\n")

ExUnit.start(timeout: :infinity)

defmodule Day11Test do
  use ExUnit.Case
  import Day11

  test "coord_largest_total_power" do
    assert coord_largest_total_power(42) === {21, 61}
  end

  test "coord_largest_total_power_with_size" do
    assert coord_largest_total_power_with_size(18) === {90, 269, 16}
  end
end

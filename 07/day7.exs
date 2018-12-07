defmodule Day7 do
  # Returns a mapping of a node to its dependencies
  # e.g. %{A => 'C'} means A depends on C
  def parse_input(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)

    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [_, start, stop] =
        Regex.run(~r/Step (.+) must be finished before step (.+) can begin./, str)

      {List.first(String.to_charlist(start)), List.first(String.to_charlist(stop))}
    end)
    |> Enum.reduce(%{}, fn {start, stop}, acc ->
      acc = Map.put_new(acc, start, [])
      Map.update(acc, stop, [start], fn val -> [start | val] end)
    end)
  end

  def order_of_steps(dependencies) do
    nodes = Map.keys(dependencies)
    generate_order('', nodes, dependencies)
  end

  def generate_order(ordered_nodes, [], _dependencies) do
    ordered_nodes
    |> Enum.reverse()
    |> to_charlist()
  end

  def generate_order(ordered_nodes, remaining_nodes, dependencies) do
    next_node =
      dependencies
      |> Enum.filter(fn {k, v} -> Enum.empty?(v) end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.min()

    next_remaining_nodes = List.delete(remaining_nodes, next_node)

    next_dependencies =
      dependencies
      |> Map.delete(next_node)
      |> Enum.reduce(%{}, fn {node, dependencies}, acc ->
        Map.put(acc, node, List.delete(dependencies, next_node))
      end)

    generate_order([next_node | ordered_nodes], next_remaining_nodes, next_dependencies)
  end
end

result1 = Day7.parse_input() |> Day7.order_of_steps()
IO.puts("Part 1: #{result1}")

# result2 = Day7.parse_input() |> Day7.order_of_steps()
# IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day7Test do
  use ExUnit.Case
  import Day7

  @input parse_input("test_input.txt")

  test "order_of_steps" do
    assert order_of_steps(@input) === 'CABDFE'
  end
end

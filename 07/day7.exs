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

  def time_to_complete(dependencies, base_time \\ 60, available_workers \\ 5) do
    dependencies
    |> Enum.map(fn {k, v} -> {k, {v, k - 65 + base_time + 1}} end)
    |> Map.new()
    |> progress(0, available_workers)
  end

  def progress(dependencies, total_seconds, available_workers)

  def progress(dependencies, total_seconds, available_workers) when dependencies === %{} do
    total_seconds
  end

  def progress(dependencies, total_seconds, available_workers) do
    working_nodes =
      dependencies
      |> Enum.filter(fn {node, {dependencies, seconds_remaining}} -> Enum.empty?(dependencies) end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.sort()
      |> Enum.take(available_workers)

    updated_dependencies =
      working_nodes
      |> Enum.reduce(%{}, fn working_node, acc ->
        {dependencies, seconds_remaining} = dependencies[working_node]
        Map.put(acc, working_node, {dependencies, seconds_remaining - 1})
      end)

    completed_nodes =
      updated_dependencies
      |> Enum.filter(fn {node, {dependencies, seconds_remaining}} -> seconds_remaining === 0 end)
      |> Enum.map(&elem(&1, 0))

    next_dependencies =
      dependencies
      |> Map.merge(updated_dependencies)
      |> Map.drop(completed_nodes)
      |> Enum.reduce(%{}, fn {node, {dependencies, seconds_remaining}}, acc ->
        updated_dependencies =
          Enum.filter(dependencies, fn e -> !Enum.member?(completed_nodes, e) end)

        Map.put(acc, node, {updated_dependencies, seconds_remaining})
      end)

    progress(next_dependencies, total_seconds + 1, available_workers)
  end
end

result1 = Day7.parse_input() |> Day7.order_of_steps()
IO.puts("Part 1: #{result1}")

result2 = Day7.parse_input() |> Day7.time_to_complete()
IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day7Test do
  use ExUnit.Case
  import Day7

  @input parse_input("test_input.txt")

  test "order_of_steps" do
    assert order_of_steps(@input) === 'CABDFE'
  end

  test "time_to_complete" do
    assert time_to_complete(@input, 0, 2) === 16
  end
end

defmodule Day8 do
  def parse_input(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)

    data
    |> String.split(~r/\n| /, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def sum_metadata_entries(parsed_input, child_stack \\ [], meta_stack \\ [], sum \\ 0)

  def sum_metadata_entries([], [], [], sum), do: sum

  def sum_metadata_entries(parsed_input, [0 | []], [0 | []], sum) do
    sum_metadata_entries(parsed_input, [], [], sum)
  end

  # Need to adjust the remaining child nodes in the last item on the stack
  # once new sum has been calculated
  def sum_metadata_entries(
        parsed_input,
        [0 | [child_stack_next | child_stack_tail]],
        [0 | meta_stack_tail],
        sum
      ) do
    sum_metadata_entries(
      parsed_input,
      [child_stack_next - 1 | child_stack_tail],
      meta_stack_tail,
      sum
    )
  end

  # Calculate new sum since no child nodes coming up
  def sum_metadata_entries(
        parsed_input,
        [0 | child_stack_tail],
        [num_metadata_entries_to_consume | meta_stack_tail],
        sum
      ) do
    new_sum = (Enum.take(parsed_input, num_metadata_entries_to_consume) |> Enum.sum()) + sum

    new_parsed_input =
      Enum.slice(parsed_input, num_metadata_entries_to_consume, length(parsed_input))

    sum_metadata_entries(new_parsed_input, [0 | child_stack_tail], [0 | meta_stack_tail], new_sum)
  end

  def sum_metadata_entries(
        [num_child_nodes | [num_metadata_entries | tail]],
        child_stack,
        meta_stack,
        sum
      ) do
    child_stack = [num_child_nodes | child_stack]
    meta_stack = [num_metadata_entries | meta_stack]
    sum_metadata_entries(tail, child_stack, meta_stack, sum)
  end

  def value_of_node(
        parsed_input,
        node_stack \\ [],
        remaining_child_stack \\ [],
        meta_stack \\ [],
        child_sum_stack \\ []
      )

  # Base case - return value of node
  def value_of_node([], [], [], [], [sum | []]), do: sum

  # No child nodes - sum of metadata entries
  def value_of_node(
        parsed_input,
        [0 | node_stack_tail],
        [0 | remaining_child_stack_tail],
        [num_metadata_entries_to_consume | meta_stack_tail],
        child_sum_stack
      ) do
    new_sum = Enum.take(parsed_input, num_metadata_entries_to_consume) |> Enum.sum()

    new_parsed_input =
      Enum.slice(parsed_input, num_metadata_entries_to_consume, length(parsed_input))

    child_nodes_remaining =
      case remaining_child_stack_tail do
        [head | tail] -> [head - 1 | tail]
        [] -> remaining_child_stack_tail
      end

    value_of_node(
      new_parsed_input,
      node_stack_tail,
      child_nodes_remaining,
      meta_stack_tail,
      [new_sum | child_sum_stack]
    )
  end

  # Has child nodes - sum of values of child nodes
  def value_of_node(
        parsed_input,
        [node_stack_head | node_stack_tail],
        [0 | remaining_child_stack_tail],
        [num_metadata_entries_to_consume | meta_stack_tail],
        child_sum_stack
      ) do
    child_sums = Enum.take(child_sum_stack, node_stack_head)
    child_sum_stack = Enum.drop(child_sum_stack, node_stack_head)

    node_sum =
      parsed_input
      |> Enum.take(num_metadata_entries_to_consume)
      |> Enum.map(fn
        0 -> 0
        i -> Enum.at(child_sums, -i, 0)
      end)
      |> Enum.sum()

    new_parsed_input =
      Enum.take(parsed_input, num_metadata_entries_to_consume - length(parsed_input))

    child_nodes_remaining =
      case remaining_child_stack_tail do
        [head | tail] -> [head - 1 | tail]
        [] -> remaining_child_stack_tail
      end

    value_of_node(
      new_parsed_input,
      node_stack_tail,
      child_nodes_remaining,
      meta_stack_tail,
      [node_sum | child_sum_stack]
    )
  end

  # Add data from next node to stacks
  def value_of_node(
        [num_child_nodes | [num_metadata_entries | tail]],
        node_stack,
        remaining_child_stack,
        meta_stack,
        child_sum_stack
      ) do
    value_of_node(
      tail,
      [num_child_nodes | node_stack],
      [num_child_nodes | remaining_child_stack],
      [num_metadata_entries | meta_stack],
      child_sum_stack
    )
  end
end

result1 = Day8.parse_input() |> Day8.sum_metadata_entries()
IO.puts("Part 1: #{result1}")

result2 = Day8.parse_input() |> Day8.value_of_node()
IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day8Test do
  use ExUnit.Case
  import Day8

  @input parse_input("test_input.txt")

  test "sum_metadata_entries" do
    assert sum_metadata_entries(@input) === 138
  end

  test "value_of_node" do
    assert value_of_node(@input) === 66
  end
end

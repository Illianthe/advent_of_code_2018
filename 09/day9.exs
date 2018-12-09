defmodule Day9 do
  def parse_input(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)

    [_, no_of_players, value_of_last_marble] =
      data
      |> String.trim()
      |> (&Regex.run(~r/(\d+) players; last marble is worth (\d+)/, &1)).()

    {String.to_integer(no_of_players), String.to_integer(value_of_last_marble)}
  end

  def winning_score(parsed_input) do
    run_game(parsed_input) |> Enum.max_by(fn {k, v} -> v end) |> elem(1)
  end

  def run_game(
        parsed_input,
        game_state \\ [0],
        current_player \\ 0,
        current_marble_index \\ 0,
        next_marble \\ 1,
        total_score \\ %{}
      )

  # Last marble used, end game
  def run_game(
        parsed_input,
        _game_state,
        _current_player,
        _current_marble_index,
        next_marble,
        total_score
      )
      when elem(parsed_input, 1) === next_marble do
    total_score
  end

  # Remove marbles, set current marble, and add to score
  def run_game(
        parsed_input,
        game_state,
        current_player,
        current_marble_index,
        next_marble,
        total_score
      )
      when rem(next_marble, 23) === 0 do
    marble_index_to_remove = calculate_marble_index(game_state, current_marble_index - 7)

    score_to_add = next_marble + Enum.at(game_state, marble_index_to_remove)
    total_score = Map.update(total_score, current_player, score_to_add, &(&1 + score_to_add))

    game_state = List.delete_at(game_state, marble_index_to_remove)
    current_marble_index = marble_index_to_remove

    current_player = calculate_next_player(parsed_input, current_player)

    run_game(
      parsed_input,
      game_state,
      current_player,
      current_marble_index,
      next_marble + 1,
      total_score
    )
  end

  # Place next marble
  def run_game(
        parsed_input,
        game_state,
        current_player,
        current_marble_index,
        next_marble,
        total_score
      ) do
    marble_index_to_add = calculate_marble_index(game_state, current_marble_index + 2)
    game_state = List.insert_at(game_state, marble_index_to_add, next_marble)
    current_player = calculate_next_player(parsed_input, current_player)

    run_game(
      parsed_input,
      game_state,
      current_player,
      marble_index_to_add,
      next_marble + 1,
      total_score
    )
  end

  def calculate_marble_index(game_state, i) do
    cond do
      i >= length(game_state) -> i - length(game_state)
      i < 0 -> i + length(game_state)
      true -> i
    end
  end

  def calculate_next_player(parsed_input, current_player) do
    if elem(parsed_input, 0) === current_player + 1, do: 0, else: current_player + 1
  end
end

result1 = Day9.parse_input() |> Day9.winning_score()
IO.puts("Part 1: #{result1}")

# result2 = Day9.parse_input() |> Day9.value_of_node()
# IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day9Test do
  use ExUnit.Case
  import Day9

  test "winning_score" do
    assert winning_score({10, 1618}) === 8317
  end
end

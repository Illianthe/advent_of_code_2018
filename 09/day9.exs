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
    run_game(parsed_input) |> Enum.max_by(fn {_k, v} -> v end) |> elem(1)
  end

  def winning_score_optimized(parsed_input) do
    run_game_optimized(parsed_input) |> Enum.max_by(fn {_k, v} -> v end) |> elem(1)
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

  def run_game_optimized(
        parsed_input,
        game_state \\ %{0 => 0},
        current_player \\ 0,
        current_marble \\ 0,
        next_marble \\ 1,
        total_score \\ %{}
      )

  # Last marble used, end game
  def run_game_optimized(
        parsed_input,
        _game_state,
        _current_player,
        _current_marble,
        next_marble,
        total_score
      )
      when elem(parsed_input, 1) === next_marble do
    total_score
  end

  # Remove marbles, set current marble, and add to score
  def run_game_optimized(
        parsed_input,
        game_state,
        current_player,
        current_marble,
        next_marble,
        total_score
      )
      when rem(next_marble, 23) === 0 do
    score_to_add = next_marble + game_state[current_marble - 4]
    total_score = Map.update(total_score, current_player, score_to_add, &(&1 + score_to_add))

    game_state =
      game_state
      |> Map.delete(game_state[current_marble - 4])
      |> Map.put(current_marble - 4, current_marble - 3)

    run_game_optimized(
      parsed_input,
      game_state,
      calculate_next_player(parsed_input, current_player),
      current_marble - 3,
      next_marble + 1,
      total_score
    )
  end

  # Place next marble
  def run_game_optimized(
        parsed_input,
        game_state,
        current_player,
        current_marble,
        next_marble,
        total_score
      ) do
    # Update next marble in mapping
    game_state =
      game_state
      |> Map.put(next_marble, game_state[game_state[current_marble]])
      |> Map.put(game_state[current_marble], next_marble)

    run_game_optimized(
      parsed_input,
      game_state,
      calculate_next_player(parsed_input, current_player),
      next_marble,
      next_marble + 1,
      total_score
    )
  end
end

result1 = Day9.parse_input() |> Day9.winning_score()
IO.puts("Part 1: #{result1}")

result2 =
  Day9.parse_input() |> (&{elem(&1, 0), elem(&1, 1) * 100}).() |> Day9.winning_score_optimized()

IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day9Test do
  use ExUnit.Case
  import Day9

  test "winning_score" do
    assert winning_score({10, 1618}) === 8317
  end

  test "winning_score_optimized" do
    assert winning_score_optimized({9, 25}) === 32
    assert winning_score_optimized({10, 1618}) === 8317
    assert winning_score_optimized({13, 7999}) === 146_373
  end
end

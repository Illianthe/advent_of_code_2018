defmodule Day4 do
  def extract_records(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)
    data |> String.split("\n", trim: true)
  end

  # Aiming for something along the lines of
  # { date_on_duty => { :guard_id => 10, :minute_event => { 0 => 'S', ..., 5 => 'W' } }}
  def parse_records(raw_records) do
    raw_records
    |> Enum.reduce(%{}, fn record, acc ->
      date = calculate_night_on_duty(record)

      acc =
        Map.put_new(acc, date, %{
          guard_id: nil,
          minute_event: %{}
        })

      cond do
        String.match?(record, ~r/begins shift/) ->
          [_, id] = Regex.run(~r/Guard #(\d+)/, record)
          put_in(acc, [date, :guard_id], String.to_integer(id))

        String.match?(record, ~r/falls asleep/) ->
          {_hour, minute} = get_time(record)
          put_in(acc, [date, :minute_event, minute], 'S')

        String.match?(record, ~r/wakes up/) ->
          {_hour, minute} = get_time(record)
          put_in(acc, [date, :minute_event, minute], 'W')
      end
    end)
  end

  # Given a minute and a range of minutes (in a map of events), determine
  # if the guard is sleeping at that time
  def is_sleeping?(minute, minute_event) do
    keys = minute_event |> Map.keys() |> Enum.sort()

    prev_key =
      Enum.reduce(keys, nil, fn
        k, acc when k < minute and acc === nil -> k
        k, acc when k < minute and k > acc -> k
        _, acc -> acc
      end)

    prev_event = minute_event[prev_key]

    next_key =
      Enum.reduce(keys, nil, fn
        k, acc when k > minute and acc === nil -> k
        k, acc when k > minute and k < acc -> k
        _, acc -> acc
      end)

    next_event = minute_event[next_key]

    cond do
      prev_event === 'S' and next_event === 'W' -> true
      minute_event[minute] === 'S' -> true
      true -> false
    end
  end

  def sum_total_sleep_in_day(minute_event) do
    0..59
    |> Enum.reduce(0, fn minute, acc ->
      cond do
        is_sleeping?(minute, minute_event) -> acc + 1
        true -> acc
      end
    end)
  end

  def calculate_minute_sleep_count(minute_event) do
    0..59
    |> Enum.reduce(%{}, fn minute, acc ->
      acc = Map.put_new(acc, minute, 0)

      if is_sleeping?(minute, minute_event) do
        put_in(acc, [minute], acc[minute] + 1)
      else
        acc
      end
    end)
  end

  def calculate_night_on_duty(raw_record) do
    [_, year, month, day] = Regex.run(~r/(\d+)-(\d+)-(\d+)/, raw_record)

    {:ok, date} =
      Date.new(
        String.to_integer(year),
        String.to_integer(month),
        String.to_integer(day)
      )

    # Check if starting at end of previous day
    {hour, _minute} = get_time(raw_record)
    if hour === 23, do: Date.add(date, 1), else: date
  end

  def get_time(raw_record) do
    [_, hour, minute] = Regex.run(~r/(\d+):(\d+)/, raw_record)
    {String.to_integer(hour), String.to_integer(minute)}
  end

  def strategy_1(parsed_records) do
    sleepy_guard_id =
      parsed_records
      |> Enum.reduce(%{}, fn {_date, data}, acc ->
        %{guard_id: guard_id, minute_event: minute_event} = data
        acc = Map.put_new(acc, guard_id, 0)
        current_total_slept = sum_total_sleep_in_day(minute_event)
        put_in(acc, [guard_id], acc[guard_id] + current_total_slept)
      end)
      |> Enum.max_by(fn {_k, v} -> v end)
      |> elem(0)

    most_sleepy_minute =
      parsed_records
      |> Enum.reduce(%{}, fn {_date, data}, acc ->
        %{guard_id: guard_id, minute_event: minute_event} = data

        if guard_id !== sleepy_guard_id do
          acc
        else
          Map.merge(
            acc,
            calculate_minute_sleep_count(minute_event),
            fn _k, v1, v2 -> v1 + v2 end
          )
        end
      end)
      |> Enum.max_by(fn {_k, v} -> v end)
      |> elem(0)

    sleepy_guard_id * most_sleepy_minute
  end
end

result1 = Day4.extract_records() |> Day4.parse_records() |> Day4.strategy_1()
IO.puts("Part 1: #{result1}")

# IO.puts("Part 2: #{result2}")

IO.puts("\n----------\n")

ExUnit.start()

defmodule Day4Test do
  use ExUnit.Case
  import Day4

  test "is_sleeping" do
    assert is_sleeping?(7, %{10 => 'W', 5 => 'S'}) === true
  end

  test "calculate_night_on_duty" do
    assert calculate_night_on_duty("[1518-11-01 23:58] Guard #99 begins shift") == ~D[1518-11-02]
  end

  test "sum_total_sleep_in_day" do
    assert sum_total_sleep_in_day(%{10 => 'W', 5 => 'S'}) === 5
  end

  test "calculate_minute_sleep_count" do
    result =
      Enum.into(0..59, %{}, fn k ->
        {k, if(Enum.member?([5, 6, 7, 8, 9], k), do: 1, else: 0)}
      end)

    assert calculate_minute_sleep_count(%{10 => 'W', 5 => 'S'}) === result
  end

  test "strategy_1" do
    records =
      parse_records([
        "[1518-11-01 00:00] Guard #10 begins shift",
        "[1518-11-01 00:05] falls asleep",
        "[1518-11-01 00:25] wakes up",
        "[1518-11-02 00:00] Guard #10 begins shift",
        "[1518-11-02 00:04] falls asleep",
        "[1518-11-02 00:06] wakes up"
      ])

    assert strategy_1(records) == 50
  end
end

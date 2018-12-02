defmodule InventoryManagement do
  @charset 'abcdefghijklmnopqrstuvwxyz'

  def extract_candidate_boxes(filename \\ "input.txt") do
    {:ok, data} = File.read(filename)
    data |> String.split("\n", trim: true) |> Enum.map(&String.to_charlist/1)
  end

  def count_char_in_charlist(char, string) do
    Enum.count(string, &(&1 == char))
  end

  def boxes_with_two_of_any_letter(boxes) do
    boxes
    |> Enum.reduce([], fn box, acc ->
      has_two =
        @charset
        |> Enum.map(&count_char_in_charlist(&1, box))
        |> Enum.any?(fn x -> x == 2 end)

      if has_two, do: [box | acc], else: acc
    end)
  end

  def boxes_with_three_of_any_letter(boxes) do
    boxes
    |> Enum.reduce([], fn box, acc ->
      has_three =
        @charset
        |> Enum.map(&count_char_in_charlist(&1, box))
        |> Enum.any?(fn x -> x == 3 end)

      if has_three, do: [box | acc], else: acc
    end)
  end

  def checksum(boxes) do
    num_with_two_letters = boxes_with_two_of_any_letter(boxes) |> Enum.count()
    num_with_three_letters = boxes_with_three_of_any_letter(boxes) |> Enum.count()
    num_with_two_letters * num_with_three_letters
  end

  def search_for_similar_box(box, boxes) do
    boxes
    |> Enum.reduce(nil, fn current_box, acc ->
      if count_differing_letters(box, current_box) == 1 do
        current_box
      else
        acc
      end
    end)
  end

  def count_differing_letters(box1, box2) do
    box1
    |> Enum.with_index()
    |> Enum.reduce(0, fn {current_letter, index}, acc ->
      if current_letter !== Enum.at(box2, index) do
        acc + 1
      else
        acc
      end
    end)
  end

  def common_letters_between_correct_boxes(boxes) do
    common_boxes =
      boxes
      |> Enum.reduce(nil, fn box, acc ->
        similar = search_for_similar_box(box, boxes)
        if similar !== nil, do: {box, similar}, else: acc
      end)

    elem(common_boxes, 0)
    |> Enum.with_index()
    |> Enum.reduce('', fn {current_letter, index}, acc ->
      if current_letter === Enum.at(elem(common_boxes, 1), index) do
        [current_letter | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end
end

IO.puts(
  "Part 1: #{InventoryManagement.extract_candidate_boxes() |> InventoryManagement.checksum()}"
)

IO.puts(
  "Part 2: #{
    InventoryManagement.extract_candidate_boxes()
    |> InventoryManagement.common_letters_between_correct_boxes()
  }"
)

IO.puts("\n----------\n")

ExUnit.start()

defmodule InventoryManagementTest do
  use ExUnit.Case
  import InventoryManagement

  test "count_char_in_charlist" do
    assert count_char_in_charlist(?a, 'aaaaa') == 5
  end

  test "boxes_with_two_of_any_letter" do
    assert boxes_with_two_of_any_letter(['aaa', 'bb']) == ['bb']
  end

  test "boxes_with_three_of_any_letter" do
    assert boxes_with_three_of_any_letter(['aaa', 'bb']) == ['aaa']
  end

  test "checksum" do
    assert checksum(['aaa', 'bb', 'cc', 'ddd']) == 4
  end

  test "search_for_similar_box" do
    assert search_for_similar_box('aa', ['aa', 'ab', 'cc']) == 'ab'
  end

  test "count_differing_letters" do
    assert count_differing_letters('abc', 'acc') == 1
  end

  test "common_letters_between_correct_boxes" do
    assert common_letters_between_correct_boxes([
             'abcde',
             'fghij',
             'klmno',
             'pqrst',
             'fguij',
             'axcye'
           ]) == 'fgij'
  end
end

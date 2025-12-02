defmodule AdventOfCode.Solution.Year2025.Day01 do
  def increase_position(sum, pos, start_pos) do
    new_sum = if start_pos > 0, do: sum + 1, else: sum
    new_pos = pos + 100
    if new_pos < 0 do
      increase_position(new_sum, new_pos, pos)
    else
      {new_sum, new_pos}
    end
  end

  def reduce_position(sum, pos, start_pos) do
    new_sum = if start_pos < 99, do: sum + 1, else: sum
    new_pos = pos - 100
    if new_pos > 99 do
      reduce_position(new_sum, new_pos, pos)
    else
      {new_sum, new_pos}
    end
  end
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{sum: 0, pos: 50}, fn line, acc ->
      number = line |> String.replace(~r"(L|R)", "") |> String.to_integer()
      %{sum: sum, pos: pos} = acc
      new_pos = if String.starts_with?(line, "L"), do: (pos - rem(number,100)), else: (pos + rem(number,100))

      new_pos = if new_pos < 0, do: 100 + rem(new_pos, 100), else: new_pos
      new_pos = if new_pos > 99, do: rem(new_pos, 100), else: new_pos
      new_sum = if new_pos == 0, do: sum + 1, else: sum

      %{sum: new_sum, pos: new_pos}
      end)
      |> Map.get(:sum)
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{sum: 0, pos: 50}, fn line, acc ->
      number = line |> String.replace(~r"(L|R)", "") |> String.to_integer()
      %{sum: sum, pos: pos} = acc
      full = floor(number / 100)
      remainder = rem(number, 100)

      new_sum = sum + full
      new_pos = if String.starts_with?(line, "L") do
        pos - remainder
      else
        pos + remainder
      end

      {new_sum, new_pos} = cond do
        new_pos < 0 ->
          new_pos = 100 + new_pos
          new_sum = if new_pos == 0 or pos == 0, do: new_sum, else: new_sum + 1
          {new_sum, new_pos}
        new_pos > 99 ->
          new_pos = new_pos - 100
          new_sum = if new_pos == 0 or pos == 0, do: new_sum, else: new_sum + 1
          {new_sum, new_pos}
        true ->

          {new_sum, new_pos}
      end

      new_sum = if new_pos == 0, do: new_sum + 1, else: new_sum
      %{sum: new_sum, pos: new_pos}
      end)
      |> Map.get(:sum)
  end
end

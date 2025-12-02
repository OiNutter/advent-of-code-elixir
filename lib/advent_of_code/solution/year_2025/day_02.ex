defmodule AdventOfCode.Solution.Year2025.Day02 do
  def part1(input) do
    input
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.flat_map(fn range_str ->
      [start_str, end_str] = String.split(range_str, "-", trim: true)
      #IO.inspect({start_str, end_str})
      start = String.to_integer(start_str)
      ending = String.to_integer(end_str)
      Enum.map(start..ending, fn x ->
        str_x = Integer.to_string(x)
        String.split_at(str_x, str_x |> String.length() |> div(2))
      end)
      |> Enum.filter(fn {left, right} ->
        left == right
      end)
    end)
    |> Enum.map(fn {left, right} -> String.to_integer(left <> right) end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.flat_map(fn range_str ->
      [start_str, end_str] = String.split(range_str, "-", trim: true)
      start = String.to_integer(start_str)
      ending = String.to_integer(end_str)
      Enum.map(start..ending, &Integer.to_string/1)
      |> Enum.filter(fn id ->
        String.match?(id, ~r/^(.+)\1+$/) # checks for repeated pattern
      end)
    end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end

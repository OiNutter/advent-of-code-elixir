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
      Enum.filter(start..ending, fn i ->
        s = Integer.to_string(i)
        l = String.length(s)
        if l < 2 do
          false
        else
          Enum.map(1..div(l, 2), fn i ->
            if rem(l, i) != 0 do
              false
            else
              s0 = String.slice(s, 0..(i-1))
              s == String.duplicate(s0, div(l, i))
            end
          end)
          |> Enum.any?()
        end
      end)
    end)
    |> Enum.sum()
  end
end

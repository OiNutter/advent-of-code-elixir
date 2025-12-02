defmodule AdventOfCode.Solution.Year2025.Day02 do
  def part1(input) do
    input
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.map(fn range_str ->
      [start_str, end_str] = String.split(range_str, "-", trim: true)
      #IO.inspect({start_str, end_str})
      String.to_integer(start_str)..String.to_integer(end_str)
    end)
    |> Task.async_stream(fn range ->
      range
      |> Enum.map(fn x ->
        str_x = Integer.to_charlist(x)
        Enum.split(str_x, str_x |> length() |> div(2))
      end)
      |> Enum.filter(fn {left, right} ->
        left == right
      end)
    end)
    |> Enum.flat_map(fn {:ok, v} -> v end)
    |> Enum.map(fn {left, right} -> Enum.concat(left, right) |> List.to_integer() end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.map(fn range_str ->
      [start_str, end_str] = String.split(range_str, "-", trim: true)
      String.to_integer(start_str)..String.to_integer(end_str)
    end)
    |> Task.async_stream(fn range ->
      range
      |> Enum.filter(fn i ->
        s = Integer.to_charlist(i)
        l = length(s)
        if l < 2 do
          false
        else
          Enum.map(1..div(l, 2), fn i ->
            if rem(l, i) != 0 do
              false
            else
              s0 = Enum.slice(s, 0..(i-1))
              s == (List.duplicate(s0, div(l, i)) |> List.flatten())
            end
          end)
          |> Enum.any?()
        end
      end)
    end)
    |> Enum.flat_map(fn {:ok, v} -> v end)
    |> Enum.sum()
  end
end

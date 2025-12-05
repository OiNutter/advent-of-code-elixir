defmodule AdventOfCode.Solution.Year2025.Day05 do
  def part1(input) do
    [fresh, available] =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    fresh =
      fresh
      |> Enum.map(fn line ->
        [start, finish] = line |> String.split("-", trim: true)
        String.to_integer(start)..String.to_integer(finish)
      end)

    available
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(MapSet.new(), fn available_piece, freshIngredients ->
      Enum.reduce(fresh, freshIngredients, fn range, acc ->
        if Enum.member?(range, available_piece), do: MapSet.put(acc, available_piece), else: acc
      end)
    end)
    |> MapSet.size()
  end

  def part2(input) do
    [fresh, _available] =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    sorted =
      fresh
      |> Enum.map(fn line ->
        [start, finish] = line |> String.split("-", trim: true)
        lowest = min(String.to_integer(start), String.to_integer(finish))
        highest = max(String.to_integer(start), String.to_integer(finish))
        %{start: lowest, finish: highest}
      end)
      |> Enum.sort_by(& &1.start)

    first = Enum.at(sorted, 0)

    {_prev, total} =
      sorted
      |> Enum.drop(1)
      |> Enum.reduce({first, first.finish - first.start + 1}, fn range, {prev, total} ->
        if range.start <= prev.finish do
          if range.finish <= prev.finish do
            {prev, total}
          else
            new_start = prev.finish + 1
            range_size = range.finish - new_start + 1
            {range, total + range_size}
          end
        else
          range_size = range.finish - range.start + 1
          {range, total + range_size}
        end
      end)

    total
  end
end

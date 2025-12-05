defmodule AdventOfCode.Solution.Year2025.Day04 do
  use AdventOfCode.Solution.SharedParse

  def remove_paper(map, total) do
    {map, total_removed} =
      map
      |> Enum.reduce({map, 0}, fn {{x, y}, _char}, {map, total} ->
        adjacents =
          Enum.reduce_while((y - 1)..(y + 1), 0, fn dy, adj ->
            adj =
              Enum.reduce_while((x - 1)..(x + 1), adj, fn dx, adj ->
                adj =
                  if {dx, dy} != {x, y} && Map.get(map, {dx, dy}, false) do
                    adj + 1
                  else
                    adj
                  end

                if adj >= 4, do: {:halt, adj}, else: {:cont, adj}
              end)

            if adj >= 4, do: {:halt, adj}, else: {:cont, adj}
          end)

        if adjacents < 4 do
          {Map.delete(map, {x, y}), total + 1}
        else
          {map, total}
        end
      end)

    # IO.inspect(total_removed, label: "Removed this round")

    if total_removed == 0, do: total, else: remove_paper(map, total + total_removed)
  end

  def get_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {char, x}, map ->
        if char == ?@, do: Map.put(map, {x, y}, true), else: map
      end)
    end)
  end

  def parse(input) do
    get_map(input)
  end

  def part1(input) do
    input
    |> Enum.reduce(0, fn {{x, y}, _char}, acc ->
      adjacents =
        Enum.reduce_while((y - 1)..(y + 1), 0, fn dy, adj ->
          adj =
            Enum.reduce_while((x - 1)..(x + 1), adj, fn dx, adj ->
              adj =
                if {dx, dy} != {x, y} && Map.get(input, {dx, dy}, false) do
                  adj + 1
                else
                  adj
                end

              if adj >= 4, do: {:halt, adj}, else: {:cont, adj}
            end)

          if adj >= 4, do: {:halt, adj}, else: {:cont, adj}
        end)

      if adjacents < 4, do: acc + 1, else: acc
    end)
  end

  def part2(input) do
    remove_paper(input, 0)
  end
end

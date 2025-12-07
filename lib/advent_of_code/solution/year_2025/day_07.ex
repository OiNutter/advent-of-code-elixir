defmodule AdventOfCode.Solution.Year2025.Day07 do
  use AdventOfCode.Solution.SharedParse
  use Agent

  defp move_quantum_tachyon([], _beam), do: 1

  defp move_quantum_tachyon([line | lines], beam) do
    memory = Agent.get(:beams, & &1)

    key = {length(lines), beam}

    if beam < 0 || beam >= length(line) do
      0
    else
      if Map.has_key?(memory, key) do
        Map.get(memory, key)
      else
        result =
          if line |> Enum.at(beam) == ?^ do
            move_quantum_tachyon(lines, beam - 1) + move_quantum_tachyon(lines, beam + 1)
          else
            move_quantum_tachyon(lines, beam)
          end

        Agent.update(:beams, &Map.put(&1, key, result))
        result
      end
    end
  end

  def parse(input) do
    lines =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    {first, lines} =
      lines
      |> List.pop_at(0)

    start =
      first
      |> Enum.find_index(&(&1 == ?S))

    {lines, start}
  end

  def part1({lines, start}) do
    lines
    |> Enum.reduce({MapSet.new([start]), 0}, fn line, {beams, count} ->
      beams
      |> Enum.reduce({MapSet.new(), count}, fn beam, {new_beams, count} ->
        if line |> Enum.at(beam) == ?^ do
          {
            MapSet.put(new_beams, beam - 1) |> MapSet.put(beam + 1),
            count + 1
          }
        else
          {MapSet.put(new_beams, beam), count}
        end
      end)
    end)
    |> elem(1)
  end

  def part2({lines, start}) do
    Agent.start_link(fn -> %{} end, name: :beams)

    move_quantum_tachyon(lines, start)
  end
end

defmodule AdventOfCode.Solution.Year2025.Day08 do
  use AdventOfCode.Solution.SharedParse

  def parse(input) do
    junctions =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    distances =
      junctions
      |> Enum.reduce(%{}, fn {x, y, z}, distances ->
        junctions
        |> Enum.reduce(distances, fn {x2, y2, z2}, distances ->
          if {x, y, z} != {x2, y2, z2} and !Map.has_key?(distances, {{x2, y2, z2}, {x, y, z}}) do
            distance = BasicMath.euclidean_distance_3d({x, y, z}, {x2, y2, z2})
            Map.put(distances, {{x, y, z}, {x2, y2, z2}}, distance)
          else
            distances
          end
        end)
      end)
      |> Enum.sort_by(fn {_key, distance} -> distance end)
      |> Enum.map(fn {{a, b}, _distance} -> {a, b} end)

    {distances, length(junctions)}
  end

  def part1({distances, _}) do
    distances
    |> Enum.take(1000)
    |> Enum.reduce([], fn {a, b}, circuits ->
      existing_a =
        circuits
        |> Enum.find_index(fn connections ->
          MapSet.member?(connections, a)
        end)

      existing_b =
        circuits
        |> Enum.find_index(fn connections ->
          MapSet.member?(connections, b)
        end)

      connections = MapSet.new([a, b])

      if existing_a != nil and existing_b != nil do
        if existing_a != existing_b do
          a_set = Enum.at(circuits, existing_a)
          b_set = Enum.at(circuits, existing_b)

          new_set = MapSet.union(a_set, b_set)

          circuits
          |> List.delete_at(Enum.max([existing_a, existing_b]))
          |> List.delete_at(Enum.min([existing_a, existing_b]))
          |> List.insert_at(Enum.min([existing_a, existing_b]), new_set)
        else
          circuits
        end
      else
        if existing_a do
          List.update_at(circuits, existing_a, fn set -> MapSet.put(set, b) end)
        else
          if existing_b do
            List.update_at(circuits, existing_b, fn set -> MapSet.put(set, a) end)
          else
            [connections | circuits]
          end
        end
      end
    end)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def part2({distances, num_junctions}) do
    {{x1, _, _}, {x2, _, _}} =
      distances
      |> Enum.reduce_while({[], nil}, fn {a, b}, {circuits, _} ->
        existing_a =
          circuits
          |> Enum.find_index(fn connections ->
            MapSet.member?(connections, a)
          end)

        existing_b =
          circuits
          |> Enum.find_index(fn connections ->
            MapSet.member?(connections, b)
          end)

        connections = MapSet.new([a, b])

        circuits =
          if existing_a != nil and existing_b != nil do
            if existing_a != existing_b do
              a_set = Enum.at(circuits, existing_a)
              b_set = Enum.at(circuits, existing_b)

              new_set = MapSet.union(a_set, b_set)

              circuits
              |> List.delete_at(Enum.max([existing_a, existing_b]))
              |> List.delete_at(Enum.min([existing_a, existing_b]))
              |> List.insert_at(Enum.min([existing_a, existing_b]), new_set)
            else
              circuits
            end
          else
            if existing_a do
              List.update_at(circuits, existing_a, fn set -> MapSet.put(set, b) end)
            else
              if existing_b do
                List.update_at(circuits, existing_b, fn set -> MapSet.put(set, a) end)
              else
                [connections | circuits]
              end
            end
          end

        if length(circuits) == 1 and
             circuits |> List.first() |> MapSet.size() == num_junctions do
          {:halt, {circuits, {a, b}}}
        else
          {:cont, {circuits, nil}}
        end
      end)
      |> elem(1)

    x1 * x2
  end
end

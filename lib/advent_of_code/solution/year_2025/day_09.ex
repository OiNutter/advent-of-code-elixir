defmodule AdventOfCode.Solution.Year2025.Day09 do
  use AdventOfCode.Solution.SharedParse

  @directions [
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
  ]

  defp flood([current | queue], grid, max_x, max_y) do
    i = div(current, max_x + 1)
    j = rem(current, max_x + 1)

    Enum.reduce(@directions, {grid, queue}, fn {dx, dy}, {g, q} ->
      i2 = i + dx
      j2 = j + dy
      coord = {i2, j2}

      if i2 >= 0 and i2 <= max_y and j2 >= 0 and j2 <= max_x and
           Map.get(g, coord, false) === false do
        {
          Map.put(g, coord, "*"),
          q ++ [i2 * (max_x + 1) + j2]
        }
      else
        {g, q}
      end
    end)
    |> (fn {new_grid, new_queue} -> flood(new_queue, new_grid, max_x, max_y) end).()
  end

  defp flood([], grid, _, _), do: grid

  defp draw_line(x1, y1, x2, y2, grid) do
    xx = x1
    yy = y1

    {xx, yy} =
      if xx === x2 do
        {xx, yy + if(yy > y2, do: -1, else: 1)}
      else
        {xx + if(xx > x2, do: -1, else: 1), yy}
      end

    grid = Map.put(grid, {xx, yy}, "#")
    if xx !== x2 or yy !== y2, do: draw_line(xx, yy, x2, y2, grid), else: grid
  end

  defp clamp_coordinates(coords) do
    {mapping, max} =
      coords
      |> Enum.sort()
      |> Enum.reduce({%{}, 1}, fn coord, {acc, coord_max} ->
        if Map.has_key?(acc, coord) do
          {acc, coord_max}
        else
          {Map.put(acc, coord, coord_max), coord_max + 2}
        end
      end)

    {mapping, max - 1}
  end

  defp is_valid({x, y}, {x2, y2}, flooded_points, mapping_x, mapping_y) do
    left = min(Map.get(mapping_x, x), Map.get(mapping_x, x2))
    right = max(Map.get(mapping_x, x), Map.get(mapping_x, x2))
    top = min(Map.get(mapping_y, y), Map.get(mapping_y, y2))
    bottom = max(Map.get(mapping_y, y), Map.get(mapping_y, y2))

    not Enum.any?(top..bottom, fn yy ->
      Enum.any?(left..right, fn xx ->
        MapSet.member?(flooded_points, {xx, yy})
      end)
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part1(coords) do
    coords
    |> Enum.reduce(%{}, fn [x, y], acc ->
      coords
      |> Enum.reduce(acc, fn [x2, y2], acc_inner ->
        if {x, y} !== {x2, y2} and
             not Map.has_key?(acc_inner, {{x, y}, {x2, y2}}) and
             not Map.has_key?(acc_inner, {{x2, y2}, {x, y}}) do
          Map.put(
            acc_inner,
            {{x, y}, {x2, y2}},
            (abs(x - x2) + 1) * (abs(y - y2) + 1)
          )
        else
          acc_inner
        end
      end)
    end)
    |> Map.values()
    |> Enum.max()
  end

  def part2(coords) do
    Agent.start_link(fn -> %{} end, name: :points)
    Agent.start_link(fn -> %{} end, name: :edges)

    {mapping_x, max_x} = clamp_coordinates(coords |> Enum.map(fn [x, _y] -> x end))
    {mapping_y, max_y} = clamp_coordinates(coords |> Enum.map(fn [_x, y] -> y end))

    grid =
      coords
      |> Enum.reduce(%{}, fn [x, y], acc ->
        Map.put(acc, {x, y}, "#")
      end)

    {grid, prev_x, prev_y} =
      coords
      |> Enum.reduce({grid, nil, nil}, fn [x, y], {grid, prev_x, prev_y} ->
        tx = Map.get(mapping_x, x)
        ty = Map.get(mapping_y, y)
        grid = Map.put(grid, {tx, ty}, "#")

        grid =
          if prev_x != nil do
            draw_line(prev_x, prev_y, tx, ty, grid)
          else
            grid
          end

        {grid, tx, ty}
      end)

    start =
      coords
      |> hd()
      |> List.to_tuple()

    grid =
      draw_line(
        prev_x,
        prev_y,
        Map.get(mapping_x, elem(start, 0)),
        Map.get(mapping_y, elem(start, 1)),
        grid
      )
      |> Map.put({0, 0}, "*")

    grid = flood([0], grid, max_x, max_y)

    flooded_points =
      grid
      |> Stream.filter(fn {_, v} -> v == "*" end)
      |> Stream.map(fn {coord, _} -> coord end)
      |> MapSet.new()

    coords
    |> Combination.combine(2)
    |> Enum.reduce(0, fn [[x, y], [x2, y2]], acc ->
      if x !== x2 and y != y2 do
        area = (abs(x - x2) + 1) * (abs(y - y2) + 1)

        if area > acc and is_valid({x, y}, {x2, y2}, flooded_points, mapping_x, mapping_y) do
          area
        else
          acc
        end
      else
        acc
      end
    end)
  end
end

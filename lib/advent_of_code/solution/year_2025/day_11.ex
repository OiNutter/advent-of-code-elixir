defmodule AdventOfCode.Solution.Year2025.Day11 do
  use AdventOfCode.Solution.SharedParse
  use Agent

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      [key, connections] = String.split(line, ": ", trim: true)
      Map.put(acc, key, String.split(connections, " ", trim: true))
    end)
  end

  defp count_paths(
         device,
         devices,
         required \\ MapSet.new(),
         visited_required \\ MapSet.new(),
         memo \\ %{}
       ) do
    # Memoization key: {device, visited_required}
    key = {device, visited_required}

    cond do
      Map.has_key?(memo, key) ->
        {Map.get(memo, key), memo}

      true ->
        connections = Map.get(devices, device, [])

        # Update visited_required if current device is in required set
        new_visited_required =
          if MapSet.member?(required, device) do
            MapSet.put(visited_required, device)
          else
            visited_required
          end

        if Enum.empty?(connections) do
          # Endpoint - check if we visited all required points
          result =
            if MapSet.size(required) == 0 or
                 MapSet.size(new_visited_required) == MapSet.size(required) do
              1
            else
              0
            end

          {result, Map.put(memo, key, result)}
        else
          # Sum paths from all connections
          {total, new_memo} =
            Enum.reduce(connections, {0, memo}, fn conn, {count, m} ->
              {path_count, updated_memo} =
                count_paths(conn, devices, required, new_visited_required, m)

              {count + path_count, updated_memo}
            end)

          {total, Map.put(new_memo, key, total)}
        end
    end
  end

  def part1(devices) do
    Map.get(devices, "you")
    |> Enum.reduce(0, fn device, acc ->
      {count, _} = count_paths(device, devices)
      acc + count
    end)
  end

  def part2(devices) do
    Agent.start_link(fn -> %{} end, name: :paths)

    Map.get(devices, "svr")
    |> Enum.reduce(0, fn device, acc ->
      {count, _} = count_paths(device, devices, MapSet.new(["dac", "fft"]))
      acc + count
    end)
  end
end

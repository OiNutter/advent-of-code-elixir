defmodule AdventOfCode.Solution.Year2025.Day10 do
  alias Dantzig.Polynomial
  alias Dantzig.Problem
  use AdventOfCode.Solution.SharedParse

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{"indicator" => indicator, "schematics" => schematics, "joltage" => joltage} =
        Regex.named_captures(
          ~r/\[(?<indicator>(\.|#)+)\] (?<schematics>\(.+\)+)+ {(?<joltage>.+)}/,
          line
        )

      %{
        :indicator => indicator |> String.graphemes(),
        :schematics =>
          schematics
          |> String.split(" ", trim: true)
          |> Enum.map(fn s ->
            Regex.replace(~r/(\(|\))/, s, "")
            |> String.split(",", trim: true)
            |> Enum.map(&String.to_integer/1)
          end),
        :joltage =>
          joltage
          |> String.split(",", trim: true)
          |> Enum.map(&String.to_integer/1)
          |> List.to_tuple()
      }
    end)
  end

  defp press_button(target, lights, schematics) do
    do_bfs(
      :queue.from_list([{lights, 0}]),
      Enum.join(target),
      schematics,
      MapSet.new([Enum.join(lights)])
    )
  end

  defp do_bfs(queue, target_str, schematics, visited) do
    case :queue.out(queue) do
      # No solution found
      {:empty, _} ->
        nil

      {{:value, {lights, presses}}, queue} ->
        lights_str = List.to_string(lights)

        if lights_str == target_str do
          presses
        else
          next_states =
            for b <- schematics do
              new_lights =
                Enum.reduce(b, lights, fn index, acc ->
                  List.update_at(acc, index, fn v -> if v == ?#, do: ?., else: ?# end)
                end)

              new_lights_str = List.to_string(new_lights)

              if MapSet.member?(visited, new_lights_str) do
                nil
              else
                {new_lights, presses + 1}
              end
            end
            |> Enum.filter(& &1)

          new_visited =
            Enum.reduce(next_states, visited, fn {lights, _}, acc ->
              MapSet.put(acc, List.to_string(lights))
            end)

          do_bfs(
            :queue.join(queue, :queue.from_list(next_states)),
            target_str,
            schematics,
            new_visited
          )
        end
    end
  end

  def part1(machines) do
    machines
    |> Enum.map(fn %{indicator: indicator, schematics: schematics, joltage: _joltage} ->
      press_button(indicator, List.duplicate(?., length(indicator)), schematics)
    end)
    |> Enum.sum()
  end

  def part2(machines) do
    machines
    |> Enum.map(fn %{schematics: schematics, joltage: joltage} ->
      num_counters = tuple_size(joltage)
      num_buttons = length(schematics)

      effects =
        for i <- 0..(num_counters - 1) do
          for s <- Enum.reverse(schematics) do
            if i in s, do: 1, else: 0
          end
        end

      problem =
        Problem.new(direction: :minimize)

      {problem, variables} =
        1..num_buttons
        |> Enum.reduce({problem, []}, fn num, {problem, variables} ->
          {problem, variable} =
            Problem.new_variable(problem, "#{num}", min: 0, type: :integer)

          {problem, [variable | variables]}
        end)

      variables = Enum.reverse(variables)

      effects
      |> Enum.with_index()
      |> Enum.reduce(problem, fn {matrix, index}, problem ->
        applied_vars =
          Enum.zip(matrix, variables)
          |> Enum.filter(fn {val, _} -> val == 1 end)
          |> Enum.map(fn {_, var} -> var end)

        Problem.add_constraint(
          problem,
          Dantzig.Constraint.new(
            Polynomial.sum(applied_vars),
            :==,
            elem(joltage, index)
          )
        )
      end)
      |> Problem.increment_objective(Polynomial.sum(variables))
      |> Dantzig.solve()
      |> elem(1)
    end)
    |> Enum.map(fn solution ->
      solution.variables
      |> Map.values()
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end

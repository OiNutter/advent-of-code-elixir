defmodule AdventOfCode.Solution.Year2025.Day06 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ", trim: true)
    end)
    |> Enum.zip()
    |> Enum.map(fn sum ->
      [operator | args] =
        sum
        |> Tuple.to_list()
        |> Enum.reverse()

      case operator do
        "+" -> Enum.sum(args |> Enum.map(&String.to_integer/1))
        "*" -> Enum.product(args |> Enum.map(&String.to_integer/1))
      end
    end)
    |> Enum.sum()
  end

  def part2(input) do
    {sums, current} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line |> String.split("", trim: true)
      end)
      |> Enum.zip()
      |> Enum.reduce({[], []}, fn col, {sums, current} ->
        if col |> Tuple.to_list() |> Enum.any?(&(&1 != " ")) do
          {sums, [col | current]}
        else
          {[current | sums], []}
        end
      end)

    sums = [current | sums]

    sums
    |> Enum.map(fn sum ->
      {operator, args} =
        sum
        |> Enum.reduce({nil, []}, fn col, {op, args} ->
          [operator | arg] =
            col
            |> Tuple.to_list()
            |> Enum.reverse()

          {if(operator != " ", do: operator, else: op),
           [
             arg
             |> Enum.reverse()
             |> Enum.join()
             |> String.trim()
             |> String.to_integer()
             | args
           ]}
        end)

      case operator do
        "+" -> Enum.sum(args)
        "*" -> Enum.product(args)
      end
    end)
    |> Enum.sum()
  end
end

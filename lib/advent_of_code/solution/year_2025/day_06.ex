defmodule AdventOfCode.Solution.Year2025.Day06 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ", trim: true)
    end)
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.reduce(0, fn sum, acc ->
      [operator | args] =
        sum
        |> Enum.reverse()

      case operator do
        "+" -> Enum.sum(args |> Enum.map(&String.to_integer/1)) + acc
        "*" -> Enum.product(args |> Enum.map(&String.to_integer/1)) + acc
      end
    end)
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.to_charlist()
    end)
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.chunk_by(fn col -> col |> Enum.any?(&(&1 !== ?\s)) end)
    |> Enum.filter(&(length(&1) > 1))
    |> Enum.reduce(0, fn sum, acc ->
      [first | _] = sum
      [operator | _] = first |> Enum.reverse()

      args =
        sum
        |> Enum.map(fn col ->
          col
          |> Enum.drop(-1)
          |> Enum.filter(&(&1 !== ?\s))
          |> List.to_integer()
        end)

      case operator do
        ?+ -> Enum.sum(args) + acc
        ?* -> Enum.product(args) + acc
      end
    end)
  end
end

defmodule AdventOfCode.Solution.Year2025.Day03 do
  def max_prefix(bank, n) do
    bank
    |> Enum.reverse()
    |> Enum.drop(n - 1)
    |> Enum.max()
  end

  def max_joltage(bank, n \\ 12, joltage \\ [])

  def max_joltage(_bank, 0, joltage) do
    joltage
  end

  def max_joltage(bank, n, joltage) do
    start = max_prefix(bank, n)
    [_start | tail] = bank |> Enum.drop_while(fn j -> j < start end)
    max_joltage(tail, n - 1, joltage ++ [start])
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn bank ->
      max_joltage(
        bank
        |> String.to_charlist(),
        2
      )
    end)
    |> Enum.map(&List.to_integer/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn bank ->
      max_joltage(
        bank
        |> String.to_charlist()

      )
    end)
    |> Enum.map(&List.to_integer/1)
    |> Enum.sum()
  end
end

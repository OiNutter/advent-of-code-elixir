defmodule Mix.Tasks.Advent.Gen do
  use Mix.Task
  require Mix.Generator

  @shortdoc "Generates source files for a new year of Advent of Code puzzles"

  @moduledoc """
  # USAGE
  ```
  mix advent.gen <--year <year>>
  ```

  # DESCRIPTION
  Generates source files for a new year of Advent of Code puzzles and populates them with boilerplate code.

  ```
  /
  |- inputs/
  | |- ${YEAR}/
  | | | - 1.aocinput.example
  | | | - 2.aocinput.example
  | | | - ...
  | | | - 25.aocinput.example
  |- lib/
  | |- advent_of_code/
  | | |- solution/
  | | | |- year_${YEAR}/
  | | | | |- day_01.ex
  | | | | |- day_02.ex
  | | | | |- ...
  | | | | |- day_25.ex
  |- test/
  | |- advent_of_code/
  | | |- solution/
  | | | |- year_${YEAR}/
  | | | | |- day_01_test.ex
  | | | | |- day_02_test.ex
  | | | | |- ...
  | | | | |- day_25_test.ex
  ```
  """

  defmodule Args do
    @type t :: %__MODULE__{
            year: integer,
            days: 1..25
          }

    @enforce_keys [:year]
    defstruct @enforce_keys ++ [days: 25]

    @spec parse(list(String.t())) :: {:ok, t()} | :error
    def parse(raw_args) do
      {parsed, argv, invalid} = OptionParser.parse(raw_args, opts())
      parsed = Map.new(parsed) |> IO.inspect()

      cond do
        argv != [] ->
          task_name = Mix.Task.task_name(Mix.Tasks.Advent.Gen)

          Mix.shell().error(
            "Unrecognized argument(s): #{inspect(argv)}. `#{task_name}` does not take any arguments; only options."
          )

          :error

        invalid != [] ->
          Mix.shell().error("Invalid option(s): #{inspect(invalid)}")

          :error

        Map.has_key?(parsed, :days) and parsed.days not in 1..25 ->
          Mix.shell().error(
            "Invalid --days option. If specified --days must be an integer in 1..25."
          )

          :error

        true ->
          parsed
          |> IO.inspect()
          |> Map.put_new_lazy(:year, &default_year/0)
          |> Map.put_new_lazy(:days, fn -> 25 end)
          |> then(&struct!(__MODULE__, &1))
          |> then(&{:ok, &1})
      end
    end

    defp opts do
      [
        aliases: [y: :year, d: :days],
        strict: [
          year: :integer,
          days: :integer
        ]
      ]
    end

    defp default_year do
      now_est = DateTime.now!("America/New_York")
      if now_est.month == 12, do: now_est.year, else: now_est.year - 1
    end
  end

  @impl Mix.Task
  def run(args) do
    with {:ok, args} = Args.parse(args) do
      generate(args.year, args.days)
    end
  end

  defp generate(year, num_days) do
    inputs_dir = Path.join(inputs_root_dir(), Integer.to_string(year))
    solution_dir = Path.join(lib_root_dir(), year_subdir(year))
    test_dir = Path.join(test_root_dir(), year_subdir(year))

    Enum.each([solution_dir, test_dir, inputs_dir], &Mix.Generator.create_directory/1)

    days = 1..min(num_days, 25)

    Enum.each(
      days,
      &Mix.Generator.create_file(
        Path.join(
          solution_dir,
          :io_lib.format("day_~2..0B.ex", [&1])
        ),
        solution_template(year: year, day: &1)
      )
    )

    Enum.each(
      days,
      &Mix.Generator.create_file(
        Path.join(
          test_dir,
          :io_lib.format("day_~2..0B_test.exs", [&1])
        ),
        test_template(year: year, day: &1)
      )
    )

    Enum.each(
      days,
      &Mix.Generator.create_file(
        Path.join(
          inputs_dir,
          ~w[#{&1}.aocinput.example]
        ),
        ""
      )
    )
  end

  defp lib_root_dir, do: Path.join(File.cwd!(), "lib")
  defp test_root_dir, do: Path.join(File.cwd!(), "test")
  defp inputs_root_dir, do: Path.join(File.cwd!(), "inputs")

  defp year_subdir(year), do: Path.join(~w[advent_of_code solution year_#{year}])

  Mix.Generator.embed_template(:solution, """
  defmodule AdventOfCode.Solution.Year<%= @year %>.Day<%= :io_lib.format("~2..0B", [@day]) %> do
    def part1(_input) do
    end

    def part2(_input) do
    end
  end
  """)

  Mix.Generator.embed_template(:test, """
  defmodule AdventOfCode.Solution.Year<%= @year %>.Day<%= :io_lib.format("~2..0B", [@day]) %>Test do
    use ExUnit.Case, async: true

    import AdventOfCode.Solution.Year<%= @year %>.Day<%= :io_lib.format("~2..0B", [@day]) %>

    setup do
      [
        input: \"""
        \"""
      ]
    end

    @tag :skip
    test "part1", %{input: input} do
      result = part1(input)

      assert result
    end

    @tag :skip
    test "part2", %{input: input} do
      result = part2(input)

      assert result
    end
  end
  """)
end

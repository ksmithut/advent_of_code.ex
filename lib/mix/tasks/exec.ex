defmodule Mix.Tasks.Exec do
  @moduledoc """
  A mix task to run your Advent of Code solution based on the input you've put in at input/{year}/{day}.txt

  Examples

      mix exec --year 2021 --day 25 --part 1
      mix exec -y 2021 -d 25 -p 1
      mix exec -y 2019 -d 5                   # assume part 1
      mix exec -y 2015 -p 2                   # assume day 1
      mix exec -d 20                          # assume current year
      mix exec -y 2015 -d 1 -p 2 --input "()" # pass in custom input
      mix exec 2015 1 2 "()"                  # positional arguments work as well
      mix exec 7 "())("                       # if first number isn't 2015 or greater, it will assume current year
      mix exec 2020 2 --sample                # runs year 2020 day 2 with the sample input defined by a sample function
  """
  @shortdoc "Run the given Advent of Code solution"
  use Mix.Task

  def run(args) do
    {year, day, part, input} = parse_args!(args)

    case AdventOfCode.run_part(year, day, part, input) do
      {:ok, value} -> if is_binary(value), do: IO.puts(value), else: IO.inspect(value)
      {:error, reason} -> IO.warn(reason)
    end
  end

  def current_year() do
    %{year: year, month: month} = Date.utc_today()

    case month do
      12 -> year
      11 -> year
      _ -> year - 1
    end
  end

  def parse_args!(args) do
    switches = [year: :integer, day: :integer, part: :integer, input: :string, sample: :boolean]
    aliases = [y: :year, d: :day, p: :part, i: :input, s: :sample]

    opts =
      case OptionParser.parse(args, aliases: aliases, strict: switches) do
        {opts, [], []} -> opts
        {opts, args, []} -> parse_positional_args(opts, args)
        {_, [], any} -> Mix.raise("Invalid option(s): #{inspect(any)}")
        {_, any, _} -> Mix.raise("Unexpected argument(s): #{inspect(any)}")
      end

    input = if opts[:input] == nil, do: nil, else: String.replace(opts[:input], "\\n", "\n")
    input = if opts[:sample], do: :sample, else: input

    {opts[:year] || current_year(), opts[:day] || 1, opts[:part] || 1, input}
  end

  defp parse_positional_args(opts, args) do
    Enum.reduce(args, opts, fn arg, opts ->
      value =
        case Integer.parse(arg) do
          {value, _} -> value
          _ -> nil
        end

      cond do
        value in 2015..3000 and opts[:year] == nil -> Keyword.put(opts, :year, value)
        value in 1..25 and opts[:day] == nil -> Keyword.put(opts, :day, value)
        value in 1..2 and opts[:part] == nil -> Keyword.put(opts, :part, value)
        opts[:input] == nil -> Keyword.put(opts, :input, arg)
        true -> Mix.raise("Unknown arg: #{arg}")
      end
    end)
  end
end

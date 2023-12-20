defmodule AdventOfCode do
  @callback part_1(String.t()) :: any()
  @callback part_2(String.t()) :: any()
  @callback input() :: String.t()
  @callback sample() :: String.t()
  @optional_callbacks sample: 0

  def run_part(year, day, part, input) do
    module =
      Module.concat(
        String.to_atom("Y#{year}"),
        String.to_atom("D#{pad_day(day)}")
      )

    input =
      case input do
        :sample -> module.sample()
        nil -> module.input()
        input -> input
      end

    case part do
      1 -> {:ok, module.part_1(input)}
      2 -> {:ok, module.part_2(input)}
      _ -> {:error, "no such part_#{part}"}
    end
  end

  @template Path.join(["lib", "template.eex"])
  @session_env "ADVENT_OF_CODE_SESSION"

  @spec generate(integer, integer) :: {:ok, binary(), binary()} | {:error, any()}
  def generate(year, day) do
    template_opts = [year: year, day: day, padded_day: pad_day(day)]

    with session <- System.get_env(@session_env),
         {:ok, input} <- fetch_input(year, day, session),
         code = EEx.eval_file(@template, template_opts) do
      input_filepath = input_path(year, day) |> create_file(input)
      code_filepath = code_path(year, day) |> create_file(code)
      {:ok, input_filepath, code_filepath}
    else
      {:error, error} ->
        IO.warn(error, [])
        {:error, error}
    end
  end

  defp pad_day(day), do: day |> to_string() |> String.pad_leading(2, "0")
  defp input_path(year, day), do: Path.join(["input", "#{year}", "#{pad_day(day)}.txt"])
  defp code_path(year, day), do: Path.join(["lib", "#{year}", "#{pad_day(day)}.ex"])

  defp fetch_input(_, _, nil), do: ""
  defp fetch_input(_, _, ""), do: ""

  defp fetch_input(year, day, session) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)
    url = ~c"https://adventofcode.com/#{year}/day/#{day}/input"
    headers = [{~c"Cookie", ~c"session=#{session}"}]
    options = [ssl: [verify: :verify_none]]

    case :httpc.request(:get, {url, headers}, options, []) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        {:ok, body}

      {:ok, {{_, 404, _}, _headers, _body}} ->
        {:error, "Input not found (yet?)"}

      {:ok, {{_, 400, _}, _headers, _body}} ->
        {:error, "Invalid session"}

      error ->
        IO.inspect(error)
        {:error, "Invalid adventofcode.com session"}
    end
  end

  defp create_file(path, contents) do
    :ok = File.mkdir_p!(Path.dirname(path))

    case File.exists?(path) do
      true ->
        IO.warn("File already exists at #{path}", [])
        path

      _ ->
        :ok = File.write!(path, contents)
        IO.puts("Generated #{path}")
        path
    end
  end

  defmodule TestHelper do
    import ExUnit.DocTest

    defmacro advent_test(year, day, opts \\ []) do
      skip = opts == :skip or opts[:skip] == true

      unless skip do
        quote do
          doctest AdventOfCode.module_name(unquote(year), unquote(day)), import: true
        end
      end
    end
  end
end

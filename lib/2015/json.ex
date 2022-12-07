defmodule JSON do
  def parse(str) do
    with {:ok, tokens, _} <- :json_lexer.string(to_charlist(str)),
         {:ok, json} <- :json_parser.parse(tokens) do
      {:ok, json}
    else
      other -> other
    end
  end

  def parse!(str) do
    case parse(str) do
      {:ok, json} -> json
      other -> raise other
    end
  end
end

defmodule Amethyst.Lexer do

  @doc """
    Converts Amethyst source code to tokens
  """
  @spec tokenize(String.t) :: list
  def tokenize(amethyst_src) do
    IO.puts "Tokenizing"

    amethyst_src
    |> String.trim() # Trim entire source leading + trailing whitespace
    |> create_tokens()
    |> IO.inspect()
  end

  defp create_tokens(src, tokens \\ [])

  defp create_tokens(<<>>, tokens) do
    tokens
    |> Enum.filter(& &1 != :whitespace)
    |> Enum.reverse()
  end

  defp create_tokens(<<char::bytes-size(1), src::binary>>, tokens) do
    # {type, value}

    {token, src} =
      cond do
        char in [" ", "\n"] -> {:whitespace, src}
        char == "=" -> {:assignment, src}
        char in ["\"", "'"] ->
          [string, rest] = String.split(src, char, parts: 2)
          {{:string, string}, rest}
        Regex.match?(~r/[a-zA-Z]/, char) ->
          [symbol, rest] = String.split(src, ~r/[^a-zA-Z0-9_$]/, parts: 2)
          {{:symbol, char <> symbol}, rest}
      end

    create_tokens(src, [token | tokens])
  end

end

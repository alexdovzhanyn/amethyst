defmodule Amethyst.Lexer do
  alias Amethyst.Exception

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

  defp create_tokens(src, tokens \\ [], ln \\ 1, pos \\ 1)

  defp create_tokens(<<>>, tokens, _ln, _pos) do
    tokens
    |> Enum.filter(& &1 not in [:whitespace, :newline])
    |> Enum.reverse()
  end

  defp create_tokens(<<char::bytes-size(1), src::binary>>, tokens, ln, pos) do
    # Tokens typically have the structure of {type, value}

    {token, src} =
      cond do
        char == " " -> {:whitespace, src}
        char == "\n" -> {:newline, src}
        char == "=" ->
          <<next_char::bytes-size(1), rest::binary>> = src

          if next_char == "=", do: {:equality_check, rest}, else: {:assignment, src}
        char in ["\"", "'"] ->
          [string, rest] = String.split(src, char, parts: 2)
          {{:string, string}, rest}
        char in ["[", "]", "{", "}", "(", ")", ","] -> {{:construct, char}, src}
        Regex.match?(~r/[a-zA-Z]/, char) ->
          [symbol, rest] = String.split(src, ~r/[^a-zA-Z0-9_$]/, parts: 2)

          # When we split on the regex we lose a character at the point of the split.
          # Let's find it and add it back to the src so it gets parsed
          split_char = String.at(src, String.length(symbol))
          {{:symbol, char <> symbol}, split_char <> rest}
        Regex.match?(~r/[0-9]/, char) -> scan_number(char, src, ln, pos)
        true -> Exception.raise(:syntax_error, "syntax error at '#{char}' [#{ln}:#{pos}]")
      end

    # Update line number & position counters
    {ln, pos} = update_counters(token, ln, pos)

    create_tokens(src, [token | tokens], ln, pos)
  end

  # Scans through source to assemble a numerical value, which can be an integer,
  # float, or a decimal
  @spec scan_number(binary, binary, integer, integer) :: {{atom, binary}, binary}
  defp scan_number(num, <<>>, _ln, _pos), do: finish_number_scan(num, <<>>)

  defp scan_number(num, src, ln, pos) do
    <<char::bytes-size(1), rest::binary>> = src

    cond do
      Regex.match?(~r/[^\.0-9]/, char) -> finish_number_scan(num, src)
      char == "." && String.last(num) != "." && String.contains?(num, ".") ->
        Exception.raise(:syntax_error, "syntax error at '#{char}' [#{ln}:#{pos}]")
      true -> scan_number(num <> char, rest, ln, pos + 1)
    end
  end

  defp finish_number_scan(num, src) do
    # We've reached end of number definition
    type =
      cond do
        String.contains?(num, "..") -> :decimal
        String.contains?(num, ".") -> :float
        true -> :integer
      end

    {{type, num}, src}
  end

  defp update_counters(:newline, ln, _pos), do: {ln + 1, 1}
  defp update_counters(:equality_check, ln, pos), do: {ln, pos + 2}
  defp update_counters(t, ln, pos) when t in [:whitespace, :assignment], do: {ln, pos + 1}
  defp update_counters({_, val}, ln, pos), do: {ln, pos + String.length(val)}
end

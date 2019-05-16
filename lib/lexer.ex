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
    |> IO.inspect(limit: :infinity)
  end

  defp create_tokens(src, tokens \\ [], ln \\ 1, pos \\ 1)

  defp create_tokens(<<>>, tokens, _ln, _pos) do
    tokens
    |> Enum.filter(& &1 not in [:whitespace, :newline, :comment])
    |> Enum.reverse()
  end

  defp create_tokens(src, tokens, ln, pos) do
    # Tokens typically have the structure of {type, value}

    {token, src} = parse_src(src, ln, pos)

    # Update line number & position counters
    {ln, pos} = update_counters(token, ln, pos)

    create_tokens(src, [token | tokens], ln, pos)
  end

  defp parse_src(" " <> src, _ln, _pos), do: {:whitespace, src}
  defp parse_src("\n" <> src, _ln, _pos), do: {:newline, src}
  defp parse_src("==" <> src, _ln, _pos), do: {:==, src}
  defp parse_src("=>" <> src, _ln, _pos), do: {:arrow, src}
  defp parse_src("=" <> src, _ln, _pos), do: {:=, src}
  defp parse_src("true" <> src, _ln, _pos), do: {{:boolean, "true"}, src}
  defp parse_src("false" <> src, _ln, _pos), do: {{:boolean, "false"}, src}
  defp parse_src("if" <> src, _ln, _pos), do: {{:token, "if"}, src}
  defp parse_src("then" <> src, _ln, _pos), do: {{:token, "then"}, src}
  defp parse_src("else" <> src, _ln, _pos), do: {{:token, "else"}, src}
  defp parse_src("end" <> src, _ln, _pos), do: {{:token, "end"}, src}
  defp parse_src("func" <> src, _ln, _pos), do: {{:token, "func"}, src}

  defp parse_src("--" <> src, _ln, _pos) do
    [_comment, rest] = String.split(src, "\n", parts: 2)
    {:comment, "\n" <> rest}
  end

  defp parse_src(<<c::bytes-size(1), src::binary>>, _ln, _pos) when c in ["\"", "'"] do
    [string, rest] = String.split(src, c, parts: 2)
    {{:string, string}, rest}
  end

  defp parse_src(<<c::bytes-size(1), src::binary>>, _ln, _pos) when c in ["[", "]", "{", "}", "(", ")", ","] do
    {{:construct, c}, src}
  end

  # Should only get here if we couldn't parse language constructs above.
  # Things here should really only be symbols or numbers
  defp parse_src(<<char::bytes-size(1), src::binary>>, ln, pos) do
    cond do
      Regex.match?(~r/[a-zA-Z]/, char) ->
        [symbol, rest] = String.split(src, ~r/[^a-zA-Z0-9_$]/, parts: 2)

        # When we split on the regex we lose a character at the point of the split.
        # Let's find it and add it back to the src so it gets parsed
        split_char = String.at(src, String.length(symbol))
        {{:symbol, char <> symbol}, split_char <> rest}
      Regex.match?(~r/[0-9]/, char) -> scan_number(char, src, ln, pos)
      true -> Exception.raise(:syntax_error, "syntax error at '#{char}' [#{ln}:#{pos}]")
    end
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
        Exception.raise(:syntax_error, "syntax error at '#{char}' [#{ln}:#{pos + 1}]")
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
  defp update_counters(:comment, ln, pos), do: {ln, pos}
  defp update_counters(:==, ln, pos), do: {ln, pos + 2}
  defp update_counters(:whitespace, ln, pos), do: {ln, pos + 1}
  defp update_counters(:=, ln, pos), do: {ln, pos + 1}
  defp update_counters(:arrow, ln, pos), do: {ln, pos + 2}
  defp update_counters({_, val}, ln, pos), do: {ln, pos + String.length(val)}
end

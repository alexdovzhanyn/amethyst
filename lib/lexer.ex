defmodule Amethyst.Lexer do

  @doc """
    Converts Amethyst source code to tokens
  """
  @spec tokenize(String.t) :: list
  def tokenize(amethyst_src) do
    IO.puts "Tokenizing"

    amethyst_src
    |> String.trim() # Trim entire source leading + trailing whitespace
    |> String.split("\n") # Split into array of lines
    |> Enum.map(&String.trim/1) # Trim each line of the source
    |> IO.inspect()
  end

end

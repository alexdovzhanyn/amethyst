defmodule Amethyst.Exception do
  def raise(type, error) do
    t =
      type
      |> to_string()
      |> String.upcase()
      |> String.replace("_", " ")

    IO.puts("#{t} :: #{error}")
    exit(:normal)
  end
end

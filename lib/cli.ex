defmodule Amethyst.CLI do
  def main([command | args]) do
    if "--debug" in args do
      IO.puts "Debug mode enabled"
      IO.inspect([command | args], label: "Called with arguments")
    end

    case command do
      "compile" -> compile(args)
      "-v" ->
        {:ok, v} = :application.get_key(:amethyst, :vsn)
        IO.puts "\nAmethyst #{v}"
        # IO.inspect(:application.get_all_key(:amethyst))
      _ -> IO.puts("Amethyst command not found: '#{command}'")
    end
  end

  def compile([path | args]) do
    with true <- String.ends_with?(path, ".amt") || {:error, :invft},
         {:ok, src} <- File.read(path)
    do
      Amethyst.Lexer.tokenize(src)
    else
      {:error, :enoent} -> IO.puts("Could not compile #{path}, ENOENT")
      {:error, :invft} -> IO.puts "Could not compile #{path}. Unrecognized file type."
    end
  end
end

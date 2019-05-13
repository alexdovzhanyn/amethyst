defmodule AmethystTest do
  use ExUnit.Case
  doctest Amethyst

  test "greets the world" do
    assert Amethyst.hello() == :world
  end
end

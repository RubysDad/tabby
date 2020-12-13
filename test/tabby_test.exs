defmodule TabbyTest do
  use ExUnit.Case
  doctest Tabby

  test "greets the world" do
    assert Tabby.hello() == :world
  end
end

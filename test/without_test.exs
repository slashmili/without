defmodule WithoutTest do
  use ExUnit.Case
  doctest Without

  test "greets the world" do
    assert Without.hello() == :world
  end
end

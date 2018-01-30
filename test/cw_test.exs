defmodule CWTest do
  use ExUnit.Case
  doctest CW

  test "greets the world" do
    assert CW.hello() == :world
  end
end

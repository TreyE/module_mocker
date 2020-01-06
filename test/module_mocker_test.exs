defmodule ModuleMockerTest do
  use ExUnit.Case
  doctest ModuleMocker

  test "greets the world" do
    assert ModuleMocker.hello() == :world
  end
end

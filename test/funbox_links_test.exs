defmodule FunboxLinksTest do
  use ExUnit.Case
  doctest FunboxLinks

  test "greets the world" do
    assert FunboxLinks.hello() == :world
  end
end

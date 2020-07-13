defmodule FunboxLinks.Database_functions.Test do
  use ExUnit.Case, async: false
  alias FunboxLinks.Database_functions, as: Db

  setup do
    Redix.command!(:redix, ["SELECT", 1])

    on_exit(fn ->
      Redix.command!(:redix, ["SELECT", 1])
      Redix.command!(:redix, ["FLUSHDB"])
    end)
  end

  test "insert/get test, :ok" do
    Db.update_domains(111, ~w<vk.com google.com>)
    domains = Db.get_domains_info(%{"from" => 111, "to" => 111})
    assert Enum.sort(domains) == Enum.sort(~w<vk.com google.com>)
  end

  test "insert/get test with equal timestamps, :ok" do
    Db.update_domains(222, ~w<test.com>)
    Db.update_domains(222, ~w<www.onemore.ru>)
    domains = Db.get_domains_info(%{"from" => 222, "to" => 222})

    assert Enum.sort(domains) == Enum.sort(~w<test.com www.onemore.ru>)
  end

  test "insert/get test, expose DB error, :error" do
    assert_raise Redix.Error, "ERR value is not a valid float", fn ->
      Db.update_domains("aaa", ~w<bbc.com www.moex.ru>)
    end

    assert_raise Redix.Error, "ERR min or max is not a float", fn ->
      Db.get_domains_info(%{"from" => "aaa", "to" => "aaa"}) == {:error, []}
    end
  end
end

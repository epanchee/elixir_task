defmodule FunboxLinks.Database_functions.Test do
  use ExUnit.Case
  alias FunboxLinks.Database_functions, as: Db

  test "insert/get test, :ok" do
    assert Db.update_domains(111, ~w<vk.com google.com>) == :ok
    {status, domains_info} = Db.get_domains_info(%{"from" => 111, "to" => 111})
    assert {status, domains_info |> Enum.sort()} == {:ok, ~w<vk.com google.com> |> Enum.sort()}
  end

  test "insert/get test with equal timestamps, :ok" do
    assert Db.update_domains(222, ~w<test.com>) == :ok
    assert Db.update_domains(222, ~w<www.onemore.ru>) == :ok
    {status, domains_info} = Db.get_domains_info(%{"from" => 222, "to" => 222})

    assert {status, domains_info |> Enum.sort()} ==
             {:ok, ~w<test.com www.onemore.ru> |> Enum.sort()}
  end

  test "insert/get test, expose DB error, :error" do
    assert Db.update_domains("aaa", ~w<bbc.com www.moex.ru>) == :error
    assert Db.get_domains_info(%{"from" => "aaa", "to" => "aaa"}) == {:error, []}
  end
end

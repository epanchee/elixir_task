defmodule FunboxLinks.Auxilary.Test do
  use ExUnit.Case
  alias FunboxLinks.Auxilary, as: Aux

  test "parse_single_domain, :ok - 1" do
    assert Aux.parse_single_domain("https://www.vk.com") == {:ok, "vk.com"}
  end

  test "parse_single_domain, :ok - 2" do
    assert Aux.parse_single_domain("funbox.ru") == {:ok, "funbox.ru"}
  end

  test "parse_single_domain, :ok - 3" do
    assert Aux.parse_single_domain("eto_test.ru?first_var=1") == {:ok, "eto_test.ru"}
  end

  test "parse_single_domain, :error" do
    assert Aux.parse_single_domain("vk..") == {:error, "vk.."}
  end

  test "parse_domains, :ok" do
    domains = %{
      "links" =>
        ~w<www.ya.ru funbox.ru https://vk.com https://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor http://ya.ru?q=123>
    }

    assert Aux.parse_domains(domains) == [ok: "ya.ru", ok: "funbox.ru", ok: "vk.com", ok: "stackoverflow.com", ok: "ya.ru"]
  end

  test "parse_domains, :error" do
    domains = %{"links" => ~w<www.ya.ru funbox.ru https://vk.com rly_bad_str>}
    assert Aux.parse_domains(domains) == [ok: "ya.ru", ok: "funbox.ru", ok: "vk.com", error: "rly_bad_str"]
  end

  test "ok? logger" do
    assert Aux.log(:ok, "test") == :ok
    assert Aux.log(:error, "test") == :error
  end
end

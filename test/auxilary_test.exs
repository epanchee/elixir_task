defmodule FunboxLinks.Auxilary.Test do
  use ExUnit.Case
  alias FunboxLinks.Auxilary, as: Aux
  # doctest FunboxLinks.Auxilary

  test "check_errors_in_array test, :ok" do
    arr = [{:ok, nil}, {:ok, []}, {:ok, ["1", "2", "three"]}]
    assert Aux.check_errors_in_array(arr) == :ok
  end

  test "check_errors_in_array test, :error" do
    arr = [{:ok, nil}, {:error, []}, {:ok, ["1", "2", "three"]}]
    assert Aux.check_errors_in_array(arr) == :error
  end

  test "parse_single_domain, :ok - 1" do
    assert Aux.parse_single_domain("https://www.vk.com") == {:ok, "vk.com"}
  end

  test "parse_single_domain, :ok - 2" do
    assert Aux.parse_single_domain("funbox.ru") == {:ok, "funbox.ru"}
  end

  test "parse_single_domain, :error" do
    assert Aux.parse_single_domain("vk..") == {:error, nil}
  end

  test "parse_domains, :ok" do
    domains = %{
      "links" =>
        ~w<www.ya.ru funbox.ru https://vk.com https://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor http://ya.ru?q=123>
    }

    valid_domains = ~w<ya.ru funbox.ru vk.com stackoverflow.com ya.ru>
    assert Aux.parse_domains(domains) == {:ok, valid_domains}
  end

  test "parse_domains, :error" do
    domains = %{"links" => ~w<www.ya.ru funbox.ru https://vk.com rly_bad_str>}
    valid_domains = ~w<ya.ru funbox.ru vk.com> ++ [nil]
    assert Aux.parse_domains(domains) == {:error, valid_domains}
  end

  test "ok? logger" do
    assert Aux.ok?(:ok, "test") == :ok
    assert Aux.ok?(:error, "test") == :error
  end
end

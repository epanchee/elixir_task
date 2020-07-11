defmodule FunboxLinks.Router.Test do
  use ExUnit.Case, async: true
  use Plug.Test
  alias FunboxLinks.Router, as: Router
  alias FunboxLinks.Database_functions, as: Db

  Router.init([])

  test "check /visited_links, empty query" do
    response = conn(:post, "/visited_links")
    		   |> put_resp_content_type("application/json")
               |> Router.call([])

    assert response.status == 200
    assert Poison.decode!(response.resp_body)["status"] == "error"
  end

  test "check /visited_links, valid query" do
    response = conn(:post, "/visited_links", %{links: ~w<ttt.ru test.au http://pastebin.ru>})
    		   |> put_resp_content_type("application/json")
    		   |> Router.call([])

    assert response.status == 200
    assert Poison.decode!(response.resp_body)["status"] == "ok"
  end

  test "check /visited_domains, valid query" do
  	Db.update_domains(1110, ~w<vk.com google.com>)
    response = conn(:get, "/visited_domains", %{from: 0, to: 2000})
    		   |> put_resp_content_type("application/json")
    		   |> Router.call([])

    assert response.status == 200
    assert Poison.decode!(response.resp_body)["status"] == "ok"
    assert Poison.decode!(response.resp_body)["domains"] |> Enum.sort == ~w<vk.com google.com> |> Enum.sort  	
  end

  test "check /visited_domains, invalid query" do
  	Db.update_domains(1110, ~w<vk.com google.com> |> Enum.sort)
    response = conn(:get, "/visited_domains", %{from: 2000, to: 0})
    		   |> put_resp_content_type("application/json")
    		   |> Router.call([])

    assert response.status == 200
    assert Poison.decode!(response.resp_body)["status"] == "error"
    assert Poison.decode!(response.resp_body)["domains"] == []	
  end

  test "check get /visited_links, invalid query" do
    response = conn(:get, "/visited_links")
           |> put_resp_content_type("application/json")
           |> Router.call([])

    assert response.status == 404
  end

  test "check nonexistent route, invalid query" do
    response = conn(:get, "/qwerqwer")
           |> put_resp_content_type("application/json")
           |> Router.call([])

    assert response.status == 404
  end

end

defmodule FunboxLinks.Router do
  use Plug.Router
  alias FunboxLinks.Database_functions, as: Db
  alias FunboxLinks.Auxilary, as: Aux
  require Logger

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  post "/visited_links" do
    recv_time = :os.system_time(:millisecond)

    status =
      try do
        parse_result = Aux.parse_domains(conn.body_params())
        valid_domains = 
        Enum.filter(parse_result, fn {status, _} -> status == :ok end)
        |> Enum.map(fn {_, link} -> link end)
        invalid_domains =
        Enum.filter(parse_result, fn {status, _} -> status == :error end)
        |> Enum.map(fn {_, domain} -> domain end)
        Db.update_domains(recv_time, valid_domains)
        if length(invalid_domains) == 0, do: "ok", 
        else: "Failed to parse domains: " <> Enum.join(invalid_domains, ",")
      rescue
        e ->
          Aux.log(:error, e.message)
          e.message
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: status}))
  end

  get "/visited_domains" do
    {domains, status_msg} =
      try do
        domains = Db.get_domains_info(conn.query_params())
        {domains, "ok"}
      rescue
        e ->
          Aux.log(:error, e.message)
          {[], "error: " <> e.message}
      end

    send_resp(conn, 200, Poison.encode!(%{status: status_msg, domains: domains}))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
end

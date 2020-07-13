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
        {parse_status, parsed} = Aux.parse_domains(conn.body_params())
        Db.update_domains(recv_time, parsed)
        if parse_status != :error, do: "ok", else: "error"
      rescue
        e ->
          Aux.log(:error, e.message)
          "error"
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
          {[], "error"}
      end

    send_resp(conn, 200, Poison.encode!(%{status: status_msg, domains: domains}))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
end

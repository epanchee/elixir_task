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

    {parse_status, parsed} = Aux.parse_domains(conn.body_params())

    update_status =
      if not is_nil(parsed) do
        Db.update_domains(recv_time, parsed)
      end

    status_msg =
      if parse_status == :error or update_status == :error do
        "error"
      else
        "ok"
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: status_msg}))
  end

  get "/visited_domains" do
    {status, domains} = Db.get_domains_info(conn.query_params())

    status_msg =
      status
      |> (fn
            :ok -> "ok"
            :error -> "error"
          end).()

    send_resp(conn, 200, Poison.encode!(%{status: status_msg, domains: domains}))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
end

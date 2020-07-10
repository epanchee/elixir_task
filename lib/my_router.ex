defmodule FunboxLinks.Router do
  use Plug.Router
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
  	
  	{parse_status, parsed} = parse_domains(conn.body_params())
  	status_msg = parse_status
	  	|> fn (parse_status) ->
  			if update_domains(recv_time, parsed) == :error or parse_status == :error, 
  			do: "error",
  			else: "ok"
	  	   end.()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: status_msg}))
  end

  get "/visited_domains" do
  	{status, domains} = get_domains_info(conn.query_params())
  	status_msg = 
  	if status == :error do
  		"error"
  	else
  		"ok"
  	end
  	send_resp(conn, 200, Poison.encode!(%{status: status_msg, domains: domains}))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  # TODO: decompose

  defp check_errors_in_array(arr) do
  	case Enum.any?(arr, fn(item) -> item |> elem(0) == :error end) do
  		true -> :error
  		false -> :ok
  	end
  end

  defp parse_single_domain(domain_string) do
  	regex = ~r/(https?:\/\/)?(?<domain>[\w.]+[.]\w+)/i
  	result = Regex.named_captures(regex, domain_string)["domain"]
  	status =
	  	case result do
	  		nil -> :error
	  		_   -> :ok
	  	end
	ok?(status, "Parse URL")
	{status, nil}
  end

  defp parse_domains(%{"links" => links}) do
  	parsed = Enum.map(links, fn(link) -> parse_single_domain(link) end)
  	status = check_errors_in_array(parsed)
  	{status, Enum.map(parsed, fn(p_res) -> p_res |> elem(1) end)}
  end

  defp ok?(status, msg) do
  	case status do
		:ok    -> Logger.info("#{msg} OK")
		:error -> Logger.info("#{msg} ERROR")
	end
  	status
  end

  defp update_domains(recv_time, domains) do
  	Enum.map(domains, fn(domain) -> Redix.command(:redix, ["LPUSH", recv_time, domain]) end)
  	|> check_errors_in_array 
  	|> ok?("LPUSH")
  	|> fn
  		(:ok) -> Redix.command(:redix, ["ZADD", "timecodes", recv_time, recv_time])
  		(status) -> {status, nil}
  	   end.()
  	|> elem(0)
  	|> ok?(~S<ZADD "timecodes">)

  end

  def get_domains_info(%{"from" => from, "to" => to}) do
  	redix_cmd_result = Redix.command(:redix, ["ZRANGEBYSCORE", "timecodes", from, to])
  	case redix_cmd_result do
  		{:ok, timecodes} ->
		  	result = Enum.map(timecodes, fn(timecode) -> ({_stat, _result} = Redix.command(:redix, ["LRANGE", timecode, 0, -1])) end)
		  	if result |> check_errors_in_array |> ok?("LRANGE") == :ok do
			  	Enum.map(result, fn(r) -> r |> elem(1) end)
			  	|> List.flatten 
			  	|> Enum.uniq
			  	|> fn(list) -> {:ok, list} end.()
		  	else
		  		{:error, nil}
		  	end
  		
  		{:error, _} -> 
	  		ok?(:error, "ZRANGEBYSCORE")
  			{:error, nil}
  	end
  end
end
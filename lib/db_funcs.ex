defmodule FunboxLinks.Database_functions do
	alias FunboxLinks.Auxilary, as: Aux

	def update_domains(recv_time, domains) do
		Enum.map(domains, fn(domain) -> Redix.command(:redix, ["LPUSH", recv_time, domain]) end)
		|> Aux.check_errors_in_array 
		|> Aux.ok?("LPUSH")
		|> fn
			(:ok) -> Redix.command(:redix, ["ZADD", "timecodes", recv_time, recv_time])
			(status) -> {status, nil}
		   end.()
		|> elem(0)
		|> Aux.ok?(~S<ZADD "timecodes">)
	end

	def get_domains_info(%{"from" => from, "to" => to}) do
		redix_cmd_result = Redix.command(:redix, ["ZRANGEBYSCORE", "timecodes", from, to])
		case redix_cmd_result do
			{:ok, timecodes} ->
		  	result = Enum.map(timecodes, fn(timecode) -> ({_stat, _result} = Redix.command(:redix, ["LRANGE", timecode, 0, -1])) end)
		  	if result |> Aux.check_errors_in_array |> Aux.ok?("LRANGE") == :ok do
			  	Enum.map(result, fn(r) -> r |> elem(1) end)
			  	|> List.flatten 
			  	|> Enum.uniq
			  	|> fn(list) -> {:ok, list} end.()
		  	else
		  		{:error, nil}
		  	end
			
			{:error, _} -> 
	  		Aux.ok?(:error, "ZRANGEBYSCORE")
				{:error, nil}
		end
	end
end
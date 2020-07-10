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
		redix_cmd_result = 
			if from <= to, 
				do: Redix.command(:redix, ["ZRANGEBYSCORE", "timecodes", from, to]),
				else: {:error, []}
		case redix_cmd_result do
			{:ok, timecodes} ->
		  	result = Enum.map(timecodes, fn(timecode) -> Redix.command(:redix, ["LRANGE", timecode, 0, -1]) end)
		  	no_errors? = result |> Aux.check_errors_in_array |> Aux.ok?("LRANGE") == :ok
		  	if no_errors? do
			  	Enum.map(result, &elem(&1,1))
			  	|> List.flatten 
			  	|> Enum.uniq
			  	|> fn(list) -> {:ok, list} end.()
		  	else
		  		{:error, []}
		  	end
			
			{:error, _} -> 
	  		Aux.ok?(:error, "ZRANGEBYSCORE")
				{:error, []}
		end
	end
end
defmodule FunboxLinks.Auxilary do
	require Logger

	def check_errors_in_array(arr) do
		case Enum.any?(arr, fn(item) -> item |> elem(0) == :error end) do
			true -> :error
			false -> :ok
		end
	end

	def parse_single_domain(domain_string) do
		regex = ~r/(https?:\/\/)?(www[.])?(?<domain>[\w.]+[.]\w+)/i
		result = Regex.named_captures(regex, domain_string)["domain"]
		
		status =
	  	case result do
	  		nil -> :error
	  		_   -> :ok
	  	end

		ok?(status, "Parse URL")
		{status, result}
	end

	def parse_domains(%{"links" => links}) do
		parsed = Enum.map(links, fn(link) -> parse_single_domain(link) end)
		status = check_errors_in_array(parsed)
		{status, Enum.map(parsed, fn(p_res) -> p_res |> elem(1) end)}
	end

	def parse_domains(%{}) do
		{:error, nil}
	end

	def ok?(status, msg) do
		case status do
		:ok    -> Logger.info("#{msg} OK")
		:error -> Logger.info("#{msg} ERROR")
	end
		status
	end
end
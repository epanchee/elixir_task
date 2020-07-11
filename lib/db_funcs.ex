defmodule FunboxLinks.Database_functions do
  alias FunboxLinks.Auxilary, as: Aux

  def update_domains(recv_time, domains) do
    domains_list = Enum.flat_map(domains, fn domain -> [recv_time, "#{recv_time}_#{domain}"] end)

    IO.inspect(
      Redix.command(:redix, ["ZADD", "timecodes"] ++ domains_list)
      |> elem(0)
      |> Aux.ok?(~S<ZADD "timecodes">)
    )
  end

  def get_domains_info(%{"from" => from, "to" => to}) do
    if from <= to do
      redix_cmd_result = Redix.command(:redix, ["ZRANGEBYSCORE", "timecodes", from, to])

      if Aux.ok?(elem(redix_cmd_result, 0), "ZRANGEBYSCORE") == :ok do
        Enum.map(elem(redix_cmd_result, 1), &(String.split(&1, "_") |> Enum.at(1)))
        |> Enum.uniq()
        |> (fn list -> {:ok, list} end).()
      else
        {:error, []}
      end
    else
      {:error, []}
    end
  end
end

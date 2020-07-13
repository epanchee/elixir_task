defmodule FunboxLinks.Database_functions do
  alias FunboxLinks.Auxilary, as: Aux

  def update_domains(recv_time, domains) do
    domains_list = Enum.flat_map(domains, fn domain -> [recv_time, "#{recv_time}_#{domain}"] end)

    Redix.command(:redix, ["ZADD", "timecodes"] ++ domains_list)
    |> elem(0)
    |> Aux.log(~S<ZADD "timecodes">)
  end

  def get_domains_info(%{"from" => from, "to" => to}) do
    if from <= to do
      {status, result} = Redix.command(:redix, ["ZRANGEBYSCORE", "timecodes", from, to])

      if Aux.log(status, "ZRANGEBYSCORE") == :ok do
        Enum.map(result, fn link ->
          {ind_, _} = :binary.match(link, "_")
          String.slice(link, ind_+1..-1)
        end)
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

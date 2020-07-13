defmodule FunboxLinks.Database_functions do
  def update_domains(recv_time, domains) do
    domains_list = Enum.flat_map(domains, fn domain -> [recv_time, "#{recv_time}_#{domain}"] end)
    Redix.command!(:redix, ["ZADD", "timecodes"] ++ domains_list)
  end

  def get_domains_info(%{"from" => from, "to" => to}) do
    if from > to, do: raise(WrongTimestampInterval)

    Redix.command!(:redix, ["ZRANGEBYSCORE", "timecodes", from, to])
    |> Enum.map(fn link ->
      {ind_, _} = :binary.match(link, "_")
      String.slice(link, (ind_ + 1)..-1)
    end)
    |> Enum.uniq()
  end
end

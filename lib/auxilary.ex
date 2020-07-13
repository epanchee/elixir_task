defmodule FunboxLinks.Auxilary do
  require Logger

  def check_errors_in_array(arr) do
    case Enum.any?(arr, &(elem(&1, 0) == :error)) do
      true -> :error
      false -> :ok
    end
  end

  def parse_single_domain(domain_string) do
    regex = ~r/(https?:\/\/)?(www[.])?(?<domain>[\w.]+[.]\w+)/i
    result = Regex.named_captures(regex, domain_string)["domain"]

    {status, result} =
      case result do
        nil -> {:error, domain_string}
        _ -> {:ok, result}
      end

    log(status, "Parse URL")
    {status, result}
  end

  def parse_domains(%{"links" => links}) when length(links) > 0 do
    Enum.map(links, &parse_single_domain/1) 
  end

  def parse_domains(%{}) do
    raise EmptyDomainsListError
  end

  def parse_domains(%{"links" => []}) do
    raise EmptyDomainsListError
  end

  def log(status, msg) do
    case status do
      :ok -> Logger.info("#{msg} OK")
      :error -> Logger.error("#{msg} ERROR")
    end

    status
  end
end

defmodule EmptyDomainsListError do
  defexception message: "Empty domain list"
end

defmodule WrongTimestampInterval do
  defexception message: "Wrong timestamp interval. from > to"
end

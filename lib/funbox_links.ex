defmodule FunboxLinks.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: FunboxLinks.Router, options: [port: 4000]},
      {Redix, name: :redix}
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

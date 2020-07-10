defmodule FunboxLinks.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: FunboxLinks.Router, options: [port: 4000, ip: {0,0,0,0}]},
      {Redix, name: :redix, host: System.get_env("REDIS_ADDR"), port: 6379}
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

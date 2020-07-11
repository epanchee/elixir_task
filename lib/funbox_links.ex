defmodule FunboxLinks.Application do
  use Application
  require Logger

  def start(_type, _args) do
    IO.puts Mix.env
    port = fn 
      :test -> 4001
      _ -> 4000
    end.(Mix.env)
    children = [
      {Plug.Cowboy, scheme: :http, plug: FunboxLinks.Router, options: [port: port, ip: {0,0,0,0}]},
      {Redix, name: :redix, host: System.get_env("REDIS_ADDR"), port: 6379}
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

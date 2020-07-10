defmodule FunboxLinks.MixProject do
  use Mix.Project

  def project do
    [
      app: :funbox_links,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FunboxLinks.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.10"},
      {:cowboy, "~> 2.8"},
      {:poison, "~> 4.0"},
      {:plug_cowboy, "~> 2.3"},
      {:redix, ">= 0.0.0"},
    ]
  end
end

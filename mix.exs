defmodule Tabby.MixProject do
  use Mix.Project

  def project do
    [
      app: :tabby,
      version: "0.1.0",
      description: "A Http Server",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {Tabby, []}, # mod specifies the callback module to be invoked when the app has started
      env: [port: 3000] # going to add key-value pair to app environment
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.6"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

defmodule Tabby.Supervisor do
  use Supervisor

  def start_link do
    IO.puts "Starting THE supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__) # first arg is callback module
  end

  def init(:ok) do # automatically invoked when we start the supervisor
    children = [
      Tabby.KickStarter,
      Tabby.ServicesSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Tabby.ServicesSupervisor do
  use Supervisor

  def start_link(_args) do
    IO.puts "Starting the services supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__) # first arg is callback module
  end

  def init(:ok) do # automatically invoked when we start the supervisor
    children = [
      Tabby.PledgeServer,
      {Tabby.SensorServer, 60}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

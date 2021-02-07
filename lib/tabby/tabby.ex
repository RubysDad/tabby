defmodule Tabby do
  use Application

  def start(_type, _args) do  # this will be invoked when the application starts
    IO.puts "Starting the application..."
    Tabby.Supervisor.start_link
  end
end

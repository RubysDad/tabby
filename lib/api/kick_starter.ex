defmodule Tabby.KickStarter do
  use GenServer

  def start do
    IO.puts "Starting the kickstarter..."
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = start_server
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts "HTTPServer exited (#{inspect reason})"
    server_pid = start_server
    {:noreply, server_pid}
  end

  defp start_server do
    IO.puts "Starting the HTTP server..."
    server_pid = spawn_link(Tabby.HttpServer, :start, [4000]) # spawb_link is short cut to spawn and then Process.link
    Process.register(server_pid, :http_server)
    server_pid
  end
end

#iex(1)> {:ok, kick_pid} = Tabby.KickStarter.start
#Starting the kickstarter...
#Starting the HTTP server...
#
#🎧  Listening for connection requests on port 4000...
#
#⌛️  Waiting to accept a client connection...
#
#{:ok, #PID<0.219.0>}
# iex(2)> server_pid = Process.whereis(:http_server)
##PID<0.220.0>
#iex(3)> Process.exit(server_pid, :kaboom)
#true
#iex(4)> Process.alive?(server_pid)
#false
#iex(5)> Process.alive?(kick_pid)
#true

# iex(2)> server_pid = Process.whereis(:http_server)
##PID<0.234.0>
#iex(3)> Process.info(kick_pid, :links)
#                    {:links, [#PID<0.234.0>]}
#                      iex(4)> Process.info(server_pid, :links)
#{:links, [#PID<0.233.0>, #Port<0.5>]}
#iex(5)> Process.exit(server_pid, :kaboom)
#true
#iex(6)> Process.alive?(kick_pid)
#false
# when we link processes then there fate is tied together. If one crashes then the other crashes.

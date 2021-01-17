defmodule Tabby.PledgeServer do
  @name :pledge_server

  # Client interface
  def start do
    IO.puts "Starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    send @name, {self(), :create_pledge, name, amount}

    receive do {:response, status} -> status end
  end

  def recent_pledges do
    send @name, {self(), :recent_pledges}

    receive do {:response, pledges} -> pledges end
  end

  def total_pledged do
    send @name, {self(), :total_pledged}

    receive do {:response, total} -> total end
  end

  # Server
  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [ {name, amount} | most_recent_pledges ]
        send sender, {:response, id}
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
        send sender, {:response, total}
        listen_loop(state)
      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Tabby.PledgeServer

pid = PledgeServer.start()

send pid, {:stop, "Hammertime"}

IO.inspect PledgeServer.create_pledge("larry", 10)
IO.inspect PledgeServer.create_pledge("Mark", 20)
IO.inspect PledgeServer.create_pledge("Jon", 30)
IO.inspect PledgeServer.create_pledge("Gary", 40)
IO.inspect PledgeServer.create_pledge("Owen", 50)

IO.inspect PledgeServer.recent_pledges()

IO.inspect PledgeServer.total_pledged()

IO.inspect Process.info(pid, :messages)

defmodule Tabby.PledgeServer do
  @name :pledge_server

  use GenServer, restart: :temporary # Server process behaves like other GenServer processes

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

#  def child_spec(arg) do  # for customization. This function gets automatically injected and called when Supervisor boots up
#    %{
#      id: Tabby.PledgeServer,
#      restart: :temporary,
#      shutdown: 5000,
#      start: {Tabby.PledgeServer, :start_link, [[]]}
#    }
#  end
  # Client interface

  def start_link(_args) do
    IO.puts "Starting the pledge server..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenServer.call @name, :recent_pledges
  end

  def total_pledged do
    GenServer.call @name, :total_pledged
  end

  def clear do
    GenServer.cast @name, :clear
  end

  def set_cache_size(size) do
    GenServer.cast @name, {:set_cache_size, size}
  end

  # Server callbacks

  def init(state) do # NOTE: GenServer.start will block until init is returned
    pledges = fetch_pledges()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{ state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{state | cache_size: size}
    {:noreply, new_state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [ {name, amount} | most_recent_pledges ]
    new_state = %{ state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_info(message, state) do # handles unexpected messages and more...
    IO.puts "Can't touch this! #{inspect message}"
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_pledges do # pretend they are coming from an external service
    [ {"Wilma", 55}, {"Fred", 65} ]
  end
end

#alias Tabby.PledgeServer
#
#{:ok, pid} = PledgeServer.start()
#
#send pid, {:stop, "Hammertime"}
#
#PledgeServer.set_cache_size(4)
#IO.inspect PledgeServer.create_pledge("larry", 10)
#PledgeServer.clear()
#IO.inspect PledgeServer.create_pledge("Mark", 20)
#IO.inspect PledgeServer.create_pledge("Jon", 30)
#IO.inspect PledgeServer.create_pledge("Gary", 40)
#IO.inspect PledgeServer.create_pledge("Owen", 50)
#
#IO.inspect PledgeServer.recent_pledges()
#
#IO.inspect PledgeServer.total_pledged()
#
#IO.inspect Process.info(pid, :messages)

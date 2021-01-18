# This is how GenServer works under the hood.
# In OTP, a design pattern like this is a "behavior".
# GenServer is a "behavior"(aka design pattern) for writing stateful server processes

defmodule Tabby.GenericServer do
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do # encapsulates synchronous requests
    send pid, {:call, self(), message}

    receive do {:response, response} -> response end
  end

  def cast(pid, message) do # casting message to the wind. Async request not waiting for a response
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state) # doesnt need to return a response to the client
        listen_loop(new_state, callback_module)
      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end

defmodule Tabby.PledgeServerHandRolled do
  @name :pledge_server_hand_rolled

  alias Tabby.GenericServer

  def start do
    IO.puts "Starting the pledge server..."
    GenericServer.start(__MODULE__, [], @name)
  end

  # Client interface
  def create_pledge(name, amount) do
    GenericServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenericServer.call @name, :recent_pledges
  end

  def total_pledged do
    GenericServer.call @name, :total_pledged
  end

  def clear do
    GenericServer.cast @name, :clear
  end

  # Server callbacks

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [ {name, amount} | most_recent_pledges ]
    {id, new_state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    {total, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

#alias Tabby.PledgeServerHandRolled
#
#pid = PledgeServerHandRolled.start()
#
#send pid, {:stop, "Hammertime"}
#
#IO.inspect PledgeServerHandRolled.create_pledge("larry", 10)
#IO.inspect PledgeServerHandRolled.create_pledge("Mark", 20)
#IO.inspect PledgeServerHandRolled.create_pledge("Jon", 30)
#IO.inspect PledgeServerHandRolled.create_pledge("Gary", 40)
#PledgeServerHandRolled.clear()
#IO.inspect PledgeServerHandRolled.create_pledge("Owen", 50)
#
#IO.inspect PledgeServerHandRolled.recent_pledges()
#
#IO.inspect PledgeServerHandRolled.total_pledged()
#
#IO.inspect Process.info(pid, :messages)

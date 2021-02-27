defmodule Tabby.CountServer do
    use GenServer

    # Simple example of hot upgrades.
    def start_link(_args) do
      GenServer.start_link(__MODULE__, 1)
    end

    def init(state) do
      send(self(), {:increment, 1})
      {:ok, state}
    end

    def handle_info(:increment, n) do
      handle_info({:increment, 2}, n)
    end

    # Update it to increment by a different number and then run r Tabby.CountServer
    def handle_info({:increment, value}, state) do
      new_state = state + value
      IO.puts("- #{inspect(self())}: #{new_state}")
      Process.send_after(self(), {:increment, 2}, 1000)
      {:noreply, new_state}
    end

    def code_change(_old_version, state, _extra) when rem(state , 2) == 1 do
        {:ok, state - 1}
    end

    def code_change(_old_version, state, _extra) do
        {:ok, state}
    end
end

# iex -S mix
# {:ok, pid} = Tabby.CountServer.start_link()
# update the handle_info callback
# :sys.suspend(pid)
# r Tabby.CountServer
# :sys.change_code(pid, Tabby.CountServer, nil, [])
# :sys.resume(pid)

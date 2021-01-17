defmodule PledgeServerTest do
  use ExUnit.Case

  alias Tabby.PledgeServer

  test "caches the 3 most recent pledges and totals their amounts" do
    PledgeServer.start()
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("Mark", 20)
    PledgeServer.create_pledge("Jon", 30)
    PledgeServer.create_pledge("Gary", 40)
    PledgeServer.create_pledge("Owen", 50)

    most_recent_pledges = [{"Owen", 50}, {"Gary", 40}, {"Jon", 30} ]
    assert PledgeServer.recent_pledges() == most_recent_pledges
    assert PledgeServer.total_pledged() == 120
  end
end

defmodule Tabby.Wildthings do
  alias Tabby.Bear

  def list_bears() do
    [
      %Bear{id: 1, name: "Teddy", type: "Brown", hibernating: true},
      %Bear{id: 2, name: "Smokey", type: "Black"},
      %Bear{id: 3, name: "Paddington", type: "Brown"},
      %Bear{id: 4, name: "Snow", type: "Polar", hibernating: true},
      %Bear{id: 5, name: "Brutus", type: "Grizzly"},
    ]
  end

  def get_bear(id) when is_integer(id) do # guard clause
    Enum.find(list_bears(), fn(b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do # guard clause
    id |> String.to_integer |> get_bear
  end
end

defmodule Tabby.Api.BearController do
  def index(conv) do
    json =
      Tabby.Wildthings.list_bears()
      |> Poison.encode!

    %{ conv | status: 200, resp_content_type: "application/json", resp_body: json}
  end
end

defmodule Tabby.Handler do
  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("../../pages", __DIR__)

  alias Tabby.Plugins
  alias Tabby.Parser
  alias Tabby.Conv
  alias Tabby.BearController
  alias Tabby.PledgeController

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> Parser.parse
    |> Plugins.rewrite_path
#    |> Plugins.log
    |> route
#    |> Plugins.emojify TODO: write tests to accomodate for this plug
    |> Plugins.track
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    sensor_data = Tabby.SensorServer.get_sensor_data()

    %{ conv | status: 200, resp_body: inspect sensor_data }
  end

  def route(%Conv{ method: "GET", path: "/kaboom" } = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Awake!" }
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Tabby.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  # name=NAME&type=TYPE
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.destroy(conv, params)
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!"}
  end

  # case solution
#  def route(%{method: "GET", path: "/about"} = conv) do
#    file =
#      Path.expand("../../pages", __DIR__)
#    |> Path.join("about.html")
#
#    case File.read("lib/pages/about.html") do
#      {:ok, content} ->
#        %{ conv | status: 200, resp_body: content}
#
#      {:error, :enoent} ->
#        %{ conv | status: 404, resp_body: "File not found"}
#
#      {:error, reason} ->
#        %{ conv | status: 500, resp_body: "File error #{reason}"}
#    end
#  end

  # multi-clause solution
  def handle_file({:ok, content}, conv) do
    %{ conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found"}
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | status: 500, resp_body: "File error #{reason}"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end

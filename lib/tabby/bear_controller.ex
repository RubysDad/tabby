defmodule Tabby.BearController do
  alias Tabby.Wildthings
  alias Tabby.Bear

  @template_path Path.expand("../../templates", __DIR__)

  defp render(conv, template, bindings \\ []) do #  \\ default parameter
    content =
      @template_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{ conv | status: 200, resp_body: content }
  end

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)
    #      |> Enum.filter(&Bear.is_grizzly/1)

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type} = _params) do
    %{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def destroy(conv, %{"id" => id}) do
    Wildthings.get_bear(id)
    %{ conv | status: 204 }
  end
end


defmodule Tabby.Parser do
  alias Tabby.Conv
  def parse(request) do
    [top, params_string] = split(request, "\r\n\r\n")
    [request_line | header_lines] = split(top, "\r\n")
    [method, path, _] = split(request_line, " ")
    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

  def parse_headers([head | tail], headers) do
    [key, value] = split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}

  defp split(list, separator) do
    String.split(list, separator)
  end
end

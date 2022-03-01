defmodule AthenaWeb.Schema.Scalar.URI do
  @moduledoc """
  URI Type for API
  """

  use Absinthe.Schema.Notation

  alias Absinthe.Blueprint.Input

  @desc """
  URI Generic Type

  Example: `https://example.com`
  """
  scalar :uri do
    parse(&_parse/1)
    serialize(&_serialize/1)
  end

  @spec _serialize(uri :: URI.t()) :: String.t()
  defp _serialize(%URI{} = uri), do: URI.to_string(uri)
  defp _serialize(uri) when is_binary(uri), do: uri |> URI.parse() |> _serialize

  @spec _parse(input :: any) :: {:ok, URI.t()} | :error
  defp _parse(%Input.String{value: value}) do
    case URI.parse(value) do
      %URI{scheme: nil} -> :error
      %URI{scheme: scheme, host: nil} when scheme in ["http", "https"] -> :error
      uri -> {:ok, uri}
    end
  end

  defp _parse(_other), do: :error
end

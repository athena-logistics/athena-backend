defmodule AthenaWeb.Schema.Scalar.Map do
  @moduledoc """
  Map Type for API
  """

  use Absinthe.Schema.Notation

  @desc """
  Map Generic Type

  Example: `{"foo": "bar"}`
  """
  scalar :map, open_ended: true do
    parse &_parse/1
    serialize &_serialize/1
  end

  @spec _serialize(map :: map()) :: map()
  defp _serialize(%{} = map), do: map

  @spec _parse(input :: any) :: {:ok, map()} | :error
  defp _parse(%{} = value), do: {:ok, value}
  defp _parse(_other), do: :error
end

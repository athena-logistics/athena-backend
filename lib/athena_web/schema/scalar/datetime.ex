defmodule AthenaWeb.Schema.Scalar.Datetime do
  @moduledoc """
  DateTime Type for API
  """

  use Absinthe.Schema.Notation

  alias Absinthe.Blueprint.Input

  @desc """
  Date Generic Type

  Example: `2021-05-04 11:44:10.858225Z`
  """
  scalar :datetime do
    parse &_parse/1
    serialize &_serialize/1
  end

  @spec _serialize(datetime :: DateTime.t()) :: String.t()
  defp _serialize(datetime), do: DateTime.to_iso8601(datetime)

  @spec _parse(input :: any) :: {:ok, DateTime.t()} | :error
  defp _parse(%Input.String{value: value}) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} ->
        {:ok, datetime}

      {:error, _} ->
        :error
    end
  end

  defp _parse(_other), do: :error
end

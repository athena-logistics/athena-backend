defmodule AthenaWeb.Schema.Scalar.Date do
  @moduledoc """
  Date Type for API
  """

  use Absinthe.Schema.Notation

  alias Absinthe.Blueprint.Input

  @desc """
  Date Generic Type

  Example: `2019-05-07`
  """
  scalar :date do
    parse &_parse/1
    serialize &_serialize/1
  end

  @spec _serialize(date :: Date.t()) :: String.t()
  defp _serialize(date), do: Date.to_iso8601(date)

  @spec _parse(input :: any) :: {:ok, Date.t()} | :error
  defp _parse(%Input.String{value: value}) do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        {:ok, date}

      {:error, _reason} ->
        :error
    end
  end

  defp _parse(_other), do: :error
end

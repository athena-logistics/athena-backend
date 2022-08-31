defmodule AthenaWeb.Schema.Location.Total.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  @spec query_filter(
          query :: Ecto.Queryable.t(),
          parent :: term(),
          args :: map(),
          resolution :: Absinthe.Resolution.t()
        ) :: Ecto.Queryable.t()
  def query_filter(query, _parent, %{filters: filters} = _args, _resolution) do
    Enum.reduce(filters, query, &query_filter/2)
  end

  defp query_filter({:include_zero_deltas, false}, query),
    do: from(total in query, where: total.delta != 0)

  defp query_filter({:include_zero_deltas, _other}, query), do: query

  defp query_filter({:location_id_equals, nil}, query), do: query

  defp query_filter({:location_id_equals, id}, query),
    do: from(total in query, where: total.location_id == ^id)

  defp query_filter({:date_from, nil}, query), do: query

  defp query_filter({:date_from, date_from}, query),
    do: from(total in query, where: total.date >= ^date_from)

  defp query_filter({:date_to, nil}, query), do: query

  defp query_filter({:date_to, date_to}, query),
    do: from(total in query, where: total.date <= ^date_to)
end

defmodule AthenaWeb.Schema.Item.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  import Ecto.Query, only: [from: 2]

  alias Athena.Inventory
  alias Athena.Inventory.Item

  @spec stock(parent :: Item.t(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def stock(%Item{id: id}, args, _resolution) do
    connection_from_query(
      from([event, item: item] in Inventory.stock_query(), where: item.id == ^id),
      args,
      &Repo.all/1,
      nil
    )
  end

  @spec location_totals_filter(
          query :: Ecto.Queryable.t(),
          parent :: Item.t(),
          args :: map(),
          resolution :: Absinthe.Resolution.t()
        ) :: Ecto.Queryable.t()
  def location_totals_filter(query, _parent, %{filters: filters} = _args, _resolution) do
    Enum.reduce(filters, query, &location_totals_filter/2)
  end

  defp location_totals_filter({:location_id_equals, id}, query),
    do: from(total in query, where: total.location_id == ^id)
end

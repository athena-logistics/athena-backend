defmodule AthenaWeb.Schema.StockEntry.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  alias Athena.Inventory.StockEntry

  @spec status(
          parent :: StockEntry.t(),
          args :: map,
          resolution :: Absinthe.Resolution.t()
        ) :: AthenaWeb.resolver_result()
  def status(parent, _args, _resolution) do
    batch(
      {__MODULE__, :preload_status_entries},
      parent,
      &{:ok, StockEntry.status(&1[{parent.location_id, parent.item_id}])}
    )
  end

  def preload_status_entries([], entries),
    do: entries |> Repo.preload(item: []) |> Map.new(&{{&1.location_id, &1.item_id}, &1})
end

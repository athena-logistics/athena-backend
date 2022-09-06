defmodule AthenaWeb.Schema.StockExpectation.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  alias Athena.Inventory

  @spec delete_stock_expectation(
          parent :: term(),
          args :: map(),
          resolution :: Absinthe.Resolution.t()
        ) ::
          AthenaWeb.resolver_result()
  def delete_stock_expectation(_parent, %{id: id} = _args, _resolution) do
    id
    |> Inventory.get_stock_expectation!()
    |> Inventory.delete_stock_expectation()
    |> changeset_result()
  end

  @spec set_stock_expectation(
          parent :: term(),
          args :: map(),
          resolution :: Absinthe.Resolution.t()
        ) ::
          AthenaWeb.resolver_result()
  def set_stock_expectation(
        _parent,
        %{item_id: item_id, location_id: location_id} = args,
        _resolution
      ) do
    item = Inventory.get_item!(item_id)
    location = Inventory.get_location!(location_id)

    item
    |> Inventory.upsert_stock_expectation(location, args)
    |> changeset_result()
  end
end

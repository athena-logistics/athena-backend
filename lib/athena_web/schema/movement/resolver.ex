defmodule AthenaWeb.Schema.Movement.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  alias Athena.Inventory

  @spec supply(parent :: any(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def supply(
        _parent,
        %{item_id: item_id, amount: amount, location_id: location_id},
        _resolution
      ) do
    item_id
    |> Inventory.get_item!()
    |> Inventory.create_movement(%{amount: amount, destination_location_id: location_id})
    |> changeset_result()
  end

  @spec consume(parent :: any(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def consume(
        _parent,
        %{item_id: item_id, amount: amount, location_id: location_id},
        _resolution
      ) do
    item_id
    |> Inventory.get_item!()
    |> Inventory.create_movement(%{amount: amount, source_location_id: location_id})
    |> changeset_result()
  end

  @spec relocate(parent :: any(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def relocate(
        _parent,
        %{item_id: item_id} = args,
        _resolution
      ) do
    item_id
    |> Inventory.get_item!()
    |> Inventory.create_movement(args)
    |> changeset_result()
  end
end

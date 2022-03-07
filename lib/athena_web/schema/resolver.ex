defmodule AthenaWeb.Schema.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  alias Athena.Inventory

  @spec node(id :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def node(%{type: :event, id: id}, _resolution), do: {:ok, Inventory.get_event!(id)}
  def node(%{type: :location, id: id}, _resolution), do: {:ok, Inventory.get_location!(id)}
  def node(%{type: :item_group, id: id}, _resolution), do: {:ok, Inventory.get_item_group!(id)}
  def node(%{type: :item, id: id}, _resolution), do: {:ok, Inventory.get_item!(id)}

  def node(%{type: movement_type, id: id}, _resolution)
      when movement_type in [:supply, :consumption, :relocation],
      do: {:ok, Inventory.get_movement!(id)}
end

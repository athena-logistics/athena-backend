defmodule AthenaWeb.Schema.Location.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  import Ecto.Query, only: [from: 2]

  alias Athena.Inventory
  alias Athena.Inventory.Location

  @spec location(parent :: term(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def location(_parent, %{id: id}, _resolution), do: {:ok, Inventory.get_location!(id)}

  @spec stock(parent :: Location.t(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def stock(%Location{id: id}, args, _resolution) do
    connection_from_query(
      from([event, location: location] in Inventory.stock_query(), where: location.id == ^id),
      args,
      &Repo.all/1,
      nil
    )
  end

  @spec items(parent :: Location.t(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def items(%Location{} = location, args, _resolution) do
    location
    |> Inventory.list_relevant_items_query()
    |> connection_from_query(args, &Repo.all/1, nil)
  end

  @spec item_groups(parent :: Location.t(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def item_groups(%Location{} = location, args, _resolution) do
    location
    |> Inventory.list_relevant_item_groups_query()
    |> connection_from_query(args, &Repo.all/1, nil)
  end
end

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
end

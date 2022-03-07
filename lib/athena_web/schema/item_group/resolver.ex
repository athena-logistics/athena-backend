defmodule AthenaWeb.Schema.ItemGroup.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  import Ecto.Query, only: [from: 2]

  alias Athena.Inventory
  alias Athena.Inventory.ItemGroup

  @spec stock(parent :: ItemGroup.t(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def stock(%ItemGroup{id: id}, args, _resolution) do
    connection_from_query(
      from([event, item_group: item_group] in Inventory.stock_query(), where: item_group.id == ^id),
      args,
      &Repo.all/1,
      nil
    )
  end
end

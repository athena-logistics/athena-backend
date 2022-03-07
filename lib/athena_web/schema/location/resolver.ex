defmodule AthenaWeb.Schema.Location.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  import Ecto.Query, only: [from: 2]

  alias Athena.Inventory
  alias Athena.Inventory.Location

  @spec location(parent :: term(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def location(_parent, %{id: id}, _resolution), do: {:ok, Inventory.get_location!(id)}

  @spec stock(parent :: Location.t(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def stock(%Location{id: id}, args, _resolution) do
    connection_from_query(
      from([event, location: location] in Inventory.stock_query(), where: location.id == ^id),
      args,
      &Repo.all/1,
      nil
    )
  end
end

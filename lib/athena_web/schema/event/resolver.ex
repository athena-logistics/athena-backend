defmodule AthenaWeb.Schema.Event.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  alias Athena.Inventory
  alias Athena.Inventory.Event

  @spec event(parent :: term(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def event(_parent, %{id: id}, _resolution), do: {:ok, Inventory.get_event!(id)}

  @spec stock(parent :: Event.t(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def stock(%Event{id: id}, args, _resolution) do
    connection_from_query(
      from(event in Inventory.stock_query(), where: event.id == ^id),
      args,
      &Repo.all/1,
      nil
    )
  end
end

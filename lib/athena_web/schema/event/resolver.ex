defmodule AthenaWeb.Schema.Event.Resolver do
  @moduledoc false

  alias Athena.Inventory

  @spec event(parent :: term(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def event(_parent, %{id: id}, _resolution), do: {:ok, Inventory.get_event!(id)}
end

defmodule AthenaWeb.Schema.Resolver do
  @moduledoc false

  alias Athena.Inventory

  @spec node(id :: map(), resolution :: Absinthe.Resolution.t()) ::
          {:ok, term()} | {:error, term()}
  def node(%{type: :event, id: id}, _resolution), do: {:ok, Inventory.get_event!(id)}
end

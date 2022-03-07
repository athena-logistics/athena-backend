defmodule AthenaWeb.Schema.StockEntry.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  alias Athena.Inventory.Movement

  @spec status(
          parent :: Movement.stock_entry(),
          args :: map,
          resolution :: Absinthe.Resolution.t()
        ) :: {:ok, term()} | {:error, term()}
  def status(parent, _args, _resolution), do: {:ok, Movement.stock_status(parent)}
end

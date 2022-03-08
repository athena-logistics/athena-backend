defmodule AthenaWeb.Schema.Movement.SubscriptionConfig do
  @moduledoc false

  use AthenaWeb, :subscription_config

  @spec created(args :: map, resolution :: Absinthe.Resolution.t()) ::
          {:ok, Keyword.t()} | {:error, term}
  def created(args, _resolution),
    do: {:ok, topics([{"event", args[:event_id]}, {"location", args[:location_id]}], ["*"])}
end

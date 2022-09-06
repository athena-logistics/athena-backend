defmodule AthenaWeb.Schema do
  @moduledoc """
  Root GraphQL Schema
  """

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias AthenaWeb.Middleware.Safe
  alias AthenaWeb.Schema.Dataloader, as: RepoDataLoader
  alias AthenaWeb.Schema.Resolver

  @impl Absinthe.Schema
  @spec context(context :: map) :: map
  def context(context),
    do:
      Map.put(
        context,
        :loader,
        Dataloader.add_source(Dataloader.new(), RepoDataLoader, RepoDataLoader.data())
      )

  @impl Absinthe.Schema
  @spec plugins :: [atom]
  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  @impl Absinthe.Schema
  @spec middleware(
          [Absinthe.Middleware.spec(), ...],
          Absinthe.Type.Field.t(),
          Absinthe.Type.Object.t()
        ) :: [Absinthe.Middleware.spec(), ...]
  def middleware(middleware, _field, _object),
    do: Enum.map(middleware, &Safe.add_error_handling/1)

  import_types Absinthe.Plug.Types
  import_types AbsintheErrorPayload.ValidationMessageTypes
  import_types AthenaWeb.Schema.Event
  import_types AthenaWeb.Schema.Event.Total
  import_types AthenaWeb.Schema.Item
  import_types AthenaWeb.Schema.ItemGroup
  import_types AthenaWeb.Schema.Location
  import_types AthenaWeb.Schema.Location.Total
  import_types AthenaWeb.Schema.Movement
  import_types AthenaWeb.Schema.StockEntry
  import_types AthenaWeb.Schema.StockExpectation
  import_types AthenaWeb.Schema.Scalar.Date
  import_types AthenaWeb.Schema.Scalar.Datetime
  import_types AthenaWeb.Schema.Scalar.Map
  import_types AthenaWeb.Schema.Scalar.Ok
  import_types AthenaWeb.Schema.Scalar.URI

  node interface do
  end

  interface :resource do
    field :id, non_null(:id)
    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)

    interface :node
  end

  query do
    node field do
      resolve(&Resolver.node/2)
    end

    import_fields :event_queries
    import_fields :location_queries
  end

  mutation do
    import_fields :movement_mutations
    import_fields :stock_expectation_mutations
  end

  subscription do
    import_fields :location_subscriptions
  end
end

defmodule AthenaWeb.Schema.SubscriptionNotifier do
  @moduledoc """
  Relay Messages from PubSub to the Absinthe subscription system
  """

  use GenServer

  alias Absinthe.Relay.Node
  alias Absinthe.Subscription
  alias Athena.Inventory.Movement
  alias AthenaWeb.Endpoint
  alias AthenaWeb.Schema

  @server __MODULE__

  @graphql_resource_override %{
    supply: :movement,
    consumption: :movement,
    relocation: :movement
  }

  @graphql_action_override %{}

  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts),
    do: GenServer.start_link(__MODULE__, nil, name: Keyword.get(opts, :name, @server))

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Athena.PubSub, "movement")

    {:ok, nil}
  end

  @impl true
  def handle_info({verb, resource, extra}, state) do
    graphql_name =
      Schema
      |> Absinthe.Schema.implementors(:node)
      |> Enum.filter(&match?(%Absinthe.Type.Object{}, &1))
      |> Enum.find(fn type ->
        Absinthe.Type.function(type, :is_type_of).(resource)
      end)
      |> Map.fetch!(:identifier)

    case graphql_action(graphql_name, verb) do
      :error ->
        {:noreply, state}

      {:ok, graphql_action} ->
        [{_pk_field, pk}] = resource |> Ecto.primary_key() |> Enum.to_list()

        global_id = Node.to_global_id(graphql_name, pk, Schema)

        :ok =
          Subscription.publish(
            Endpoint,
            case verb do
              :created -> resource
              :updated -> resource
              :matched -> resource
              :deleted -> global_id
            end,
            Enum.map(
              ["*", global_id | additional_topics(resource, verb, extra)],
              &{graphql_action, &1}
            )
          )

        {:noreply, state}
    end
  end

  defp additional_topics(resource, verb, extra)

  defp additional_topics(
         %Movement{
           source_location_id: source_location_id,
           destination_location_id: destination_location_id,
           item_id: item_id
         },
         _verb,
         %{event_id: event_id}
       ),
       do:
         List.flatten([
           case source_location_id do
             nil -> []
             location_id -> "location:" <> Node.to_global_id(:location, location_id, Schema)
           end,
           case destination_location_id do
             nil -> []
             location_id -> "location:" <> Node.to_global_id(:location, location_id, Schema)
           end,
           [
             "item:" <> Node.to_global_id(:item, item_id, Schema),
             "event:" <> Node.to_global_id(:event, event_id, Schema)
           ]
         ])

  defp additional_topics(_resource, _verb, _extra), do: []

  defp graphql_action(graphql_resource, verb) do
    graphql_action =
      String.to_existing_atom(
        "#{Map.get(@graphql_resource_override, graphql_resource, graphql_resource)}_#{verb}"
      )

    graphql_action =
      if Map.has_key?(@graphql_action_override, graphql_action) do
        @graphql_action_override[graphql_action]
      else
        graphql_action
      end

    {:ok, graphql_action}
  rescue
    ArgumentError -> :error
  end
end

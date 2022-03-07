defmodule AthenaWeb.Schema.Query.Node.MovementTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      __typename
      ... on Movement {
        event {
          id
        }
        itemGroup {
          id
        }
        item {
          id
        }
        insertedAt
        updatedAt

        ... on Supply {
          location {
            id
          }
        }
        ... on Consumption {
          location {
            id
          }
        }
        ... on Relocation {
          sourceLocation {
            id
          }
          destinationLocation {
            id
          }
        }
      }
    }
  }
  """

  test "gets supply by id" do
    event = event()
    item_group = item_group(event)
    item = item(item_group, name: "Lager")
    location = location(event, name: "Gallusplatz")

    supply =
      movement(item, amount: 1, source_location_id: nil, destination_location_id: location.id)

    event_node_id = global_id!(:event, item_group.event_id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)
    supply_node_id = global_id!(:supply, supply.id)
    location_node_id = global_id!(:location, location.id)

    assert result = run!(@query, variables: %{"id" => supply_node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^supply_node_id,
                 "insertedAt" => _inserted_at,
                 "updatedAt" => _updated_at,
                 "event" => %{"id" => ^event_node_id},
                 "itemGroup" => %{"id" => ^item_group_node_id},
                 "item" => %{"id" => ^item_node_id},
                 "location" => %{"id" => ^location_node_id}
               }
             }
           } = result
  end

  test "gets consumption by id" do
    event = event()
    item_group = item_group(event)
    item = item(item_group, name: "Lager")
    location = location(event, name: "Gallusplatz")

    consumption =
      movement(item, amount: 1, source_location_id: location.id, destination_location_id: nil)

    event_node_id = global_id!(:event, item_group.event_id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)
    consumption_node_id = global_id!(:consumption, consumption.id)
    location_node_id = global_id!(:location, location.id)

    assert result = run!(@query, variables: %{"id" => consumption_node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^consumption_node_id,
                 "insertedAt" => _inserted_at,
                 "updatedAt" => _updated_at,
                 "event" => %{"id" => ^event_node_id},
                 "itemGroup" => %{"id" => ^item_group_node_id},
                 "item" => %{"id" => ^item_node_id},
                 "location" => %{"id" => ^location_node_id}
               }
             }
           } = result
  end

  test "gets relocation by id" do
    event = event()
    item_group = item_group(event)
    item = item(item_group, name: "Lager")
    location_central = location(event, name: "Gallusplatz")
    location_sattelite = location(event, name: "Vadian")

    relocation =
      movement(item,
        amount: 1,
        source_location_id: location_central.id,
        destination_location_id: location_sattelite.id
      )

    event_node_id = global_id!(:event, item_group.event_id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)
    relocation_node_id = global_id!(:relocation, relocation.id)
    location_central_node_id = global_id!(:location, location_central.id)
    location_sattelite_node_id = global_id!(:location, location_sattelite.id)

    assert result = run!(@query, variables: %{"id" => relocation_node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^relocation_node_id,
                 "insertedAt" => _inserted_at,
                 "updatedAt" => _updated_at,
                 "event" => %{"id" => ^event_node_id},
                 "itemGroup" => %{"id" => ^item_group_node_id},
                 "item" => %{"id" => ^item_node_id},
                 "sourceLocation" => %{"id" => ^location_central_node_id},
                 "destinationLocation" => %{"id" => ^location_sattelite_node_id}
               }
             }
           } = result
  end
end

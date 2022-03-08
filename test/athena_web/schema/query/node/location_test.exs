defmodule AthenaWeb.Schema.Query.Node.LocationTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      ... on Location {
        name
        event {
          id
        }
        movementsIn(first: 10) {
          edges {
            node {
              id
            }
          }
        }
        movementsOut(first: 10) {
          edges {
            node {
              id
            }
          }
        }
        itemGroups(first: 10) {
          edges {
            node {
              id
            }
          }
        }
        items(first: 10) {
          edges {
            node {
              id
            }
          }
        }
        stock(first: 10) {
          edges {
            node {
              consumption
              movementIn
              movementOut
              stock
              supply
              status
              item {
                id
              }
              itemGroup {
                id
              }
              location {
                id
              }
            }
          }
        }
        insertedAt
        updatedAt
      }
    }
  }
  """

  test "gets location by id" do
    event = event()
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    unrelated_item_group = item_group(event, name: "Cookies")
    item = item(item_group, name: "Lager")
    _unrelated_item = item(unrelated_item_group, name: "Chocolate Chip")

    supply =
      movement(item, amount: 1, source_location_id: nil, destination_location_id: location.id)

    consumption =
      movement(item, amount: 1, source_location_id: location.id, destination_location_id: nil)

    event_node_id = global_id!(:event, event.id)
    location_node_id = global_id!(:location, location.id)
    supply_node_id = global_id!(:supply, supply.id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)
    consumption_node_id = global_id!(:consumption, consumption.id)

    assert result = run!(@query, variables: %{"id" => location_node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^location_node_id,
                 "name" => "Gallusplatz",
                 "insertedAt" => _inserted_at,
                 "updatedAt" => _updated_at,
                 "event" => %{"id" => ^event_node_id},
                 "movementsIn" => %{
                   "edges" => [%{"node" => %{"id" => ^supply_node_id}}]
                 },
                 "movementsOut" => %{
                   "edges" => [%{"node" => %{"id" => ^consumption_node_id}}]
                 },
                 "itemGroups" => %{
                   "edges" => [%{"node" => %{"id" => ^item_group_node_id}}]
                 },
                 "items" => %{
                   "edges" => [%{"node" => %{"id" => ^item_node_id}}]
                 },
                 "stock" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "consumption" => 1,
                         "movementIn" => 0,
                         "movementOut" => 0,
                         "stock" => 0,
                         "supply" => 1,
                         "item" => %{"id" => ^item_node_id},
                         "itemGroup" => %{"id" => ^item_group_node_id},
                         "location" => %{"id" => ^location_node_id},
                         "status" => "IMPORTANT"
                       }
                     }
                   ]
                 }
               }
             }
           } = result
  end
end

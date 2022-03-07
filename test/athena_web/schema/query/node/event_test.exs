defmodule AthenaWeb.Schema.Query.Node.EventTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      ... on Event {
        name
        insertedAt
        updatedAt
        locations(first: 10) {
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
        movements(first: 10) {
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
      }
    }
  }
  """

  test "gets event by id" do
    event = event(name: "Awesome Gathering")
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")
    movement = movement(item, amount: 1, destination_location_id: location.id)

    event_node_id = global_id!(:event, event.id)
    location_node_id = global_id!(:location, location.id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)
    movement_node_id = global_id!(:supply, movement.id)

    assert result = run!(@query, variables: %{"id" => event_node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^event_node_id,
                 "name" => "Awesome Gathering",
                 "insertedAt" => _inserted_at,
                 "updatedAt" => _updated_at,
                 "locations" => %{
                   "edges" => [%{"node" => %{"id" => ^location_node_id}}]
                 },
                 "itemGroups" => %{
                   "edges" => [%{"node" => %{"id" => ^item_group_node_id}}]
                 },
                 "items" => %{
                   "edges" => [%{"node" => %{"id" => ^item_node_id}}]
                 },
                 "movements" => %{
                   "edges" => [%{"node" => %{"id" => ^movement_node_id}}]
                 },
                 "stock" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "consumption" => 0,
                         "movementIn" => 0,
                         "movementOut" => 0,
                         "stock" => 1,
                         "supply" => 1,
                         "item" => %{"id" => ^item_node_id},
                         "itemGroup" => %{"id" => ^item_group_node_id},
                         "location" => %{"id" => ^location_node_id}
                       }
                     }
                   ]
                 }
               }
             }
           } = result
  end
end

defmodule AthenaWeb.Schema.Query.Node.ItemGroupTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      ... on ItemGroup {
        name
        event {
          id
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
        insertedAt
        updatedAt
      }
    }
  }
  """

  test "gets item group by id" do
    event = event()
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")
    location = location(event, name: "Gallusplatz")
    movement = movement(item, amount: 1, destination_location_id: location.id)

    event_node_id = global_id!(:event, item_group.event_id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)
    location_node_id = global_id!(:location, location.id)
    movement_node_id = global_id!(:supply, movement.id)

    assert result = run!(@query, variables: %{"id" => item_group_node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^item_group_node_id,
                 "name" => "Bier",
                 "insertedAt" => _inserted_at,
                 "updatedAt" => _updated_at,
                 "event" => %{"id" => ^event_node_id},
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

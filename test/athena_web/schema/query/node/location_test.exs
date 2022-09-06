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
                id name
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
        stockExpectations(first: 10) {
          edges {
            node {
              id
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
    item_lager = item(item_group, name: "Lager")
    item_kloesti = item(item_group, name: "Klösti")
    _unrelated_item = item(unrelated_item_group, name: "Chocolate Chip")

    stock_expectation =
      stock_expectation(item_lager, location, %{important_threshold: 3, warning_threshold: 5})

    supply_lager =
      movement(item_lager,
        amount: 1,
        source_location_id: nil,
        destination_location_id: location.id
      )

    supply_kloesti =
      movement(item_kloesti,
        amount: 1,
        source_location_id: nil,
        destination_location_id: location.id
      )

    consumption =
      movement(item_lager,
        amount: 1,
        source_location_id: location.id,
        destination_location_id: nil
      )

    event_node_id = global_id!(:event, event.id)
    location_node_id = global_id!(:location, location.id)
    supply_lager_node_id = global_id!(:supply, supply_lager.id)
    supply_kloesti_node_id = global_id!(:supply, supply_kloesti.id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_lager_node_id = global_id!(:item, item_lager.id)
    item_kloesti_node_id = global_id!(:item, item_kloesti.id)
    consumption_node_id = global_id!(:consumption, consumption.id)
    stock_expectation_node_id = global_id!(:stock_expectation, stock_expectation.id)

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
                   "edges" => [
                     %{"node" => %{"id" => ^supply_lager_node_id}},
                     %{"node" => %{"id" => ^supply_kloesti_node_id}}
                   ]
                 },
                 "movementsOut" => %{
                   "edges" => [%{"node" => %{"id" => ^consumption_node_id}}]
                 },
                 "itemGroups" => %{
                   "edges" => [%{"node" => %{"id" => ^item_group_node_id}}]
                 },
                 "items" => %{
                   "edges" => [
                     %{"node" => %{"id" => ^item_kloesti_node_id}},
                     %{"node" => %{"id" => ^item_lager_node_id}}
                   ]
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
                         "item" => %{"id" => ^item_kloesti_node_id},
                         "itemGroup" => %{"id" => ^item_group_node_id},
                         "location" => %{"id" => ^location_node_id},
                         "status" => "NORMAL"
                       }
                     },
                     %{
                       "node" => %{
                         "consumption" => 1,
                         "movementIn" => 0,
                         "movementOut" => 0,
                         "stock" => 0,
                         "supply" => 1,
                         "item" => %{"id" => ^item_lager_node_id},
                         "itemGroup" => %{"id" => ^item_group_node_id},
                         "location" => %{"id" => ^location_node_id},
                         "status" => "IMPORTANT"
                       }
                     }
                   ]
                 },
                 "stockExpectations" => %{
                   "edges" => [%{"node" => %{"id" => ^stock_expectation_node_id}}]
                 }
               }
             }
           } = result
  end
end

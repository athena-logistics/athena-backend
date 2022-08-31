defmodule AthenaWeb.Schema.Query.Node.Item.LocationTotalsTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!, $filters: LocationTotalFilter) {
    node(id: $id) {
      id
      ... on Item {
        locationTotals(first: 10, filters: $filters) {
          edges {
            node {
              amount
              item {
                id
              }
              itemGroup {
                id
              }
              event {
                id
              }
              location {
                id
              }
              date
              delta
            }
          }
        }
      }
    }
  }
  """

  test "gets totals for all locations" do
    event = event()
    item_group = item_group(event)
    item = item(item_group, name: "Lager", inverse: false, unit: "cask")
    location = location(event, name: "Gallusplatz")
    movement(item, amount: 1, destination_location_id: location.id)

    event_node_id = global_id!(:event, event.id)
    location_node_id = global_id!(:location, location.id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)

    assert result = run!(@query, variables: %{"id" => item_node_id})

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{
                 "locationTotals" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "amount" => 1,
                         "date" => "20" <> _rest_date,
                         "item" => %{"id" => ^item_node_id},
                         "itemGroup" => %{"id" => ^item_group_node_id},
                         "location" => %{"id" => ^location_node_id},
                         "event" => %{"id" => ^event_node_id}
                       }
                     }
                   ]
                 }
               }
             }
           } = result
  end

  test "gets totals for a specific location" do
    event = event()
    item_group = item_group(event)
    item = item(item_group, name: "Lager", inverse: false, unit: "cask")

    location_a = location(event, name: "Gallusplatz")
    location_b = location(event, name: "Vadian")

    movement(item, amount: 1, destination_location_id: location_a.id)
    movement(item, amount: 2, destination_location_id: location_b.id)

    location_a_node_id = global_id!(:location, location_a.id)
    item_node_id = global_id!(:item, item.id)

    assert result =
             run!(@query,
               variables: %{
                 "id" => item_node_id,
                 "filters" => %{"locationIdEquals" => location_a_node_id}
               }
             )

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{
                 "locationTotals" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "amount" => 1,
                         "location" => %{"id" => ^location_a_node_id}
                       }
                     }
                   ]
                 }
               }
             }
           } = result
  end

  test "can handle zero deltas" do
    event = event()
    item_group = item_group(event)
    item = item(item_group, name: "Lager", inverse: false, unit: "cask")
    location = location(event, name: "Gallusplatz")

    movement(item,
      amount: 1,
      destination_location_id: location.id,
      inserted_at: ~U[2022-08-31 17:47:00Z]
    )

    movement(item,
      amount: 1,
      destination_location_id: location.id,
      inserted_at: ~U[2022-08-31 18:31:00Z]
    )

    item_node_id = global_id!(:item, item.id)

    assert result = run!(@query, variables: %{"id" => item_node_id})

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{
                 "locationTotals" => %{
                   "edges" => [
                     %{"node" => %{"amount" => 1, "delta" => 1}},
                     %{"node" => %{"amount" => 1, "delta" => 0}},
                     %{"node" => %{"amount" => 1, "delta" => 0}},
                     %{"node" => %{"amount" => 2, "delta" => 1}}
                   ]
                 }
               }
             }
           } = result

    assert result =
             run!(@query,
               variables: %{"id" => item_node_id, "filters" => %{"includeZeroDeltas" => false}}
             )

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{
                 "locationTotals" => %{
                   "edges" => [
                     %{"node" => %{"amount" => 1, "delta" => 1}},
                     %{"node" => %{"amount" => 2, "delta" => 1}}
                   ]
                 }
               }
             }
           } = result
  end

  test "can filter by date" do
    event = event()
    item_group = item_group(event)
    item = item(item_group, name: "Lager", inverse: false, unit: "cask")
    location = location(event, name: "Gallusplatz")

    movement(item,
      amount: 1,
      destination_location_id: location.id,
      inserted_at: ~U[2022-08-31 17:47:00Z]
    )

    movement(item,
      amount: 1,
      destination_location_id: location.id,
      inserted_at: ~U[2022-08-31 18:31:00Z]
    )

    item_node_id = global_id!(:item, item.id)

    assert result =
             run!(@query,
               variables: %{
                 "id" => item_node_id,
                 "filters" => %{
                   "dateFrom" => "2022-08-31 18:15:00Z",
                   "dateTo" => "2022-08-31 18:15:00Z"
                 }
               }
             )

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{
                 "locationTotals" => %{
                   "edges" => [
                     %{"node" => %{"amount" => 1, "delta" => 0}}
                   ]
                 }
               }
             }
           } = result
  end
end

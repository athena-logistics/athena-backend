defmodule AthenaWeb.Schema.Query.Node.Event.LocationTotalsTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!, $filters: LocationTotalFilter) {
    node(id: $id) {
      id
      ... on Event {
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

  test "gets event totals by id" do
    event = event(name: "Awesome Gathering")
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")
    movement(item, amount: 1, destination_location_id: location.id)

    event_node_id = global_id!(:event, event.id)
    location_node_id = global_id!(:location, location.id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)

    assert result = run!(@query, variables: %{"id" => event_node_id})

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
end

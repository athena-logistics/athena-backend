defmodule AthenaWeb.Schema.Query.Node.Event.TotalsTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      ... on Event {
        totals(first: 10) {
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
              date
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
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)

    assert result = run!(@query, variables: %{"id" => event_node_id})

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{
                 "totals" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "amount" => 1,
                         "date" => "20" <> _rest_date,
                         "item" => %{"id" => ^item_node_id},
                         "itemGroup" => %{"id" => ^item_group_node_id},
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

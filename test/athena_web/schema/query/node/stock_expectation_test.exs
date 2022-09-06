defmodule AthenaWeb.Schema.Query.Node.StockExpectationTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      ... on StockExpectation {
        item {
          id
        }
        itemGroup {
          id
        }
        location {
          id
        }
        event {
          id
        }
        importantThreshold
        warningThreshold
        insertedAt
        updatedAt
      }
    }
  }
  """

  test "gets stock expectation by id" do
    event = event()
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    stock_expectation =
      stock_expectation(item, location, %{important_threshold: 3, warning_threshold: 5})

    event_node_id = global_id!(:event, event.id)
    location_node_id = global_id!(:location, location.id)
    item_group_node_id = global_id!(:item_group, item_group.id)
    item_node_id = global_id!(:item, item.id)
    stock_expectation_node_id = global_id!(:stock_expectation, stock_expectation.id)

    assert result = run!(@query, variables: %{"id" => stock_expectation_node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^stock_expectation_node_id,
                 "event" => %{"id" => ^event_node_id},
                 "importantThreshold" => 3,
                 "insertedAt" => "2" <> _rest_inserted_at,
                 "item" => %{"id" => ^item_node_id},
                 "itemGroup" => %{"id" => ^item_group_node_id},
                 "location" => %{"id" => ^location_node_id},
                 "updatedAt" => "2" <> _rest_updated_at,
                 "warningThreshold" => 5
               }
             }
           } = result
  end
end

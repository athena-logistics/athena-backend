defmodule AthenaWeb.Schema.Mutation.SetStockExpectationTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @mutation """
  mutation SetStockExpectation($input: SetStockExpectationInput!) {
    setStockExpectation(input: $input) {
      successful
      messages {
        code
        field
      }
      result {
        id
        warningThreshold
        importantThreshold
      }
    }
  }
  """

  test "sets stock expectation" do
    event = event(name: "Awesome Gathering")
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    stock_expectation =
      stock_expectation(item, location, %{important_threshold: 3, warning_threshold: 5})

    item_node_id = global_id!(:item, item.id)
    location_node_id = global_id!(:location, location.id)
    stock_expectation_node_id = global_id!(:stock_expectation, stock_expectation.id)

    assert result =
             run!(@mutation,
               variables: %{
                 "input" => %{
                   "itemId" => item_node_id,
                   "locationId" => location_node_id,
                   "importantThreshold" => 4,
                   "warningThreshold" => 6
                 }
               }
             )

    assert %{
             data: %{
               "setStockExpectation" => %{
                 "successful" => true,
                 "result" => %{
                   "importantThreshold" => 4,
                   "warningThreshold" => 6,
                   "id" => ^stock_expectation_node_id
                 }
               }
             }
           } = result
  end
end

defmodule AthenaWeb.Schema.Mutation.DeleteStockExpectationTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @mutation """
  mutation DeleteStockExpectation($input: DeleteStockExpectationInput!) {
    deleteStockExpectation(input: $input) {
      successful
      messages {
        code
        field
      }
    }
  }
  """

  test "deletes stock expectation" do
    event = event(name: "Awesome Gathering")
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    stock_expectation =
      stock_expectation(item, location, %{important_threshold: 3, warning_threshold: 5})

    stock_expectation_node_id = global_id!(:stock_expectation, stock_expectation.id)

    assert result = run!(@mutation, variables: %{"input" => %{"id" => stock_expectation_node_id}})

    assert %{
             data: %{
               "deleteStockExpectation" => %{
                 "successful" => true
               }
             }
           } = result
  end
end

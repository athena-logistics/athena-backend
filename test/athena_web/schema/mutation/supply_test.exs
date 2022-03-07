defmodule AthenaWeb.Schema.Mutation.SupplyTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  alias Athena.Inventory
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement

  @mutation """
  mutation Supply($input: SupplyInput!) {
    supply(input: $input) {
      successful
      result {
        id
      }
    }
  }
  """

  test "creates supply entry" do
    event = event(name: "Awesome Gathering")
    %Location{id: location_id} = location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    location_node_id = global_id!(:location, location.id)
    item_node_id = global_id!(:item, item.id)

    assert result =
             run!(@mutation,
               variables: %{
                 "input" => %{
                   "itemId" => item_node_id,
                   "locationId" => location_node_id,
                   "amount" => 7
                 }
               }
             )

    assert %{
             data: %{
               "supply" => %{
                 "successful" => true,
                 "result" => %{
                   "id" => movement_global_id
                 }
               }
             }
           } = result

    assert %{type: :supply, id: movement_id} = from_global_id(movement_global_id)

    assert %Movement{
             id: ^movement_id,
             amount: 7,
             source_location_id: nil,
             destination_location_id: ^location_id
           } = Inventory.get_movement!(movement_id)
  end
end

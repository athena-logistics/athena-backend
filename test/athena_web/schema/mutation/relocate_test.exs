defmodule AthenaWeb.Schema.Mutation.RelocateTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  alias Athena.Inventory
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement

  @mutation """
  mutation Relocate($input: RelocateInput!) {
    relocate(input: $input) {
      successful
      result {
        id
      }
    }
  }
  """

  test "creates relocation entry" do
    event = event(name: "Awesome Gathering")
    %Location{id: source_location_id} = source_location = location(event, name: "Gallusplatz")

    %Location{id: destination_location_id} =
      destination_location = location(event, name: "Vadian")

    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    source_location_node_id = global_id!(:location, source_location.id)
    destination_location_node_id = global_id!(:location, destination_location.id)
    item_node_id = global_id!(:item, item.id)

    assert result =
             run!(@mutation,
               variables: %{
                 "input" => %{
                   "itemId" => item_node_id,
                   "sourceLocationId" => source_location_node_id,
                   "destinationLocationId" => destination_location_node_id,
                   "amount" => 7
                 }
               }
             )

    assert %{
             data: %{
               "relocate" => %{
                 "successful" => true,
                 "result" => %{
                   "id" => movement_global_id
                 }
               }
             }
           } = result

    assert %{type: :relocation, id: movement_id} = from_global_id(movement_global_id)

    assert %Movement{
             id: ^movement_id,
             amount: 7,
             source_location_id: ^source_location_id,
             destination_location_id: ^destination_location_id
           } = Inventory.get_movement!(movement_id)
  end
end

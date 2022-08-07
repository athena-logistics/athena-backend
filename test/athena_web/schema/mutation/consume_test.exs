defmodule AthenaWeb.Schema.Mutation.ConsumeTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  alias Athena.Inventory
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement

  @mutation """
  mutation Consume($input: ConsumeInput!) {
    consume(input: $input) {
      successful
      result {
        id
      }
      messages {
        code
        field
      }
    }
  }
  """

  test "creates consumation entry" do
    event = event(name: "Awesome Gathering")
    %Location{id: location_id} = location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    movement(item, %{destination_location_id: location_id, amount: 100})

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
               "consume" => %{
                 "successful" => true,
                 "result" => %{
                   "id" => movement_global_id
                 }
               }
             }
           } = result

    assert %{type: :consumption, id: movement_id} = from_global_id(movement_global_id)

    assert %Movement{
             id: ^movement_id,
             amount: 7,
             source_location_id: ^location_id,
             destination_location_id: nil
           } = Inventory.get_movement!(movement_id)
  end

  test "error on too big consumption" do
    event = event(name: "Awesome Gathering")
    %Location{id: location_id} = location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    movement(item, %{destination_location_id: location_id, amount: 10})

    location_node_id = global_id!(:location, location.id)
    item_node_id = global_id!(:item, item.id)

    assert result =
             run!(@mutation,
               variables: %{
                 "input" => %{
                   "itemId" => item_node_id,
                   "locationId" => location_node_id,
                   "amount" => 20
                 }
               }
             )

    assert %{
             data: %{
               "consume" => %{
                 "messages" => [
                   %{
                     "code" => "source_stock_negative",
                     "field" => "amount"
                   }
                 ],
                 "result" => nil,
                 "successful" => false
               }
             }
           } = result
  end
end

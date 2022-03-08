defmodule AthenaWeb.Schema.Subscription.MovementCreatedTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @subscription """
  subscription MovementCreated($eventId: ID, $locationId: ID) {
    movementCreated(eventId: $eventId, locationId: $locationId) {
      id
    }
  }
  """

  test "gets new movement by event id", %{socket: socket} do
    event = event()
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    event_node_id = global_id!(:event, event.id)

    ref = push_doc(socket, @subscription, variables: %{"eventId" => event_node_id})

    assert_reply ref, :ok, %{}

    movement = movement(item, destination_location_id: location.id)

    movement_node_id = global_id!(:supply, movement.id)

    assert_push("subscription:data", %{
      result:
        %{
          data: %{
            "movementCreated" => %{
              "id" => ^movement_node_id
            }
          }
        } = result
    })

    assert_no_error(result)
  end

  test "gets new movement by location id", %{socket: socket} do
    event = event()
    location = location(event, name: "Gallusplatz")
    item_group = item_group(event, name: "Bier")
    item = item(item_group, name: "Lager")

    location_node_id = global_id!(:location, location.id)

    ref = push_doc(socket, @subscription, variables: %{"locationId" => location_node_id})

    assert_reply ref, :ok, %{}

    movement = movement(item, destination_location_id: location.id)

    movement_node_id = global_id!(:supply, movement.id)

    assert_push("subscription:data", %{
      result:
        %{
          data: %{
            "movementCreated" => %{
              "id" => ^movement_node_id
            }
          }
        } = result
    })

    assert_no_error(result)
  end
end

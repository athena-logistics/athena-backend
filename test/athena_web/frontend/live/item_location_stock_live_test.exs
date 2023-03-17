defmodule AthenaWeb.Frontend.ItemLocationStockLiveTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  setup do
    event = event()
    location = location(event)
    item_group = item_group(event)
    item = item(item_group)

    movement(item, %{destination_location_id: location.id})

    {:ok, event: event, location: location, item_group: item_group, item: item}
  end

  test "disconnected", %{conn: conn, location: location} do
    conn = get(conn, ~p"/logistics/locations/#{location.id}")

    assert html = html_response(conn, 200)

    assert ["1"] =
             html
             |> Floki.parse_document!()
             |> Floki.find(~S(input[type="number"]))
             |> Floki.attribute("value")
  end
end

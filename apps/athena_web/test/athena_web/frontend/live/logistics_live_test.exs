defmodule AthenaWeb.Frontend.LogisticsLiveTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Phoenix.LiveViewTest

  import Athena.Fixture

  setup do
    event = event()
    location = location(event)
    item_group = item_group(event)
    item = item(item_group)

    movement(item, %{destination_location_id: location.id})

    {:ok, event: event, location: location, item_group: item_group, item: item}
  end

  test "disconnected and connected mount", %{
    conn: conn,
    event: event,
    location: location,
    item: item
  } do
    conn = get(conn, Routes.frontend_live_path(conn, AthenaWeb.Frontend.LogisticsLive, event.id))

    assert html = html_response(conn, 200)

    assert "1" = html |> Floki.parse_document!() |> Floki.find("td.stock") |> Floki.text()

    movement(item, %{destination_location_id: location.id})

    {:ok, _view, html} = live(conn)

    assert "2" = html |> Floki.parse_document!() |> Floki.find("td.stock") |> Floki.text()
  end
end

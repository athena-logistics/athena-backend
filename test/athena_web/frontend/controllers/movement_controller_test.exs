defmodule AthenaWeb.Frontend.MovementControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  @create_attrs %{amount: 42}
  @invalid_attrs %{amount: nil}

  setup do
    event = event()
    location_a = location(event)
    location_b = location(event)
    item_group = item_group(event)
    item = item(item_group)

    {:ok,
     event: event,
     location_a: location_a,
     location_b: location_b,
     item_group: item_group,
     item: item}
  end

  describe "supply new movement" do
    test "renders form", %{conn: conn, event: event} do
      conn = get(conn, Routes.frontend_logistics_movement_path(conn, :supply_new, event.id))
      assert html_response(conn, 200) =~ "Supply Item"
    end
  end

  describe "supply create movement" do
    test "redirects to show when data is valid", %{
      conn: conn,
      event: %{id: event_id} = event,
      item: item,
      location_a: location
    } do
      conn =
        post(conn, Routes.frontend_logistics_movement_path(conn, :supply_create, event.id),
          movement:
            @create_attrs
            |> Map.put(:destination_location_id, location.id)
            |> Map.put(:item_id, item.id)
        )

      assert %{event: ^event_id} = redirected_params(conn)

      assert redirected_to(conn) ==
               Routes.frontend_logistics_live_path(conn, AthenaWeb.Frontend.LogisticsLive, event)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      event: event,
      item: item,
      location_a: location
    } do
      conn =
        post(conn, Routes.frontend_logistics_movement_path(conn, :supply_create, event.id),
          movement:
            @invalid_attrs
            |> Map.put(:destination_location_id, location.id)
            |> Map.put(:item_id, item.id)
        )

      assert html_response(conn, 200) =~ "Supply Item"
    end
  end

  describe "relocate new movement" do
    test "renders form", %{conn: conn, event: event} do
      conn = get(conn, Routes.frontend_logistics_movement_path(conn, :relocate_new, event.id))
      assert html_response(conn, 200) =~ "Move Item"
    end
  end

  describe "relocate create movement" do
    test "redirects to show when data is valid", %{
      conn: conn,
      event: %{id: event_id} = event,
      item: item,
      location_a: location_a,
      location_b: location_b
    } do
      conn =
        post(conn, Routes.frontend_logistics_movement_path(conn, :relocate_create, event.id),
          movement:
            @create_attrs
            |> Map.put(:source_location_id, location_a.id)
            |> Map.put(:destination_location_id, location_b.id)
            |> Map.put(:item_id, item.id)
        )

      assert %{event: ^event_id} = redirected_params(conn)

      assert redirected_to(conn) ==
               Routes.frontend_logistics_live_path(conn, AthenaWeb.Frontend.LogisticsLive, event)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      event: event,
      item: item,
      location_a: location_a,
      location_b: location_b
    } do
      conn =
        post(conn, Routes.frontend_logistics_movement_path(conn, :relocate_create, event.id),
          movement:
            @invalid_attrs
            |> Map.put(:source_location_id, location_a.id)
            |> Map.put(:destination_location_id, location_b.id)
            |> Map.put(:item_id, item.id)
        )

      assert html_response(conn, 200) =~ "Move Item"
    end
  end
end

defmodule AthenaWeb.Frontend.MovementLiveTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

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
      conn =
        conn
        |> put_req_header("accept-language", "en")
        |> get(~p"/logistics/events/#{event}/movements/supply")

      assert html_response(conn, 200) =~ "Supply Item"
    end
  end

  describe "supply create movement" do
    test "redirects to overview when data is valid", %{
      conn: conn,
      event: event,
      item: item,
      location_a: location
    } do
      conn = get(conn, ~p"/logistics/events/#{event}/movements/supply")

      {:ok, view, _html} = live(conn)

      render_submit(view, :save, %{
        "movement_live" => %{
          "destination_location_id" => location.id,
          "movements" => %{0 => %{"item_id" => item.id, "amount" => 42}}
        }
      })

      {path, flash} = assert_redirect view

      assert path == ~p"/logistics/events/#{event}/overview"

      assert %{"info" => _message} = flash
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      event: event,
      item: item,
      location_a: location
    } do
      conn = get(conn, ~p"/logistics/events/#{event}/movements/supply")

      {:ok, view, _html} = live(conn)

      html =
        render_submit(view, :save, %{
          "movement_live" => %{
            "destination_location_id" => location.id,
            "movements" => %{0 => %{"item_id" => item.id, "amount" => -10}}
          }
        })

      refute_redirected view, ~p"/logistics/events/#{event}/overview"

      assert html
             |> Floki.parse_document!()
             |> Floki.find(".invalid-feedback")
             |> Floki.text() =~ "0"
    end
  end

  describe "relocate new movement" do
    test "renders form", %{conn: conn, event: event} do
      conn =
        conn
        |> put_req_header("accept-language", "en")
        |> get(~p"/logistics/events/#{event}/movements/relocate")

      assert html_response(conn, 200) =~ "Move Item"
    end
  end

  describe "relocate create movement" do
    test "redirects to show when data is valid", %{
      conn: conn,
      event: event,
      item: item,
      location_a: location_a,
      location_b: location_b
    } do
      movement(item, %{destination_location_id: location_a.id, amount: 100})

      conn = get(conn, ~p"/logistics/events/#{event}/movements/relocate")

      {:ok, view, _html} = live(conn)

      render_submit(view, :save, %{
        "movement_live" => %{
          "source_location_id" => location_a.id,
          "destination_location_id" => location_b.id,
          "movements" => %{0 => %{"item_id" => item.id, "amount" => 42}}
        }
      })

      {path, flash} = assert_redirect view

      assert path == ~p"/logistics/events/#{event}/overview"

      assert %{"info" => _message} = flash
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      event: event,
      item: item,
      location_a: location_a
    } do
      conn = get(conn, ~p"/logistics/events/#{event}/movements/relocate")

      {:ok, view, _html} = live(conn)

      html =
        render_submit(view, :save, %{
          "movement_live" => %{
            "destination_location_id" => location_a.id,
            "movements" => %{0 => %{"item_id" => item.id, "amount" => 10}}
          }
        })

      refute_redirected view, ~p"/logistics/events/#{event}/overview"

      assert html
             |> Floki.parse_document!()
             |> Floki.find(".help-block")
             |> Floki.text()
    end
  end
end

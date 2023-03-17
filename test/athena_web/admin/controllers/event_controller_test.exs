defmodule AthenaWeb.Admin.EventControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  alias Athena.Inventory

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all events", %{conn: conn} do
      conn = get(conn, ~p"/admin/events")
      assert html_response(conn, 200) =~ "events"
    end
  end

  describe "new event" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/events/new")
      assert html_response(conn, 200) =~ "create event"
    end
  end

  describe "create event" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/events", event: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/events/#{id}"

      event = Inventory.get_event!(id)

      conn = get(conn, ~p"/admin/events/#{id}")
      assert html_response(conn, 200) =~ event.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/events", event: @invalid_attrs)
      assert html_response(conn, 200) =~ "create event"
    end
  end

  describe "edit event" do
    setup [:create_event]

    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get(conn, ~p"/admin/events/#{event}/edit")
      assert html_response(conn, 200) =~ "edit #{event.name}"
    end
  end

  describe "update event" do
    setup [:create_event]

    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put(conn, ~p"/admin/events/#{event}", event: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/events/#{event}"

      conn = get(conn, ~p"/admin/events/#{event}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, ~p"/admin/events/#{event}", event: @invalid_attrs)
      assert html_response(conn, 200) =~ "edit #{event.name}"
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, ~p"/admin/events/#{event}")
      assert redirected_to(conn) == ~p"/admin/events"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/events/#{event}")
      end
    end
  end

  defp create_event(_tags) do
    {:ok, event: event()}
  end
end

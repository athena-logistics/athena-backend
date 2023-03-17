defmodule AthenaWeb.Admin.LocationControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  alias Athena.Inventory

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    setup [:create_event]

    test "lists all locations", %{conn: conn, event: event} do
      conn = get(conn, ~p"/admin/events/#{event.id}/locations")
      assert html_response(conn, 200) =~ "locations"
    end
  end

  describe "new location" do
    setup [:create_event]

    test "renders form", %{conn: conn, event: event} do
      conn = get(conn, ~p"/admin/events/#{event.id}/locations/new")
      assert html_response(conn, 200) =~ "create location"
    end
  end

  describe "create location" do
    setup [:create_event]

    test "redirects to show when data is valid", %{conn: conn, event: event} do
      conn = post(conn, ~p"/admin/events/#{event.id}/locations", location: @create_attrs)

      assert %{id: id} = redirected_params(conn)

      location = Inventory.get_location!(id)

      assert redirected_to(conn) == ~p"/admin/locations/#{id}"

      conn = get(conn, ~p"/admin/locations/#{id}")
      assert html_response(conn, 200) =~ location.name
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = post(conn, ~p"/admin/events/#{event.id}/locations", location: @invalid_attrs)

      assert html_response(conn, 200) =~ "create location"
    end
  end

  describe "edit location" do
    setup [:create_location]

    test "renders form for editing chosen location", %{conn: conn, location: location} do
      conn = get(conn, ~p"/admin/locations/#{location}/edit")
      assert html_response(conn, 200) =~ "edit #{location.name}"
    end
  end

  describe "update location" do
    setup [:create_location]

    test "redirects when data is valid", %{conn: conn, location: location} do
      conn = put(conn, ~p"/admin/locations/#{location}", location: @update_attrs)

      assert redirected_to(conn) == ~p"/admin/locations/#{location}"

      conn = get(conn, ~p"/admin/locations/#{location}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, location: location} do
      conn = put(conn, ~p"/admin/locations/#{location}", location: @invalid_attrs)

      assert html_response(conn, 200) =~ "edit #{location.name}"
    end
  end

  describe "delete location" do
    setup [:create_event, :create_location]

    test "deletes chosen location", %{conn: conn, location: location, event: event} do
      conn = delete(conn, ~p"/admin/locations/#{location}")
      assert redirected_to(conn) == ~p"/admin/events/#{event.id}/locations"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/locations/#{location}")
      end
    end
  end

  defp create_event(_tags) do
    {:ok, event: event()}
  end

  defp create_location(%{event: event}) do
    {:ok, location: location(event)}
  end

  defp create_location(_tags) do
    {:ok, location: location()}
  end
end

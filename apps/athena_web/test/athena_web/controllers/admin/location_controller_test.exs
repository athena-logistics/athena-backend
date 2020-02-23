defmodule AthenaWeb.Admin.LocationControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    setup [:create_event]

    test "lists all locations", %{conn: conn, event: event} do
      conn = get(conn, Routes.location_path(conn, :index, event.id))
      assert html_response(conn, 200) =~ "Listing Locations"
    end
  end

  describe "new location" do
    setup [:create_event]

    test "renders form", %{conn: conn, event: event} do
      conn = get(conn, Routes.location_path(conn, :new, event.id))
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "create location" do
    setup [:create_event]

    test "redirects to show when data is valid", %{conn: conn, event: event} do
      conn = post(conn, Routes.location_path(conn, :create, event.id), location: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.location_path(conn, :show, id)

      conn = get(conn, Routes.location_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Location"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = post(conn, Routes.location_path(conn, :create, event.id), location: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "edit location" do
    setup [:create_location]

    test "renders form for editing chosen location", %{conn: conn, location: location} do
      conn = get(conn, Routes.location_path(conn, :edit, location))
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "update location" do
    setup [:create_location]

    test "redirects when data is valid", %{conn: conn, location: location} do
      conn = put(conn, Routes.location_path(conn, :update, location), location: @update_attrs)
      assert redirected_to(conn) == Routes.location_path(conn, :show, location)

      conn = get(conn, Routes.location_path(conn, :show, location))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, location: location} do
      conn = put(conn, Routes.location_path(conn, :update, location), location: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "delete location" do
    setup [:create_event, :create_location]

    test "deletes chosen location", %{conn: conn, location: location, event: event} do
      conn = delete(conn, Routes.location_path(conn, :delete, location))
      assert redirected_to(conn) == Routes.location_path(conn, :index, event.id)

      assert_error_sent 404, fn ->
        get(conn, Routes.location_path(conn, :show, location))
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

defmodule AthenaWeb.Frontend.LocationControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  describe "show location" do
    setup [:create_location]

    test "for logistics", %{conn: conn, location: location} do
      conn = get(conn, Routes.frontend_logistics_location_path(conn, :show, location.id))

      assert html_response(conn, 200) =~ location.name
    end

    test "for vendor", %{conn: conn, location: location} do
      conn = get(conn, Routes.frontend_logistics_location_path(conn, :show, location.id))

      assert html_response(conn, 200) =~ location.name
    end
  end

  defp create_location(_tags) do
    {:ok, location: location()}
  end
end

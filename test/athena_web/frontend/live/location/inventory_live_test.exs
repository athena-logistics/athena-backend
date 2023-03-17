defmodule AthenaWeb.Frontend.Location.InventoryLiveTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  describe "show location" do
    setup [:create_location]

    test "for logistics", %{conn: conn, location: location} do
      conn = get(conn, ~p"/logistics/locations/#{location.id}")

      assert html_response(conn, 200) =~ location.name
    end

    test "for vendor", %{conn: conn, location: location} do
      conn = get(conn, ~p"/logistics/locations/#{location.id}")

      assert html_response(conn, 200) =~ location.name
    end
  end

  defp create_location(_tags) do
    {:ok, location: location()}
  end
end

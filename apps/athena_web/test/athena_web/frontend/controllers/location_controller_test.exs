defmodule AthenaWeb.Frontend.LocationControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  describe "show location" do
    setup [:create_location]

    test "redirects to show when data is valid", %{conn: conn, location: location} do
      conn = get(conn, Routes.frontend_location_path(conn, :show, location.id))

      assert html_response(conn, 200) =~ location.name
    end
  end

  defp create_location(_tags) do
    {:ok, location: location()}
  end
end

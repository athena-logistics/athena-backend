defmodule AthenaWeb.Admin.MovementControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  @create_attrs %{amount: 42}
  @update_attrs %{amount: 43}
  @invalid_attrs %{amount: nil}

  describe "index" do
    setup [:create_item]

    test "lists all movements", %{conn: conn, item: item} do
      conn = get(conn, ~p"/admin/items/#{item.id}/movements")
      assert html_response(conn, 200) =~ "movements"
    end
  end

  describe "new movement" do
    setup [:create_item]

    test "renders form", %{conn: conn, item: item} do
      conn = get(conn, ~p"/admin/items/#{item.id}/movements/new")
      assert html_response(conn, 200) =~ "create movement"
    end
  end

  describe "create movement" do
    setup [:create_item, :create_location, :create_supply]

    test "redirects to show when data is valid", %{conn: conn, item: item, location: location} do
      conn =
        post(conn, ~p"/admin/items/#{item.id}/movements",
          movement: Map.put(@create_attrs, :source_location_id, location.id)
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/movements/#{id}"

      conn = get(conn, ~p"/admin/movements/#{id}")
      assert html_response(conn, 200) =~ item.name
      assert html_response(conn, 200) =~ location.name
    end

    test "renders errors when data is invalid", %{conn: conn, item: item, location: location} do
      conn =
        post(conn, ~p"/admin/items/#{item.id}/movements",
          movement: Map.put(@invalid_attrs, :source_location_id, location.id)
        )

      assert html_response(conn, 200) =~ "create movement"
    end
  end

  describe "edit movement" do
    setup [:create_movement]

    test "renders form for editing chosen movement", %{conn: conn, movement: movement} do
      conn = get(conn, ~p"/admin/movements/#{movement}/edit")
      assert html_response(conn, 200) =~ "edit movement"
    end
  end

  describe "update movement" do
    setup [:create_movement]

    test "redirects when data is valid", %{conn: conn, movement: movement} do
      conn = put(conn, ~p"/admin/movements/#{movement}", movement: @update_attrs)

      assert redirected_to(conn) == ~p"/admin/movements/#{movement}"

      conn = get(conn, ~p"/admin/movements/#{movement}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, movement: movement} do
      conn = put(conn, ~p"/admin/movements/#{movement}", movement: @invalid_attrs)

      assert html_response(conn, 200) =~ "edit movement"
    end
  end

  describe "delete movement" do
    setup [:create_item, :create_movement]

    test "deletes chosen movement", %{conn: conn, movement: movement, item: item} do
      conn = delete(conn, ~p"/admin/movements/#{movement}")
      assert redirected_to(conn) == ~p"/admin/items/#{item.id}/movements"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/movements/#{movement}")
      end
    end
  end

  defp create_item(_tags) do
    {:ok, item: item()}
  end

  defp create_location(%{item: item}) do
    item = Repo.preload(item, :event)
    {:ok, location: location(item.event)}
  end

  defp create_movement(%{item: item}) do
    {:ok, movement: movement(item)}
  end

  defp create_movement(_tags) do
    {:ok, movement: movement()}
  end

  defp create_supply(%{item: item, location: location} = _tags) do
    {:ok, supply: movement(item, %{destination_location_id: location.id, amount: 100})}
  end
end

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
      conn = get(conn, Routes.admin_movement_path(conn, :index, item.id))
      assert html_response(conn, 200) =~ "Listing Movements"
    end
  end

  describe "new movement" do
    setup [:create_item]

    test "renders form", %{conn: conn, item: item} do
      conn = get(conn, Routes.admin_movement_path(conn, :new, item.id))
      assert html_response(conn, 200) =~ "New Movement"
    end
  end

  describe "create movement" do
    setup [:create_item, :create_location]

    test "redirects to show when data is valid", %{conn: conn, item: item, location: location} do
      conn =
        post(conn, Routes.admin_movement_path(conn, :create, item.id),
          movement: Map.put(@create_attrs, :source_location_id, location.id)
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_movement_path(conn, :show, id)

      conn = get(conn, Routes.admin_movement_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Movement"
    end

    test "renders errors when data is invalid", %{conn: conn, item: item, location: location} do
      conn =
        post(conn, Routes.admin_movement_path(conn, :create, item.id),
          movement: Map.put(@invalid_attrs, :source_location_id, location.id)
        )

      assert html_response(conn, 200) =~ "New Movement"
    end
  end

  describe "edit movement" do
    setup [:create_movement]

    test "renders form for editing chosen movement", %{conn: conn, movement: movement} do
      conn = get(conn, Routes.admin_movement_path(conn, :edit, movement))
      assert html_response(conn, 200) =~ "Edit Movement"
    end
  end

  describe "update movement" do
    setup [:create_movement]

    test "redirects when data is valid", %{conn: conn, movement: movement} do
      conn =
        put(conn, Routes.admin_movement_path(conn, :update, movement), movement: @update_attrs)

      assert redirected_to(conn) == Routes.admin_movement_path(conn, :show, movement)

      conn = get(conn, Routes.admin_movement_path(conn, :show, movement))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, movement: movement} do
      conn =
        put(conn, Routes.admin_movement_path(conn, :update, movement), movement: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Movement"
    end
  end

  describe "delete movement" do
    setup [:create_item, :create_movement]

    test "deletes chosen movement", %{conn: conn, movement: movement, item: item} do
      conn = delete(conn, Routes.admin_movement_path(conn, :delete, movement))
      assert redirected_to(conn) == Routes.admin_movement_path(conn, :index, item.id)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_movement_path(conn, :show, movement))
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
end

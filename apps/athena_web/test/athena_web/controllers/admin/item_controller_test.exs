defmodule AthenaWeb.Admin.ItemControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  @create_attrs %{name: "some name", unit: "Fass", inverse: false}
  @update_attrs %{name: "some updated name", unit: "Box", inverse: true}
  @invalid_attrs %{name: nil, unit: nil, inverse: nil}

  describe "index" do
    setup [:create_item_group]

    test "lists all items", %{conn: conn, item_group: item_group} do
      conn = get(conn, Routes.admin_item_path(conn, :index, item_group.id))
      assert html_response(conn, 200) =~ "Listing Items"
    end
  end

  describe "new item" do
    setup [:create_item_group]

    test "renders form", %{conn: conn, item_group: item_group} do
      conn = get(conn, Routes.admin_item_path(conn, :new, item_group.id))
      assert html_response(conn, 200) =~ "New Item"
    end
  end

  describe "create item" do
    setup [:create_item_group]

    test "redirects to show when data is valid", %{conn: conn, item_group: item_group} do
      conn = post(conn, Routes.admin_item_path(conn, :create, item_group.id), item: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_item_path(conn, :show, id)

      conn = get(conn, Routes.admin_item_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Item"
    end

    test "renders errors when data is invalid", %{conn: conn, item_group: item_group} do
      conn =
        post(conn, Routes.admin_item_path(conn, :create, item_group.id), item: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Item"
    end
  end

  describe "edit item" do
    setup [:create_item]

    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get(conn, Routes.admin_item_path(conn, :edit, item))
      assert html_response(conn, 200) =~ "Edit Item"
    end
  end

  describe "update item" do
    setup [:create_item]

    test "redirects when data is valid", %{conn: conn, item: item} do
      conn = put(conn, Routes.admin_item_path(conn, :update, item), item: @update_attrs)
      assert redirected_to(conn) == Routes.admin_item_path(conn, :show, item)

      conn = get(conn, Routes.admin_item_path(conn, :show, item))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      conn = put(conn, Routes.admin_item_path(conn, :update, item), item: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Item"
    end
  end

  describe "delete item" do
    setup [:create_item_group, :create_item]

    test "deletes chosen item", %{conn: conn, item: item, item_group: item_group} do
      conn = delete(conn, Routes.admin_item_path(conn, :delete, item))
      assert redirected_to(conn) == Routes.admin_item_path(conn, :index, item_group.id)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_item_path(conn, :show, item))
      end
    end
  end

  defp create_item_group(_tags) do
    {:ok, item_group: item_group()}
  end

  defp create_item(%{item_group: item_group}) do
    {:ok, item: item(item_group)}
  end

  defp create_item(_tags) do
    {:ok, item: item()}
  end
end

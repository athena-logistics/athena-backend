defmodule AthenaWeb.Admin.ItemControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  @create_attrs %{name: "some name", unit: "Fass", inverse: false}
  @update_attrs %{name: "some updated name", unit: "Box", inverse: true}
  @invalid_attrs %{name: nil, unit: nil, inverse: nil}

  describe "new item" do
    setup [:create_item_group]

    test "renders form", %{conn: conn, item_group: item_group} do
      conn = get(conn, ~p"/admin/item_groups/#{item_group.id}/items/new")
      assert html_response(conn, 200) =~ "create item"
    end
  end

  describe "create item" do
    setup [:create_item_group]

    test "redirects to show when data is valid", %{conn: conn, item_group: item_group} do
      conn = post(conn, ~p"/admin/item_groups/#{item_group.id}/items", item: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/items/#{id}"

      conn = get(conn, ~p"/admin/items/#{id}")
      assert html_response(conn, 200) =~ @create_attrs[:name]
    end

    test "renders errors when data is invalid", %{conn: conn, item_group: item_group} do
      conn = post(conn, ~p"/admin/item_groups/#{item_group.id}/items", item: @invalid_attrs)

      assert html_response(conn, 200) =~ "create item"
    end
  end

  describe "edit item" do
    setup [:create_item]

    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get(conn, ~p"/admin/items/#{item}/edit")
      assert html_response(conn, 200) =~ "edit #{item.name}"
    end
  end

  describe "update item" do
    setup [:create_item]

    test "redirects when data is valid", %{conn: conn, item: item} do
      conn = put(conn, ~p"/admin/items/#{item}", item: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/items/#{item}"

      conn = get(conn, ~p"/admin/items/#{item}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      conn = put(conn, ~p"/admin/items/#{item}", item: @invalid_attrs)
      assert html_response(conn, 200) =~ "edit #{item.name}"
    end
  end

  describe "delete item" do
    setup [:create_item_group, :create_item]

    test "deletes chosen item", %{conn: conn, item: item, item_group: item_group} do
      conn = delete(conn, ~p"/admin/items/#{item}")
      assert redirected_to(conn) == ~p"/admin/item_groups/#{item_group.id}/items"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/items/#{item}")
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

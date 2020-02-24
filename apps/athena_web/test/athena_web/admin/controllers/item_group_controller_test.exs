defmodule AthenaWeb.Admin.ItemGroupControllerTest do
  use Athena.DataCase
  use AthenaWeb.ConnCase

  import Athena.Fixture

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    setup [:create_event]

    test "lists all item_groups", %{conn: conn, event: event} do
      conn = get(conn, Routes.admin_item_group_path(conn, :index, event.id))
      assert html_response(conn, 200) =~ "Listing Item groups"
    end
  end

  describe "new item_group" do
    setup [:create_event]

    test "renders form", %{conn: conn, event: event} do
      conn = get(conn, Routes.admin_item_group_path(conn, :new, event.id))
      assert html_response(conn, 200) =~ "New Item group"
    end
  end

  describe "create item_group" do
    setup [:create_event]

    test "redirects to show when data is valid", %{conn: conn, event: event} do
      conn =
        post(conn, Routes.admin_item_group_path(conn, :create, event.id),
          item_group: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_item_group_path(conn, :show, id)

      conn = get(conn, Routes.admin_item_group_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Item group"
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn =
        post(conn, Routes.admin_item_group_path(conn, :create, event.id),
          item_group: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Item group"
    end
  end

  describe "edit item_group" do
    setup [:create_item_group]

    test "renders form for editing chosen item_group", %{conn: conn, item_group: item_group} do
      conn = get(conn, Routes.admin_item_group_path(conn, :edit, item_group))
      assert html_response(conn, 200) =~ "Edit Item group"
    end
  end

  describe "update item_group" do
    setup [:create_item_group]

    test "redirects when data is valid", %{conn: conn, item_group: item_group} do
      conn =
        put(conn, Routes.admin_item_group_path(conn, :update, item_group),
          item_group: @update_attrs
        )

      assert redirected_to(conn) == Routes.admin_item_group_path(conn, :show, item_group)

      conn = get(conn, Routes.admin_item_group_path(conn, :show, item_group))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, item_group: item_group} do
      conn =
        put(conn, Routes.admin_item_group_path(conn, :update, item_group),
          item_group: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Item group"
    end
  end

  describe "delete item_group" do
    setup [:create_event, :create_item_group]

    test "deletes chosen item_group", %{conn: conn, item_group: item_group, event: event} do
      conn = delete(conn, Routes.admin_item_group_path(conn, :delete, item_group))
      assert redirected_to(conn) == Routes.admin_item_group_path(conn, :index, event.id)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_item_group_path(conn, :show, item_group))
      end
    end
  end

  defp create_event(_tags) do
    {:ok, event: event()}
  end

  defp create_item_group(%{event: event}) do
    {:ok, item_group: item_group(event)}
  end

  defp create_item_group(_tags) do
    {:ok, item_group: item_group()}
  end
end

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
      conn = get(conn, ~p"/admin/events/#{event.id}/item_groups")
      assert html_response(conn, 200) =~ "item groups"
    end
  end

  describe "new item_group" do
    setup [:create_event]

    test "renders form", %{conn: conn, event: event} do
      conn = get(conn, ~p"/admin/events/#{event.id}/item_groups/new")
      assert html_response(conn, 200) =~ "create item group"
    end
  end

  describe "create item_group" do
    setup [:create_event]

    test "redirects to show when data is valid", %{conn: conn, event: event} do
      conn = post(conn, ~p"/admin/events/#{event.id}/item_groups", item_group: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/item_groups/#{id}"

      conn = get(conn, ~p"/admin/item_groups/#{id}")
      assert html_response(conn, 200) =~ @create_attrs[:name]
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = post(conn, ~p"/admin/events/#{event.id}/item_groups", item_group: @invalid_attrs)

      assert html_response(conn, 200) =~ "create item group"
    end
  end

  describe "edit item_group" do
    setup [:create_item_group]

    test "renders form for editing chosen item_group", %{conn: conn, item_group: item_group} do
      conn = get(conn, ~p"/admin/item_groups/#{item_group}/edit")
      assert html_response(conn, 200) =~ "edit #{item_group.name}"
    end
  end

  describe "update item_group" do
    setup [:create_item_group]

    test "redirects when data is valid", %{conn: conn, item_group: item_group} do
      conn = put(conn, ~p"/admin/item_groups/#{item_group}", item_group: @update_attrs)

      assert redirected_to(conn) == ~p"/admin/item_groups/#{item_group}"

      conn = get(conn, ~p"/admin/item_groups/#{item_group}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, item_group: item_group} do
      conn = put(conn, ~p"/admin/item_groups/#{item_group}", item_group: @invalid_attrs)

      assert html_response(conn, 200) =~ "edit #{item_group.name}"
    end
  end

  describe "delete item_group" do
    setup [:create_event, :create_item_group]

    test "deletes chosen item_group", %{conn: conn, item_group: item_group, event: event} do
      conn = delete(conn, ~p"/admin/item_groups/#{item_group}")
      assert redirected_to(conn) == ~p"/admin/events/#{event.id}/item_groups"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/item_groups/#{item_group}")
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

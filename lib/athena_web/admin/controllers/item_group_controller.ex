defmodule AthenaWeb.Admin.ItemGroupController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.ItemGroup

  def index(conn, %{"event" => event}) do
    event = Inventory.get_event!(event)
    item_groups = Inventory.list_item_groups(event)

    render_with_navigation(conn, event, "index.html", item_groups: item_groups, event: event)
  end

  def new(conn, %{"event" => event}) do
    event = Inventory.get_event!(event)
    changeset = Inventory.change_item_group(%ItemGroup{})

    render_with_navigation(conn, event, "new.html", changeset: changeset, event: event)
  end

  def create(conn, %{"item_group" => item_group_params, "event" => event}) do
    event = Inventory.get_event!(event)

    case Inventory.create_item_group(event, item_group_params) do
      {:ok, item_group} ->
        conn
        |> put_flash(:info, gettext("Item group created successfully."))
        |> redirect(to: ~p"/admin/item_groups/#{item_group}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, event, "new.html", changeset: changeset, event: event)
    end
  end

  def show(conn, %{"id" => id}) do
    item_group =
      id
      |> Inventory.get_item_group!()
      |> Repo.preload([:event, :items])

    render_with_navigation(conn, item_group.event, "show.html", item_group: item_group)
  end

  def edit(conn, %{"id" => id}) do
    item_group =
      id
      |> Inventory.get_item_group!()
      |> Repo.preload(:event)

    changeset = Inventory.change_item_group(item_group)

    render_with_navigation(conn, item_group.event, "edit.html",
      item_group: item_group,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "item_group" => item_group_params}) do
    item_group =
      id
      |> Inventory.get_item_group!()
      |> Repo.preload(:event)

    case Inventory.update_item_group(item_group, item_group_params) do
      {:ok, item_group} ->
        conn
        |> put_flash(:info, gettext("Item group updated successfully."))
        |> redirect(to: ~p"/admin/item_groups/#{item_group}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, item_group.event, "edit.html",
          item_group: item_group,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    %{event_id: event_id} = item_group = Inventory.get_item_group!(id)
    {:ok, _item_group} = Inventory.delete_item_group(item_group)

    conn
    |> put_flash(:info, gettext("Item group deleted successfully."))
    |> redirect(to: ~p"/admin/events/#{event_id}/item_groups")
  end
end

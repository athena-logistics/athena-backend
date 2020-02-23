defmodule AthenaWeb.Admin.ItemGroupController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.ItemGroup

  def index(conn, %{"event" => event}) do
    event = Inventory.get_event!(event)
    item_groups = Inventory.list_item_groups(event)

    render(conn, "index.html", item_groups: item_groups, event: event)
  end

  def new(conn, %{"event" => event}) do
    event = Inventory.get_event!(event)
    changeset = Inventory.change_item_group(%ItemGroup{})

    render(conn, "new.html", changeset: changeset, event: event)
  end

  def create(conn, %{"item_group" => item_group_params, "event" => event}) do
    event = Inventory.get_event!(event)

    case Inventory.create_item_group(event, item_group_params) do
      {:ok, item_group} ->
        conn
        |> put_flash(:info, "Item group created successfully.")
        |> redirect(to: Routes.admin_item_group_path(conn, :show, item_group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, event: event)
    end
  end

  def show(conn, %{"id" => id}) do
    item_group = Inventory.get_item_group!(id)

    render(conn, "show.html", item_group: item_group)
  end

  def edit(conn, %{"id" => id}) do
    item_group = Inventory.get_item_group!(id)
    changeset = Inventory.change_item_group(item_group)

    render(conn, "edit.html", item_group: item_group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item_group" => item_group_params}) do
    item_group = Inventory.get_item_group!(id)

    case Inventory.update_item_group(item_group, item_group_params) do
      {:ok, item_group} ->
        conn
        |> put_flash(:info, "Item group updated successfully.")
        |> redirect(to: Routes.admin_item_group_path(conn, :show, item_group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item_group: item_group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    %{event_id: event_id} = item_group = Inventory.get_item_group!(id)
    {:ok, _item_group} = Inventory.delete_item_group(item_group)

    conn
    |> put_flash(:info, "Item group deleted successfully.")
    |> redirect(to: Routes.admin_item_group_path(conn, :index, event_id))
  end
end

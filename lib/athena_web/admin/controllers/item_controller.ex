defmodule AthenaWeb.Admin.ItemController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.Item

  def index(conn, %{"item_group" => item_group}) do
    item_group =
      item_group
      |> Inventory.get_item_group!()
      |> Repo.preload(:event)

    items = Inventory.list_items(item_group)

    render_with_navigation(conn, item_group.event, "index.html",
      items: items,
      item_group: item_group
    )
  end

  def new(conn, %{"item_group" => item_group}) do
    item_group =
      item_group
      |> Inventory.get_item_group!()
      |> Repo.preload(:event)

    changeset = Inventory.change_item(%Item{})

    render_with_navigation(conn, item_group.event, "new.html",
      changeset: changeset,
      item_group: item_group
    )
  end

  def create(conn, %{"item" => item_params, "item_group" => item_group}) do
    item_group =
      item_group
      |> Inventory.get_item_group!()
      |> Repo.preload(:event)

    case Inventory.create_item(item_group, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, gettext("Item created successfully."))
        |> redirect(to: ~p"/admin/items/#{item}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, item_group.event, "new.html",
          changeset: changeset,
          item_group: item_group
        )
    end
  end

  def show(conn, %{"id" => id}) do
    item =
      id
      |> Inventory.get_item!()
      |> Repo.preload(:event)

    render_with_navigation(conn, item.event, "show.html",
      item: item,
      supply: Inventory.get_item_supply(item),
      consumption: Inventory.get_item_consumption(item),
      stock: Inventory.get_item_stock(item),
      relocations: Inventory.get_item_relocations(item)
    )
  end

  def edit(conn, %{"id" => id}) do
    item =
      id
      |> Inventory.get_item!()
      |> Repo.preload(:event)

    changeset = Inventory.change_item(item)

    render_with_navigation(conn, item.event, "edit.html", item: item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item =
      id
      |> Inventory.get_item!()
      |> Repo.preload(:event)

    case Inventory.update_item(item, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, gettext("Item updated successfully."))
        |> redirect(to: ~p"/admin/items/#{item}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, item.event, "edit.html", item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    %{item_group_id: item_group_id} = item = Inventory.get_item!(id)
    {:ok, _item} = Inventory.delete_item(item)

    conn
    |> put_flash(:info, gettext("Item deleted successfully."))
    |> redirect(to: ~p"/admin/item_groups/#{item_group_id}/items")
  end
end

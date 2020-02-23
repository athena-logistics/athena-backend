defmodule AthenaWeb.Admin.ItemController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.Item

  def index(conn, %{"item_group" => item_group}) do
    item_group = Inventory.get_item_group!(item_group)
    items = Inventory.list_items(item_group)

    render(conn, "index.html", items: items, item_group: item_group)
  end

  def new(conn, %{"item_group" => item_group}) do
    item_group = Inventory.get_item_group!(item_group)
    changeset = Inventory.change_item(%Item{})

    render(conn, "new.html", changeset: changeset, item_group: item_group)
  end

  def create(conn, %{"item" => item_params, "item_group" => item_group}) do
    item_group = Inventory.get_item_group!(item_group)

    case Inventory.create_item(item_group, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: Routes.item_path(conn, :show, item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, item_group: item_group)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Inventory.get_item!(id)

    render(conn, "show.html",
      item: item,
      supply: Inventory.get_item_supply(item),
      consumption: Inventory.get_item_consumption(item),
      stock: Inventory.get_item_stock(item),
      relocations: Inventory.get_item_relocations(item)
    )
  end

  def edit(conn, %{"id" => id}) do
    item = Inventory.get_item!(id)
    changeset = Inventory.change_item(item)

    render(conn, "edit.html", item: item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Inventory.get_item!(id)

    case Inventory.update_item(item, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item updated successfully.")
        |> redirect(to: Routes.item_path(conn, :show, item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    %{item_group_id: item_group_id} = item = Inventory.get_item!(id)
    {:ok, _item} = Inventory.delete_item(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: Routes.item_path(conn, :index, item_group_id))
  end
end

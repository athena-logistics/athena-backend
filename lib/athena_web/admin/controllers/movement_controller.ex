defmodule AthenaWeb.Admin.MovementController do
  use AthenaWeb, :controller

  alias Athena.Inventory
  alias Athena.Inventory.Movement

  def index(conn, %{"item" => item}) do
    item =
      item
      |> Inventory.get_item!()
      |> Repo.preload(:event)

    movements =
      item
      |> Inventory.list_movements()
      |> Repo.preload([:source_location, :destination_location])

    render_with_navigation(conn, item.event, "index.html", movements: movements, item: item)
  end

  def new(conn, %{"item" => item}) do
    item =
      item
      |> Inventory.get_item!()
      |> Repo.preload(:event)

    locations = Inventory.list_locations(item.event)
    changeset = Inventory.change_movement(%Movement{})

    render_with_navigation(conn, item.event, "new.html",
      changeset: changeset,
      item: item,
      locations: locations
    )
  end

  def create(conn, %{"movement" => movement_params, "item" => item}) do
    item =
      item
      |> Inventory.get_item!()
      |> Repo.preload(:event)

    locations = Inventory.list_locations(item.event)

    case Inventory.create_movement(item, movement_params) do
      {:ok, movement} ->
        conn
        |> put_flash(:info, gettext("Movement created successfully."))
        |> redirect(to: ~p"/admin/movements/#{movement}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, item.event, "new.html",
          changeset: changeset,
          item: item,
          locations: locations
        )
    end
  end

  def show(conn, %{"id" => id}) do
    movement =
      id
      |> Inventory.get_movement!()
      |> Repo.preload([:item, :item_group, :source_location, :destination_location, :event])

    render_with_navigation(conn, movement.event, "show.html", movement: movement)
  end

  def edit(conn, %{"id" => id}) do
    movement =
      id
      |> Inventory.get_movement!()
      |> Repo.preload(:event)

    locations = Inventory.list_locations(movement.event)
    changeset = Inventory.change_movement(movement)

    render_with_navigation(conn, movement.event, "edit.html",
      movement: movement,
      changeset: changeset,
      locations: locations
    )
  end

  def update(conn, %{"id" => id, "movement" => movement_params}) do
    movement =
      id
      |> Inventory.get_movement!()
      |> Repo.preload(:event)

    locations = Inventory.list_locations(movement.event)

    case Inventory.update_movement(movement, movement_params) do
      {:ok, movement} ->
        conn
        |> put_flash(:info, gettext("Movement updated successfully."))
        |> redirect(to: ~p"/admin/movements/#{movement}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render_with_navigation(conn, movement.event, "edit.html",
          movement: movement,
          changeset: changeset,
          locations: locations
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    %{item_id: item_id} = movement = Inventory.get_movement!(id)
    {:ok, _movement} = Inventory.delete_movement(movement)

    conn
    |> put_flash(:info, gettext("Movement deleted successfully."))
    |> redirect(to: ~p"/admin/items/#{item_id}/movements")
  end
end

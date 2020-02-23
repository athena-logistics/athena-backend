defmodule AthenaWeb.Frontend.LocationController do
  use AthenaWeb, :controller

  alias Athena.Inventory

  def show(conn, %{"id" => id}) do
    location =
      id
      |> Inventory.get_location!()
      |> Repo.preload(:event)

    item_groups =
      location
      |> Inventory.list_relevant_item_groups()
      |> Enum.map(&{&1, Inventory.list_relevant_items(location, &1)})

    render(conn, "show.html", location: location, item_groups: item_groups)
  end
end

defmodule AthenaWeb.Frontend.MovementLive do
  @moduledoc false

  use AthenaWeb, :live
  use Ecto.Schema

  import Ecto.Changeset

  alias Athena.Inventory
  alias Athena.Inventory.Item
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement
  alias Athena.Inventory.StockEntry
  alias Ecto.Changeset
  alias Phoenix.PubSub

  @foreign_key_type :binary_id
  embedded_schema do
    belongs_to :source_location, Location
    belongs_to :destination_location, Location

    embeds_many :movements, Movement
  end

  @impl Phoenix.LiveView
  def mount(%{"event" => event_id}, _session, socket) do
    PubSub.subscribe(Athena.PubSub, "location:event:#{event_id}")
    PubSub.subscribe(Athena.PubSub, "movement:event:#{event_id}")

    {:ok,
     socket
     |> update(event_id)
     |> assign(
       changeset:
         changeset(socket.assigns.live_action, %{
           id: Ecto.UUID.generate(),
           movements: [%{id: Ecto.UUID.generate(), amount: 1}]
         })
     )}
  end

  @impl Phoenix.LiveView
  def handle_info({action, %type{}, _extra}, socket)
      when action in [:created, :updated, :deleted] and
             type in [
               Athena.Inventory.Location,
               Athena.Inventory.Movement
             ] do
    {:noreply, update(socket, socket.assigns.event.id)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"movement_live" => movements}, socket),
    do: {:noreply, assign(socket, changeset: changeset(socket.assigns.live_action, movements))}

  def handle_event("save", %{"movement_live" => movements}, socket) do
    case changeset(socket.assigns.live_action, movements) do
      %Changeset{valid?: true} = changeset ->
        {:ok, _saved} =
          changeset
          |> get_change(:movements, get_field(changeset, :movements, []))
          |> Enum.map(&cast(&1, %{}, []))
          |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.insert(&2, make_ref(), &1))
          |> Athena.Repo.transaction()

        {:noreply,
         socket
         |> put_flash(:info, gettext("Movement created successfully."))
         |> push_redirect(
           to:
             Routes.frontend_logistics_live_path(
               socket,
               AthenaWeb.Frontend.LogisticsLive,
               socket.assigns.event
             )
         )}

      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, changeset: %Changeset{changeset | action: :insert})}
    end
  end

  def handle_event("add_movement", _params, socket) do
    current_movements =
      get_change(
        socket.assigns.changeset,
        :movements,
        get_field(socket.assigns.changeset, :movements, [])
      )

    changeset =
      put_embed(
        socket.assigns.changeset,
        :movements,
        current_movements ++ [%Movement{id: Ecto.UUID.generate(), amount: 1}]
      )

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_movement", %{"id" => id}, socket) do
    current_movements =
      get_change(
        socket.assigns.changeset,
        :movements,
        get_field(socket.assigns.changeset, :movements, [])
      )

    current_movements =
      Enum.reject(current_movements, fn
        %Changeset{} = changeset -> fetch_field!(changeset, :id) == id
        %Movement{id: ^id} -> true
        %Movement{} -> false
      end)

    changeset = put_embed(socket.assigns.changeset, :movements, current_movements)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("advance_amount", %{"id" => movement_id, "delta" => delta}, socket) do
    movements =
      socket.assigns.changeset
      |> get_change(
        :movements,
        get_field(socket.assigns.changeset, :movements, [])
      )
      |> Enum.map(&movement_changeset(&1, %{}))
      |> Enum.map(fn changeset ->
        if Changeset.fetch_field!(changeset, :id) == movement_id do
          Changeset.put_change(
            changeset,
            :amount,
            Changeset.fetch_field!(changeset, :amount) + String.to_integer(delta)
          )
        else
          changeset
        end
      end)

    changeset = put_embed(socket.assigns.changeset, :movements, movements)

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp update(socket, event_id) do
    event =
      event_id
      |> Inventory.get_event!()
      |> Repo.preload(locations: [stock_entries: [item: []]], item_groups: [items: []])

    socket
    |> assign(event: event)
    |> assign_navigation(event)
  end

  defp changeset(movements \\ %__MODULE__{movements: []}, action, attrs) do
    movements
    |> cast(attrs, [:source_location_id, :destination_location_id])
    |> cast_embed(:movements,
      required: true,
      with: &movement_changeset/2
    )
    |> validate_action_constraints(action)
    |> patch_root_fields()
  end

  defp movement_changeset(movement, attrs),
    do:
      Movement.changeset(movement, attrs, %{
        location_required: false,
        validate_amount_positive: true
      })

  defp validate_action_constraints(changeset, action)

  defp validate_action_constraints(changeset, :supply),
    do: validate_required(changeset, [:destination_location_id])

  defp validate_action_constraints(changeset, :relocate),
    do: validate_required(changeset, [:source_location_id, :destination_location_id])

  def patch_root_fields(changeset) do
    movements =
      changeset
      |> get_change(:movements, get_field(changeset, :movements, []))
      |> Enum.map(
        &cast(
          &1,
          %{
            source_location_id: fetch_field!(changeset, :source_location_id),
            destination_location_id: fetch_field!(changeset, :destination_location_id)
          },
          [:source_location_id, :destination_location_id]
        )
      )

    put_embed(changeset, :movements, movements)
  end

  defp get_stock(event, changeset, movement_changeset) do
    {
      _get_stock(
        event,
        Changeset.fetch_field!(changeset, :source_location_id),
        Changeset.fetch_field!(movement_changeset, :item_id)
      ),
      _get_stock(
        event,
        Changeset.fetch_field!(changeset, :destination_location_id),
        Changeset.fetch_field!(movement_changeset, :item_id)
      )
    }
  end

  defp _get_stock(event, location_id, item_id)
  defp _get_stock(_event, _location_id, nil), do: nil
  defp _get_stock(_event, nil, _item_id), do: nil

  defp _get_stock(event, location_id, item_id) do
    with %Location{stock_entries: stock_entries, id: ^location_id} <-
           Enum.find(event.locations, &match?(%Location{id: ^location_id}, &1)),
         %StockEntry{item_id: ^item_id, stock: stock} <-
           Enum.find(stock_entries, &match?(%StockEntry{item_id: ^item_id}, &1)) do
      stock
    end
  end
end

defmodule AthenaWeb.Frontend.MovementLive do
  @moduledoc false

  use AthenaWeb, :live
  use Ecto.Schema

  import Ecto.Changeset

  alias Athena.Inventory
  alias Athena.Inventory.Location
  alias Athena.Inventory.Movement
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
     |> assign(changeset: changeset(socket.assigns.live_action, %{id: Ecto.UUID.generate()}))}
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
        current_movements ++ [%Movement{id: Ecto.UUID.generate()}]
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
      with: {Movement, :changeset, [%{location_required: false, validate_amount_positive: true}]}
    )
    |> validate_action_constraints(action)
    |> patch_root_fields()
  end

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
end

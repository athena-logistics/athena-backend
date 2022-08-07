defmodule AthenaWeb.Schema.Movement.Resolver do
  @moduledoc false

  use AthenaWeb, :resolver

  alias Athena.Inventory

  @spec supply(parent :: any(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def supply(
        _parent,
        %{item_id: item_id, amount: amount, location_id: location_id},
        _resolution
      ) do
    item_id
    |> Inventory.get_item!()
    |> Inventory.create_movement(%{amount: amount, destination_location_id: location_id})
    |> add_details_to_amount_error()
    |> changeset_result()
  end

  @spec consume(parent :: any(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def consume(
        _parent,
        %{item_id: item_id, amount: amount, location_id: location_id},
        _resolution
      ) do
    item_id
    |> Inventory.get_item!()
    |> Inventory.create_movement(%{amount: amount, source_location_id: location_id})
    |> add_details_to_amount_error()
    |> changeset_result()
  end

  @spec relocate(parent :: any(), args :: map(), resolution :: Absinthe.Resolution.t()) ::
          AthenaWeb.resolver_result()
  def relocate(
        _parent,
        %{item_id: item_id} = args,
        _resolution
      ) do
    item_id
    |> Inventory.get_item!()
    |> Inventory.create_movement(args)
    |> add_details_to_amount_error()
    |> changeset_result()
  end

  defp add_details_to_amount_error(result)

  defp add_details_to_amount_error({:error, %Ecto.Changeset{errors: errors} = changeset}) do
    {:error,
     %Ecto.Changeset{
       changeset
       | errors:
           Enum.map(errors, fn
             {:amount,
              {message, [constraint: :check, constraint_name: "source_stock_negative"] = opts}} ->
               {:amount, {message, [{:code, :source_stock_negative} | opts]}}

             {:amount,
              {message,
               [constraint: :check, constraint_name: "destination_stock_negative"] = opts}} ->
               {:amount, {message, [{:code, :destination_stock_negative} | opts]}}

             other ->
               other
           end)
     }}
  end

  defp add_details_to_amount_error(result), do: result
end

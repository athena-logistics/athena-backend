defmodule Athena.ChangesetHelper do
  @moduledoc false

  import Ecto.Changeset

  alias Ecto.Changeset

  @spec fill_uuid(changeset :: Changeset.t()) :: Changeset.t()
  def fill_uuid(changeset) do
    changeset
    |> fetch_field!(:id)
    |> case do
      nil -> put_change(changeset, :id, Ecto.UUID.generate())
      id when is_binary(id) -> changeset
    end
  end

  @spec validate_one_required(changeset :: Changeset.t(), fields :: [atom()]) :: Changeset.t()
  def validate_one_required(changeset, [first_field | _] = fields) do
    fields
    |> Enum.map(&get_field(changeset, &1))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> add_error(changeset, first_field, "at least field is required", fields: fields)
      [_ | _] -> changeset
    end
  end
end

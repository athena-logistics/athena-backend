defmodule Athena do
  @moduledoc """
  Athena keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def model do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      @type association(type) :: Ecto.Association.NotLoaded.t() | type
    end
  end

  def migration do
    quote do
      use Ecto.Migration
    end
  end

  @doc """
  When used, dispatch to the appropriate model/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

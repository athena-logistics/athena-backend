defmodule AthenaWeb.Schema.Dataloader do
  @moduledoc """
  Absinthe Dataloader
  """

  alias Athena.Repo

  @spec data :: Dataloader.Ecto.t()
  def data, do: Dataloader.Ecto.new(Repo)
end

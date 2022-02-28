defmodule Athena.Repo.Migrations.CreateItemGroups do
  use Athena, :migration

  def change do
    create table(:item_groups) do
      add :event_id, references(:events, on_delete: :delete_all), null: false

      add :name, :string

      timestamps()
    end
  end
end

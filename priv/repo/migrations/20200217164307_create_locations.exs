defmodule Athena.Repo.Migrations.CreateLocations do
  use Athena, :migration

  def change do
    create table(:locations) do
      add :event_id, references(:events, on_delete: :delete_all), null: false

      add :name, :string

      timestamps()
    end
  end
end

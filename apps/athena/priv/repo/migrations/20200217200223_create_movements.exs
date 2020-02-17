defmodule Athena.Repo.Migrations.CreateMovements do
  use Athena, :migration

  def change do
    create table(:movements) do
      add :amount, :integer

      add :item_id, references(:items, on_delete: :delete_all), null: false

      add :source_location_id, references(:locations, on_delete: :delete_all), null: true
      add :destination_location_id, references(:locations, on_delete: :delete_all), null: true

      timestamps()
    end
  end
end

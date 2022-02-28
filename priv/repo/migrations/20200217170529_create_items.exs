defmodule Athena.Repo.Migrations.CreateItems do
  use Athena, :migration

  def change do
    create table(:items) do
      add :item_group_id, references(:item_groups, on_delete: :delete_all), null: false

      add :name, :string

      timestamps()
    end
  end
end

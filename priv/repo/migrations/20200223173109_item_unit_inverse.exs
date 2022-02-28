defmodule Athena.Repo.Migrations.ItemUnitInverse do
  use Athena, :migration

  def change do
    alter table(:items) do
      add :unit, :string, null: false
      add :inverse, :boolean, null: false, default: false
    end
  end
end

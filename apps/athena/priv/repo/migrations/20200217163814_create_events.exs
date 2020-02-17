defmodule Athena.Repo.Migrations.CreateEvents do
  use Athena, :migration

  def change do
    create table(:events) do
      add :name, :string

      timestamps()
    end
  end
end

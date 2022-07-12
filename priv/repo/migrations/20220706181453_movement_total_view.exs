defmodule Athena.Repo.Migrations.MovementTotalView do
  use Athena, :migration

  def change do
    execute(
      """
      CREATE
        VIEW location_totals
        AS
          WITH
            location_movements AS (
              SELECT
                amount,
                item_id,
                destination_location_id AS location_id,
                inserted_at
                FROM movements
                WHERE destination_location_id IS NOT NULL
              UNION ALL
                SELECT
                  0 - amount AS amount,
                  item_id,
                  source_location_id AS location_id,
                  inserted_at
                  FROM movements
                  WHERE source_location_id IS NOT NULL
            )
          SELECT
            locations.id AS location_id,
            location_movements.item_id AS item_id,
            SUM(location_movements.amount)
              OVER (
                PARTITION BY
                  locations.id,
                  location_movements.item_id
                ORDER BY location_movements.inserted_at
              )
              AS amount,
              location_movements.inserted_at
            FROM locations
            JOIN
              location_movements
              ON location_movements.location_id = locations.id
      """,
      """
      DROP
        VIEW location_totals
      """
    )

    execute(
      """
      CREATE
        VIEW event_totals
        AS
          WITH
            location_movements AS (
              SELECT
                amount,
                item_id,
                destination_location_id AS location_id,
                inserted_at
                FROM movements
                WHERE destination_location_id IS NOT NULL
              UNION ALL
                SELECT
                  0 - amount AS amount,
                  item_id,
                  source_location_id AS location_id,
                  inserted_at
                  FROM movements
                  WHERE source_location_id IS NOT NULL
            )
          SELECT
            locations.id AS location_id,
            location_movements.item_id AS item_id,
            SUM(location_movements.amount)
              OVER (
                PARTITION BY
                  locations.event_id,
                  location_movements.item_id
                ORDER BY location_movements.inserted_at
              )
              AS amount,
              location_movements.inserted_at
            FROM locations
            JOIN
              location_movements
              ON location_movements.location_id = locations.id
      """,
      """
      DROP
        VIEW event_totals
      """
    )
  end
end

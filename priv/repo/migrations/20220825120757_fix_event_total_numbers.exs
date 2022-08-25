defmodule Athena.Repo.Migrations.FixEventTotalNumbers do
  use Athena, :migration

  def change do
    execute(
      """
      CREATE
        FUNCTION DATE_CEILING(_timestamp TIMESTAMPTZ, _round_seconds INT)
        RETURNS TIMESTAMPTZ
        LANGUAGE sql
        STABLE
        AS 'SELECT TO_TIMESTAMP(CEIL(EXTRACT(EPOCH FROM $1) / $2) * $2)'
      """,
      """
      DROP
        FUNCTION DATE_CEILING(_timestamp TIMESTAMPTZ, _round_seconds INT)
      """
    )

    execute(
      """
      CREATE
        FUNCTION DATE_CEILING(_timestamp TIMESTAMPTZ, _interval INTERVAL)
        RETURNS TIMESTAMPTZ
        LANGUAGE sql
        STABLE
        AS 'SELECT DATE_CEILING($1, EXTRACT(EPOCH FROM $2)::INT)';
      """,
      """
      DROP
        FUNCTION DATE_CEILING(_timestamp TIMESTAMPTZ, _interval INTERVAL)
      """
    )

    execute(
      """
      DROP
        VIEW event_totals
      """,
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
      """
    )

    execute(
      """
      DROP
        VIEW location_totals
      """,
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
            ),
            location_grouped_movements AS (
              SELECT
                SUM(location_movements.amount)::INT AS amount,
                location_movements.item_id,
                location_movements.location_id,
                DATE_CEILING(location_movements.inserted_at, INTERVAL '5 minutes') AS inserted_at
                FROM location_movements
                GROUP BY
                  location_movements.item_id,
                  location_movements.location_id,
                  DATE_CEILING(location_movements.inserted_at, INTERVAL '5 minutes')
            )
          SELECT
            location_grouped_movements.item_id AS item_id,
            locations.event_id AS event_id,
            SUM(location_grouped_movements.amount)
              OVER (
                PARTITION BY
                  locations.event_id,
                  location_grouped_movements.item_id
                ORDER BY location_grouped_movements.inserted_at
              )::INT
              AS amount,
              location_grouped_movements.inserted_at
            FROM locations
            JOIN
              location_grouped_movements
              ON location_grouped_movements.location_id = locations.id
      """,
      """
      DROP
        VIEW event_totals
      """
    )

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
            ),
            location_grouped_movements AS (
              SELECT
                SUM(location_movements.amount)::INT AS amount,
                location_movements.item_id,
                location_movements.location_id,
                DATE_CEILING(location_movements.inserted_at, INTERVAL '5 minutes') AS inserted_at
                FROM location_movements
                GROUP BY
                  location_movements.item_id,
                  location_movements.location_id,
                  DATE_CEILING(location_movements.inserted_at, INTERVAL '5 minutes')
            )
          SELECT
            locations.id AS location_id,
            location_grouped_movements.item_id AS item_id,
            locations.event_id,
            SUM(location_grouped_movements.amount)
              OVER (
                PARTITION BY
                  locations.id,
                  location_grouped_movements.item_id
                ORDER BY location_grouped_movements.inserted_at
              )
              AS amount,
              location_grouped_movements.inserted_at
            FROM locations
            JOIN
              location_grouped_movements
              ON location_grouped_movements.location_id = locations.id
      """,
      """
      DROP
        VIEW location_totals
      """
    )
  end
end

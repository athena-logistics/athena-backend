defmodule Athena.Repo.Migrations.StatsTimeseries do
  use Athena, :migration

  def change do
    # Drop old Views

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
      """
    )

    # Create New Views

    execute(
      """
      CREATE
        VIEW location_movements
        AS
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
      """,
      """
      DROP
        VIEW location_movements
      """
    )

    execute(
      """
      CREATE
        VIEW event_totals
        AS
          WITH
            cleaned_movements AS (
              SELECT
                item_id,
                SUM(amount)::int AS delta,
                DATE_CEILING(inserted_at, INTERVAL '15 minutes') AS date
              FROM location_movements
              GROUP BY
                item_id,
                DATE_CEILING(inserted_at, INTERVAL '15 minutes')
            ),
            event_dates AS (
              SELECT
                item_groups.event_id AS event_id,
                MIN(cleaned_movements.date) AS min,
                MAX(cleaned_movements.date) AS max
              FROM cleaned_movements
              JOIN
                items
                ON items.id = cleaned_movements.item_id
              JOIN
                item_groups
                ON items.item_group_id = item_groups.id
              GROUP BY
                item_groups.event_id
            ),
            timelined_movements AS (
              SELECT
                items.id AS item_id,
                item_groups.event_id AS event_id,
                time_series_date AS date,
                COALESCE(cleaned_movements.delta, 0)::int AS delta
              FROM item_groups
              JOIN
                items
                ON items.item_group_id = item_groups.id
              JOIN
                event_dates
                ON event_dates.event_id = item_groups.event_id
              CROSS JOIN
                GENERATE_SERIES(event_dates.min, event_dates.max, INTERVAL '15 minutes')
                AS time_series_date
              LEFT JOIN
                cleaned_movements
                ON
                  cleaned_movements.item_id = items.id AND
                  cleaned_movements.date = time_series_date
            )
          SELECT
            timelined_movements.event_id AS event_id,
            timelined_movements.item_id AS item_id,
            timelined_movements.delta AS delta,
            SUM(timelined_movements.delta) OVER (
              PARTITION BY timelined_movements.item_id
              ORDER BY timelined_movements.date
            ) AS amount,
            timelined_movements.date
          FROM timelined_movements
          ORDER BY
            timelined_movements.date,
            timelined_movements.event_id,
            timelined_movements.item_id
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
            cleaned_movements AS (
              SELECT
                item_id,
                location_id,
                SUM(amount)::int AS delta,
                DATE_CEILING(inserted_at, INTERVAL '15 minutes') AS date
              FROM location_movements
              GROUP BY
                item_id,
                location_id,
                DATE_CEILING(inserted_at, INTERVAL '15 minutes')
            ),
            event_dates AS (
              SELECT
                item_groups.event_id AS event_id,
                MIN(cleaned_movements.date) AS min,
                MAX(cleaned_movements.date) AS max
              FROM cleaned_movements
              JOIN
                items
                ON items.id = cleaned_movements.item_id
              JOIN
                item_groups
                ON items.item_group_id = item_groups.id
              GROUP BY
                item_groups.event_id
            ),
            existing_location_item_combinations AS (
              SELECT
                DISTINCT
                item_id,
                location_id
              FROM cleaned_movements
            ),
            timelined_movements AS (
              SELECT
                items.id AS item_id,
                item_groups.event_id AS event_id,
                locations.id AS location_id,
                time_series_date AS date,
                COALESCE(cleaned_movements.delta, 0)::int AS delta
                FROM item_groups
                JOIN locations ON locations.event_id = item_groups.event_id
                JOIN
                  items
                  ON items.item_group_id = item_groups.id
                JOIN
                  event_dates
                  ON event_dates.event_id = item_groups.event_id
                JOIN
                  existing_location_item_combinations
                  ON
                    existing_location_item_combinations.location_id = locations.id AND
                    existing_location_item_combinations.item_id = items.id
                CROSS JOIN
                  GENERATE_SERIES(event_dates.min, event_dates.max, INTERVAL '15 minutes')
                  AS time_series_date
                LEFT JOIN
                  cleaned_movements
                  ON
                    cleaned_movements.item_id = items.id AND
                    cleaned_movements.location_id = locations.id AND
                    cleaned_movements.date = time_series_date
            )
          SELECT
            timelined_movements.event_id AS event_id,
            timelined_movements.location_id AS location_id,
            timelined_movements.item_id AS item_id,
            timelined_movements.delta AS delta,
            SUM(timelined_movements.delta) OVER (
              PARTITION BY timelined_movements.item_id, timelined_movements.location_id
              ORDER BY timelined_movements.date
            ) AS amount,
            timelined_movements.date
          FROM timelined_movements
          ORDER BY
            timelined_movements.date,
            timelined_movements.event_id,
            timelined_movements.location_id,
            timelined_movements.item_id
      """,
      """
      DROP
        VIEW location_totals
      """
    )
  end
end

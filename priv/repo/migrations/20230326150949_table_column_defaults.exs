defmodule Athena.Repo.Migrations.TableColumnDefaults do
  use Athena, :migration

  def up do
    for view_name <- [
          :stock_entries,
          :location_totals,
          :event_order_overview,
          :event_totals,
          :location_movements
        ] do
      execute("""
      DROP
        VIEW #{view_name}
      """)
    end

    for table_name <- [:events, :locations, :item_groups, :items, :stock_expectations, :movements] do
      alter table(table_name) do
        modify :id, :binary_id, null: false, default: fragment("GEN_RANDOM_UUID()")
        modify :inserted_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
        modify :updated_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
      end
    end

    execute("""
    CREATE
      VIEW stock_entries
      AS
        WITH
          supply_movements AS (
            SELECT
              item_id,
              destination_location_id AS location_id,
              SUM(amount) AS amount
              FROM movements
              WHERE source_location_id IS NULL
              GROUP BY
                item_id,
                destination_location_id
          ),
          consumption_movements AS (
            SELECT
              item_id,
              source_location_id AS location_id,
              SUM(amount) AS amount
              FROM movements
              WHERE destination_location_id IS NULL
              GROUP BY
                item_id,
                source_location_id
          ),
          recipient_movements AS (
            SELECT
              item_id,
              destination_location_id AS location_id,
              SUM(amount) AS amount
              FROM movements
              WHERE
                source_location_id IS NOT NULL AND
                destination_location_id IS NOT NULL
              GROUP BY
                item_id,
                destination_location_id
          ),
          sender_movements AS (
            SELECT
              item_id,
              source_location_id AS location_id,
              SUM(amount) AS amount
              FROM movements
              WHERE
                source_location_id IS NOT NULL AND
                destination_location_id IS NOT NULL
              GROUP BY
                item_id,
                source_location_id
          ),
          movement_sums AS (
            SELECT
              items.id AS item_id,
              locations.id AS location_id,
              COALESCE(SUM(supply_movements.amount), 0)::INT AS supply,
              COALESCE(SUM(consumption_movements.amount), 0)::INT AS consumption,
              COALESCE(SUM(recipient_movements.amount), 0)::INT AS movement_in,
              COALESCE(SUM(sender_movements.amount), 0)::INT AS movement_out,
              COALESCE(SUM(supply_movements.amount), 0)::INT
                - COALESCE(SUM(consumption_movements.amount), 0)::INT
                + COALESCE(SUM(recipient_movements.amount), 0)::INT
                - COALESCE(SUM(sender_movements.amount), 0)::INT
                AS stock
              FROM items
              JOIN
                item_groups
                ON items.item_group_id = item_groups.id
              JOIN
                locations
                ON locations.event_id = item_groups.event_id
              LEFT JOIN
                supply_movements
                ON
                  supply_movements.item_id = items.id AND
                  supply_movements.location_id = locations.id
              LEFT JOIN
                consumption_movements
                ON
                  consumption_movements.item_id = items.id AND
                  consumption_movements.location_id = locations.id
              LEFT JOIN
                recipient_movements
                ON
                  recipient_movements.item_id = items.id AND
                  recipient_movements.location_id = locations.id
              LEFT JOIN
                sender_movements
                ON
                  sender_movements.item_id = items.id AND
                  sender_movements.location_id = locations.id
              WHERE
                supply_movements IS NOT NULL OR
                consumption_movements IS NOT NULL OR
                recipient_movements IS NOT NULL OR
                sender_movements IS NOT NULL
              GROUP BY
                locations.id,
                item_groups.id,
                items.id
          )
      SELECT
        events.id AS event_id,
        item_groups.id AS item_group_id,
        items.id AS item_id,
        locations.id AS location_id,
        COALESCE(movement_sums.supply, 0) AS supply,
        COALESCE(movement_sums.consumption, 0) AS consumption,
        COALESCE(movement_sums.movement_in, 0) AS movement_in,
        COALESCE(movement_sums.movement_out, 0) AS movement_out,
        COALESCE(movement_sums.stock, 0) AS stock,
        CASE
          WHEN
            NOT items.inverse AND
            COALESCE(movement_sums.stock, 0) >= COALESCE(stock_expectations.warning_threshold, 0) THEN
            'normal'
          WHEN
            NOT items.inverse AND
            COALESCE(movement_sums.stock, 0) >= COALESCE(stock_expectations.important_threshold, 0) THEN
            'warning'
          WHEN
            NOT items.inverse THEN
            'important'
          WHEN
            items.inverse AND
            COALESCE(movement_sums.stock, 0) <= COALESCE(stock_expectations.warning_threshold) THEN
            'normal'
          WHEN
            items.inverse AND
            COALESCE(movement_sums.stock, 0) <= COALESCE(stock_expectations.important_threshold) THEN
            'warning'
          WHEN
            items.inverse THEN
            'important'
        END AS status,
        CASE
          WHEN items.inverse THEN
            GREATEST(COALESCE(movement_sums.stock, 0) - COALESCE(stock_expectations.warning_threshold, 0), 0)
          ELSE
            GREATEST(COALESCE(stock_expectations.warning_threshold, 0) - COALESCE(movement_sums.stock, 0), 0)
        END AS missing_count

        FROM events
        JOIN
          locations
          ON locations.event_id = events.id
        JOIN
          item_groups
          ON item_groups.event_id = events.id
        JOIN
          items
          ON items.item_group_id = item_groups.id
        LEFT JOIN
          stock_expectations
          ON
            stock_expectations.item_id = items.id AND
            stock_expectations.location_id = locations.id
        LEFT JOIN
          movement_sums
          ON
            movement_sums.item_id = items.id AND
            movement_sums.location_id = locations.id
        WHERE
          movement_sums IS NOT NULL OR
          stock_expectations IS NOT NULL OR
          items.inverse
    """)

    execute("""
    CREATE
      VIEW event_order_overview
      AS
        SELECT
          (DATE_TRUNC('day', movements.inserted_at))::date AS date,
          'consumption' AS type,
          locations.id AS location_id,
          item_groups.id AS item_group_id,
          items.id AS item_id,
          locations.event_id AS event_id,
          SUM(movements.amount) AS amount
          FROM items
          FULL OUTER JOIN
            movements
            ON movements.item_id = items.id
          FULL OUTER JOIN
            locations
            ON movements.source_location_id = locations.id
          FULL OUTER JOIN
            item_groups
            ON items.item_group_id = item_groups.id
          WHERE
            movements.destination_location_id IS NULL AND
            NOT items.inverse
          GROUP BY
            GROUPING SETS (
              (items.id, item_groups.id, locations.event_id, locations.id, DATE_TRUNC('day', movements.inserted_at)),
              (items.id, item_groups.id, locations.event_id, locations.id),
              (items.id, item_groups.id, locations.event_id, DATE_TRUNC('day', movements.inserted_at)),
              (items.id, item_groups.id, locations.event_id)
            )
        UNION ALL
        SELECT
          (DATE_TRUNC('day', movements.inserted_at))::date AS date,
          'supply' AS type,
          locations.id AS location_id,
          item_groups.id AS item_group_id,
          items.id AS item_id,
          locations.event_id AS event_id,
          SUM(movements.amount) AS amount
          FROM items
          FULL OUTER JOIN
            movements
            ON movements.item_id = items.id
          FULL OUTER JOIN
            locations
            ON movements.destination_location_id = locations.id
          FULL OUTER JOIN
            item_groups
            ON items.item_group_id = item_groups.id
          WHERE
            movements.source_location_id IS NULL AND
            NOT items.inverse
          GROUP BY
            GROUPING SETS (
              (items.id, item_groups.id, locations.event_id, locations.id, DATE_TRUNC('day', movements.inserted_at)),
              (items.id, item_groups.id, locations.event_id, locations.id),
              (items.id, item_groups.id, locations.event_id, DATE_TRUNC('day', movements.inserted_at)),
              (items.id, item_groups.id, locations.event_id)
            )
    """)

    execute("""
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
    """)

    execute("""
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
    """)

    execute("""
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
    """)
  end
end

defmodule Athena.Repo.Migrations.AddStockExpectations do
  use Athena, :migration

  def change do
    create table(:stock_expectations) do
      add :item_id, references(:items, on_delete: :delete_all), null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: true
      add :warning_threshold, :integer, null: false
      add :important_threshold, :integer, null: false

      timestamps()
    end

    create unique_index(:stock_expectations, [:item_id, :location_id])

    execute(
      """
      DROP
        VIEW stock_entries;
      """,
      """
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
            )
        SELECT
          events.id AS event_id,
          item_groups.id AS item_group_id,
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
          GROUP BY
            events.id,
            locations.id,
            item_groups.id,
            items.id
      """
    )

    execute(
      """
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
      """,
      """
      DROP
        VIEW stock_entries;
      """
    )
  end
end

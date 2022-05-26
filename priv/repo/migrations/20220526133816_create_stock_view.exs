defmodule Athena.Repo.Migrations.CreateStockView do
  use Athena, :migration

  def change do
    create index(:movements, [:item_id, :source_location_id, :destination_location_id])

    execute(
      """
      CREATE
        VIEW stock_entries
        AS
          SELECT
            events.id AS event_id,
            item_groups.id AS item_group_id,
            items.id AS item_id,
            locations.id AS location_id,
            COALESCE(SUM(supply_movements.amount), 0) AS supply,
            COALESCE(SUM(consumption_movements.amount), 0) AS consumption,
            COALESCE(SUM(recipient_movements.amount), 0) AS movement_in,
            COALESCE(SUM(sender_movements.amount), 0) AS movement_out,
            COALESCE(SUM(supply_movements.amount), 0)
              - COALESCE(SUM(consumption_movements.amount), 0)
              + COALESCE(SUM(recipient_movements.amount), 0)
              - COALESCE(SUM(sender_movements.amount), 0)
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
            movements
            AS supply_movements
            ON
              supply_movements.item_id = items.id AND
              supply_movements.destination_location_id = locations.id AND
              supply_movements.source_location_id IS NULL
          LEFT JOIN
            movements
            AS consumption_movements
            ON
              consumption_movements.item_id = items.id AND
              consumption_movements.destination_location_id IS NULL AND
              consumption_movements.source_location_id = locations.id
          LEFT JOIN
            movements
            AS recipient_movements
            ON
              recipient_movements.item_id = items.id AND
              recipient_movements.destination_location_id = locations.id AND
              recipient_movements.source_location_id IS NOT NULL
          LEFT JOIN
            movements
            AS sender_movements
            ON
              sender_movements.item_id = items.id AND
              sender_movements.destination_location_id IS NOT NULL AND
              sender_movements.source_location_id = locations.id
          GROUP BY
            events.id,
            locations.id,
            item_groups.id,
            items.id
      """,
      """
      DROP
        VIEW stock_entries;
      """
    )
  end
end

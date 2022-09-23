defmodule Athena.Repo.Migrations.OrderOverviewFix do
  use Athena, :migration

  def change do
    execute(
      """
      DROP
        VIEW event_order_overview
      """,
      """
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
              item_groups.event_id = 'fb36ea15-9d65-4b09-9b87-40bdaf4c3254' AND
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
              item_groups.event_id = 'fb36ea15-9d65-4b09-9b87-40bdaf4c3254' AND
              movements.source_location_id IS NULL AND
              NOT items.inverse
            GROUP BY
              GROUPING SETS (
                (items.id, item_groups.id, locations.event_id, locations.id, DATE_TRUNC('day', movements.inserted_at)),
                (items.id, item_groups.id, locations.event_id, locations.id),
                (items.id, item_groups.id, locations.event_id, DATE_TRUNC('day', movements.inserted_at)),
                (items.id, item_groups.id, locations.event_id)
              )
      """
    )

    execute(
      """
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
      """,
      """
      DROP
        VIEW event_order_overview
      """
    )
  end
end

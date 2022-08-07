defmodule Athena.Repo.Migrations.MovementValidateNotNegative do
  use Athena, :migration

  def change do
    execute("""
    INSERT
      INTO movements
      (id, amount, item_id, source_location_id, inserted_at, updated_at)
      SELECT
          GEN_RANDOM_UUID(),
          stock,
          item_id,
          location_id,
          NOW(),
          NOW()
          FROM stock_entries
          WHERE stock < 0;
    """)

    execute(
      """
      CREATE
        FUNCTION movement_validate_not_negative()
        RETURNS TRIGGER
        AS $movement_validate_not_negative$
          BEGIN
            IF (
              NEW.source_location_id IS NOT NULL AND
              (
                SELECT
                  stock
                  FROM stock_entries
                  WHERE
                    location_id = NEW.source_location_id AND
                    item_id = NEW.item_id
              ) < 0
            ) THEN
              RAISE
                check_violation
                USING
                  MESSAGE = 'source_location_id has negative stock',
                  HINT = 'movements can only be made if the resulting stock is not negative',
                  CONSTRAINT = 'source_stock_negative',
                  COLUMN = 'amount',
                  TABLE = TG_TABLE_NAME,
                  SCHEMA = TG_TABLE_SCHEMA;
            END IF;
            IF (
              NEW.destination_location_id IS NOT NULL AND
              (
                SELECT
                  stock
                  FROM stock_entries
                  WHERE
                    location_id = NEW.destination_location_id AND
                    item_id = NEW.item_id
              ) < 0
            ) THEN
              RAISE
                check_violation
                USING
                  MESSAGE = 'destination_location_id has negative stock',
                  HINT = 'movements can only be made if the resulting stock is not negative',
                  CONSTRAINT = 'destination_stock_negative',
                  COLUMN = 'amount',
                  TABLE = TG_TABLE_NAME,
                  SCHEMA = TG_TABLE_SCHEMA;
            END IF;

            RETURN NEW;
          END;
        $movement_validate_not_negative$
        LANGUAGE plpgsql;
      """,
      """
      DROP
        FUNCTION movement_validate_not_negative();
      """
    )

    execute(
      """
      CREATE
        CONSTRAINT TRIGGER movement_validate_not_negative
        AFTER INSERT OR UPDATE
        ON movements
        FOR EACH ROW
        EXECUTE PROCEDURE movement_validate_not_negative();
      """,
      """
      DROP
        TRIGGER movement_validate_not_negative
        ON movements;
      """
    )
  end
end

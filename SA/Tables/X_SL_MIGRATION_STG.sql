CREATE TABLE sa.x_sl_migration_stg (
  objid NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE),
  sim VARCHAR2(100 BYTE),
  zip VARCHAR2(50 BYTE),
  brand_name VARCHAR2(100 BYTE),
  service_plan_id VARCHAR2(100 BYTE),
  billing_pgm_id VARCHAR2(100 BYTE),
  action_type VARCHAR2(50 BYTE) DEFAULT 'MIGRATION',
  source_system VARCHAR2(100 BYTE),
  voice VARCHAR2(100 BYTE),
  "TEXT" VARCHAR2(100 BYTE),
  "DATA" VARCHAR2(100 BYTE),
  status VARCHAR2(100 BYTE),
  retry_limit NUMBER,
  retry_count NUMBER,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT tf_x_x_sl_migration_stg_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_sl_migration_stg IS 'Staging migration table for SOA team';
COMMENT ON COLUMN sa.x_sl_migration_stg.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_sl_migration_stg.sim IS 'ESN';
COMMENT ON COLUMN sa.x_sl_migration_stg.zip IS 'Metering source voice,text,data';
COMMENT ON COLUMN sa.x_sl_migration_stg.brand_name IS 'Brand Name';
COMMENT ON COLUMN sa.x_sl_migration_stg.service_plan_id IS 'Service Plan id';
COMMENT ON COLUMN sa.x_sl_migration_stg.action_type IS ' action type default to migration ';
COMMENT ON COLUMN sa.x_sl_migration_stg.source_system IS 'source system';
COMMENT ON COLUMN sa.x_sl_migration_stg.status IS 'status';
COMMENT ON COLUMN sa.x_sl_migration_stg.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_sl_migration_stg.update_timestamp IS 'Last date when the record was last modified';
CREATE TABLE sa.x_reward_catalog (
  objid NUMBER NOT NULL,
  catalog_name VARCHAR2(50 CHAR),
  catalog_version VARCHAR2(10 CHAR),
  catalog_status VARCHAR2(30 CHAR),
  catalog_type VARCHAR2(30 CHAR),
  catalog_description VARCHAR2(255 CHAR),
  catalog_provider VARCHAR2(30 CHAR),
  start_date DATE,
  end_date DATE,
  insert_timestamp DATE DEFAULT sysdate NOT NULL,
  update_timestamp DATE DEFAULT sysdate NOT NULL,
  CONSTRAINT x_reward_catalog_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_reward_catalog IS 'Captures Reward Catalog';
COMMENT ON COLUMN sa.x_reward_catalog.objid IS 'Primary Key';
COMMENT ON COLUMN sa.x_reward_catalog.catalog_name IS 'Unique name given for the catalog. Values: LOYALTY_AUGEO';
COMMENT ON COLUMN sa.x_reward_catalog.catalog_version IS 'Version of the catalog. Values: 1';
COMMENT ON COLUMN sa.x_reward_catalog.catalog_status IS 'Status of the catalog. Values: ACTIVE, INACTIVE';
COMMENT ON COLUMN sa.x_reward_catalog.catalog_type IS 'Type of catalog: Values: LOYALTY_INT, LOYALTY_EXT';
COMMENT ON COLUMN sa.x_reward_catalog.catalog_description IS 'Additional description for the catalog';
COMMENT ON COLUMN sa.x_reward_catalog.catalog_provider IS 'Intended source of this offer/event. Values: AUGEO, TRACFONE';
COMMENT ON COLUMN sa.x_reward_catalog.start_date IS 'Start date of the catalog';
COMMENT ON COLUMN sa.x_reward_catalog.end_date IS 'End date of the catalog';
COMMENT ON COLUMN sa.x_reward_catalog.insert_timestamp IS 'Record creation time';
COMMENT ON COLUMN sa.x_reward_catalog.update_timestamp IS 'Record creation time';
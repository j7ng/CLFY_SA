CREATE TABLE sa.x_bogo_tsp_id (
  tsp_id NUMBER(25) NOT NULL,
  tsp_name VARCHAR2(240 BYTE),
  door_type VARCHAR2(30 BYTE),
  door_status VARCHAR2(30 BYTE),
  dealer_id VARCHAR2(30 BYTE),
  store_name VARCHAR2(240 BYTE),
  store_open_date DATE,
  store_closed_date DATE,
  tsp_added_date DATE,
  CONSTRAINT x_bogo_tsp_id_pk PRIMARY KEY (tsp_id) USING INDEX sa.pk1_x_bogo_tsp_id
);
COMMENT ON TABLE sa.x_bogo_tsp_id IS 'Table to store BOGO Branded Stores TSP ID';
COMMENT ON COLUMN sa.x_bogo_tsp_id.tsp_id IS 'Unique TSP ID';
COMMENT ON COLUMN sa.x_bogo_tsp_id.tsp_name IS 'TSP name';
COMMENT ON COLUMN sa.x_bogo_tsp_id.door_type IS 'Store door type';
COMMENT ON COLUMN sa.x_bogo_tsp_id.door_status IS 'Store door status';
COMMENT ON COLUMN sa.x_bogo_tsp_id.dealer_id IS 'Store dealer ID';
COMMENT ON COLUMN sa.x_bogo_tsp_id.store_name IS 'Store name';
COMMENT ON COLUMN sa.x_bogo_tsp_id.store_open_date IS 'Date store was opened';
COMMENT ON COLUMN sa.x_bogo_tsp_id.store_closed_date IS 'Date store was closed';
COMMENT ON COLUMN sa.x_bogo_tsp_id.tsp_added_date IS 'Date TSP record was added';
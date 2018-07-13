CREATE TABLE sa.table_x_part_request (
  objid NUMBER,
  dev NUMBER,
  x_action VARCHAR2(20 BYTE),
  x_repl_part_num VARCHAR2(30 BYTE),
  x_part_serial_no VARCHAR2(30 BYTE),
  x_ff_center VARCHAR2(30 BYTE),
  x_ship_date DATE,
  x_est_arrival_date DATE,
  x_received_date DATE,
  x_courier VARCHAR2(10 BYTE),
  x_shipping_method VARCHAR2(30 BYTE),
  x_tracking_no VARCHAR2(30 BYTE),
  x_status VARCHAR2(20 BYTE),
  x_part_num_domain VARCHAR2(40 BYTE),
  x_insert_date DATE,
  x_last_update_stamp DATE,
  x_service_level NUMBER,
  x_flag_migration VARCHAR2(5 BYTE),
  x_date_process DATE,
  x_problem VARCHAR2(100 BYTE),
  request2case NUMBER,
  x_quantity NUMBER
);
ALTER TABLE sa.table_x_part_request ADD SUPPLEMENTAL LOG GROUP dmtsora1046681647_0 (dev, objid, request2case, x_action, x_courier, x_date_process, x_est_arrival_date, x_ff_center, x_flag_migration, x_insert_date, x_last_update_stamp, x_part_num_domain, x_part_serial_no, x_problem, x_received_date, x_repl_part_num, x_service_level, x_shipping_method, x_ship_date, x_status, x_tracking_no) ALWAYS;
COMMENT ON TABLE sa.table_x_part_request IS 'Warehouse Integration Records';
COMMENT ON COLUMN sa.table_x_part_request.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_part_request.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_part_request.x_action IS 'SHIP,RETURN';
COMMENT ON COLUMN sa.table_x_part_request.x_repl_part_num IS 'TBD';
COMMENT ON COLUMN sa.table_x_part_request.x_part_serial_no IS 'Part Serial No: ESNs, IMEI, SIMs, etc.';
COMMENT ON COLUMN sa.table_x_part_request.x_ff_center IS 'Fulfillment Center Name';
COMMENT ON COLUMN sa.table_x_part_request.x_ship_date IS 'TBD';
COMMENT ON COLUMN sa.table_x_part_request.x_est_arrival_date IS 'Estimated Arrival Date';
COMMENT ON COLUMN sa.table_x_part_request.x_received_date IS 'RETURN received date';
COMMENT ON COLUMN sa.table_x_part_request.x_courier IS 'Courier ID';
COMMENT ON COLUMN sa.table_x_part_request.x_shipping_method IS 'Shipping Method';
COMMENT ON COLUMN sa.table_x_part_request.x_tracking_no IS 'Tracking Number';
COMMENT ON COLUMN sa.table_x_part_request.x_status IS 'Request Status';
COMMENT ON COLUMN sa.table_x_part_request.x_part_num_domain IS 'Part Number Domain';
COMMENT ON COLUMN sa.table_x_part_request.x_insert_date IS 'Record Creation Time';
COMMENT ON COLUMN sa.table_x_part_request.x_last_update_stamp IS 'Last Update Date Time';
COMMENT ON COLUMN sa.table_x_part_request.x_service_level IS 'Number of days for delivery';
COMMENT ON COLUMN sa.table_x_part_request.x_flag_migration IS 'Migration Status Between TOSS and OFS';
COMMENT ON COLUMN sa.table_x_part_request.x_date_process IS 'Date request was migrated to OFS';
COMMENT ON COLUMN sa.table_x_part_request.x_problem IS 'Comments about Migration Problems';
COMMENT ON COLUMN sa.table_x_part_request.request2case IS 'TBD';
COMMENT ON COLUMN sa.table_x_part_request.x_quantity IS 'Quantity for B2B Sales';
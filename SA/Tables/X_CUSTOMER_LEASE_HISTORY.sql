CREATE TABLE sa.x_customer_lease_history (
  objid NUMBER NOT NULL,
  esn_lease_obj_id NUMBER,
  change_dt TIMESTAMP,
  dml_action VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  lease_status VARCHAR2(20 BYTE),
  application_req_num VARCHAR2(100 BYTE),
  client_id VARCHAR2(80 BYTE),
  insert_dt TIMESTAMP,
  update_dt TIMESTAMP,
  CONSTRAINT pk_x_customer_lease_history PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.x_customer_lease_history.objid IS 'System defined sequence';
COMMENT ON COLUMN sa.x_customer_lease_history.esn_lease_obj_id IS 'ESN System defined sequence ';
COMMENT ON COLUMN sa.x_customer_lease_history.change_dt IS 'Change date and timestamp';
COMMENT ON COLUMN sa.x_customer_lease_history.dml_action IS 'Thype of change';
COMMENT ON COLUMN sa.x_customer_lease_history.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_customer_lease_history.lease_status IS 'Lease status';
COMMENT ON COLUMN sa.x_customer_lease_history.application_req_num IS 'Transaction Application Req Number';
COMMENT ON COLUMN sa.x_customer_lease_history.client_id IS 'Customer client identifier';
COMMENT ON COLUMN sa.x_customer_lease_history.insert_dt IS 'Date history record inserted';
COMMENT ON COLUMN sa.x_customer_lease_history.update_dt IS 'Date history record updated';
CREATE TABLE sa.x_device_mgmt (
  objid NUMBER NOT NULL,
  x_transaction_id NUMBER(10),
  x_min VARCHAR2(30 BYTE) NOT NULL,
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_current_rate_plan VARCHAR2(20 BYTE) NOT NULL,
  x_new_rate_plan VARCHAR2(20 BYTE),
  x_apn_update_flag VARCHAR2(1 BYTE),
  x_create_date DATE NOT NULL,
  x_last_update_date DATE NOT NULL,
  x_carrier_id NUMBER,
  PRIMARY KEY (objid),
  UNIQUE (x_transaction_id)
);
COMMENT ON TABLE sa.x_device_mgmt IS 'LIST OF PHONES WHICH WILL BE OR HAVE BEEN THROTTLED.';
COMMENT ON COLUMN sa.x_device_mgmt.objid IS 'INTERNAL UNIQUE IDENTIFIER FROM DEVICE_MGMT_SEQ';
COMMENT ON COLUMN sa.x_device_mgmt.x_transaction_id IS 'TRANSACTION_ID FROM GW1.IG_TRANSACTION RECORD';
COMMENT ON COLUMN sa.x_device_mgmt.x_min IS 'MIN OF PHONE TO BE THROTTLED';
COMMENT ON COLUMN sa.x_device_mgmt.x_esn IS 'ESN OF PHONE TO BE THROTTLED';
COMMENT ON COLUMN sa.x_device_mgmt.x_current_rate_plan IS 'CURRENT RATE PLAN OF ESN';
COMMENT ON COLUMN sa.x_device_mgmt.x_new_rate_plan IS 'NEW RATE PLAN OF ESN';
COMMENT ON COLUMN sa.x_device_mgmt.x_apn_update_flag IS '[NULL] - WAITING TO BE INSERTED INTO IG_TRANSACTION. [N] - RATE CHANGE IG_TRANSACTION SUCCESSFUL, WAITING TO BE THROTTLED. [Y] - ADDED TO THROTTLE LIST';
COMMENT ON COLUMN sa.x_device_mgmt.x_create_date IS 'TIMESTAMP RECORD WAS INSERTED';
COMMENT ON COLUMN sa.x_device_mgmt.x_last_update_date IS 'TIMESTAMP RECORD WAS UPDATED';
COMMENT ON COLUMN sa.x_device_mgmt.x_carrier_id IS 'CARRIER ID FROM TABLE_PART_INST';
CREATE TABLE sa.x_customer_lease (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  lease_status VARCHAR2(20 BYTE) NOT NULL,
  application_req_num VARCHAR2(100 BYTE) NOT NULL,
  client_id VARCHAR2(80 BYTE),
  insert_dt TIMESTAMP,
  update_dt TIMESTAMP,
  smp VARCHAR2(30 BYTE),
  account_group_id NUMBER(22),
  x_merchant_id VARCHAR2(30 BYTE),
  lease_scope VARCHAR2(100 BYTE),
  CONSTRAINT pk_esn_lease_status PRIMARY KEY (objid),
  CONSTRAINT fk_lease_status FOREIGN KEY (lease_status) REFERENCES sa.x_lease_status (lease_status)
);
COMMENT ON COLUMN sa.x_customer_lease.objid IS 'System defined sequence';
COMMENT ON COLUMN sa.x_customer_lease.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_customer_lease.lease_status IS 'Lease status';
COMMENT ON COLUMN sa.x_customer_lease.application_req_num IS 'Transaction Application Req Number';
COMMENT ON COLUMN sa.x_customer_lease.client_id IS 'Customer client identifier';
COMMENT ON COLUMN sa.x_customer_lease.insert_dt IS 'Date record inserted';
COMMENT ON COLUMN sa.x_customer_lease.update_dt IS 'Date record updated';
COMMENT ON COLUMN sa.x_customer_lease.smp IS 'Card Inventory Number';
COMMENT ON COLUMN sa.x_customer_lease.account_group_id IS 'Unique identifier of the account group.';
COMMENT ON COLUMN sa.x_customer_lease.lease_scope IS 'It defines the Scope of the lease, possible values are (Device only, Device + Plan)';
CREATE TABLE sa.x_rtr_trans_log (
  objid NUMBER NOT NULL,
  step VARCHAR2(100 BYTE),
  rtr_vendor_name VARCHAR2(100 BYTE),
  rtr_remote_trans_id VARCHAR2(100 BYTE),
  rtr_merch_store_name VARCHAR2(100 BYTE),
  rtr_request sa.rtr_trans_header_tab,
  rtr_response sa.rtr_trans_header_tab,
  error_number VARCHAR2(50 BYTE),
  error_message VARCHAR2(4000 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_rtr_trans_log PRIMARY KEY (objid)
)
NESTED TABLE rtr_request STORE AS rtr_request_nt
NESTED TABLE rtr_response STORE AS rtr_response_nt;
COMMENT ON TABLE sa.x_rtr_trans_log IS 'RTR transactions log table';
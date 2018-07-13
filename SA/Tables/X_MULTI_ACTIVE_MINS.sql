CREATE TABLE sa.x_multi_active_mins (
  creation_date DATE DEFAULT sysdate,
  call_trans_objid NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_carrier_id NUMBER,
  x_technology VARCHAR2(20 BYTE),
  x_line_status VARCHAR2(20 BYTE),
  x_transact_date DATE,
  x_action_type VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_result VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_multi_active_mins ADD SUPPLEMENTAL LOG GROUP dmtsora1678520641_0 (call_trans_objid, creation_date, x_action_type, x_carrier_id, x_line_status, x_min, x_result, x_service_id, x_sourcesystem, x_technology, x_transact_date) ALWAYS;
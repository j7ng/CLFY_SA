CREATE TABLE sa.external_mo_req_hist (
  objid NUMBER,
  insert_date DATE,
  update_date DATE,
  request_xml VARCHAR2(1000 BYTE),
  response_xml VARCHAR2(1000 BYTE),
  source_system VARCHAR2(20 BYTE),
  calc_sub_source_system VARCHAR2(40 BYTE),
  request_channel VARCHAR2(200 BYTE),
  "METADATA" VARCHAR2(200 BYTE),
  status VARCHAR2(1 BYTE),
  err_code VARCHAR2(20 BYTE),
  err_msg VARCHAR2(1000 BYTE)
);
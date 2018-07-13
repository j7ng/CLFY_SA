CREATE TABLE sa.table_msg_id_gen (
  objid NUMBER,
  msg_hdl_id NUMBER,
  msg_hdl_name VARCHAR2(30 BYTE),
  msg_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_msg_id_gen ADD SUPPLEMENTAL LOG GROUP dmtsora2111748285_0 (dev, msg_hdl_id, msg_hdl_name, msg_id, objid) ALWAYS;
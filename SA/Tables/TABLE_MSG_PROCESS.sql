CREATE TABLE sa.table_msg_process (
  objid NUMBER,
  in_msg_id NUMBER,
  out_msg_id NUMBER,
  in_msg_hdl_id NUMBER,
  out_msg_hdl_id NUMBER,
  msg_hdl_id NUMBER,
  msg_step NUMBER,
  error_code NUMBER,
  in_msg_dt DATE,
  done_ind NUMBER,
  server_id NUMBER,
  dev NUMBER,
  msg_type NUMBER
);
ALTER TABLE sa.table_msg_process ADD SUPPLEMENTAL LOG GROUP dmtsora1206678000_0 (dev, done_ind, error_code, in_msg_dt, in_msg_hdl_id, in_msg_id, msg_hdl_id, msg_step, msg_type, objid, out_msg_hdl_id, out_msg_id, server_id) ALWAYS;
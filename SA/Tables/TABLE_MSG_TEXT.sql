CREATE TABLE sa.table_msg_text (
  objid NUMBER,
  msg_type NUMBER,
  msg_step NUMBER,
  out_msg_dt DATE,
  msg_text LONG,
  dev NUMBER,
  msg_text2msg_process NUMBER(*,0)
);
ALTER TABLE sa.table_msg_text ADD SUPPLEMENTAL LOG GROUP dmtsora670317904_0 (dev, msg_step, msg_text2msg_process, msg_type, objid, out_msg_dt) ALWAYS;
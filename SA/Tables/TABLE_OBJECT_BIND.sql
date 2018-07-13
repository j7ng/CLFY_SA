CREATE TABLE sa.table_object_bind (
  objid NUMBER,
  in_type NUMBER,
  in_lowid NUMBER,
  out_type NUMBER,
  out_lowid NUMBER,
  direction NUMBER,
  dir_mask NUMBER,
  error_code NUMBER,
  error_msg VARCHAR2(255 BYTE),
  server_id NUMBER,
  dev NUMBER,
  bind2exch_protocol NUMBER(*,0)
);
ALTER TABLE sa.table_object_bind ADD SUPPLEMENTAL LOG GROUP dmtsora121453582_0 (bind2exch_protocol, dev, direction, dir_mask, error_code, error_msg, in_lowid, in_type, objid, out_lowid, out_type, server_id) ALWAYS;
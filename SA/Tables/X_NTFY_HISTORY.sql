CREATE TABLE sa.x_ntfy_history (
  objid NUMBER,
  x_ref_objid NUMBER(10),
  x_ref_type NUMBER(30),
  x_notes VARCHAR2(30 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_ntfy_history ADD SUPPLEMENTAL LOG GROUP dmtsora598594238_0 (objid, x_description, x_notes, x_ref_objid, x_ref_type, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_history IS 'EMPTY TABLE. Billing notification history';
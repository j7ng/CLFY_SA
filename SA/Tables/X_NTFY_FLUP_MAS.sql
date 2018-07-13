CREATE TABLE sa.x_ntfy_flup_mas (
  objid NUMBER NOT NULL,
  x_stopping_criteria VARCHAR2(255 BYTE),
  x_update_stamp DATE NOT NULL,
  x_update_status CHAR NOT NULL,
  x_update_user VARCHAR2(255 BYTE) NOT NULL,
  flup_itm2tmplt_mas NUMBER,
  flup_itm2chnl_mas NUMBER
);
ALTER TABLE sa.x_ntfy_flup_mas ADD SUPPLEMENTAL LOG GROUP dmtsora2032607051_0 (flup_itm2chnl_mas, flup_itm2tmplt_mas, objid, x_stopping_criteria, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_flup_mas IS 'Billing notification follow-up master';
COMMENT ON COLUMN sa.x_ntfy_flup_mas.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_flup_mas.x_stopping_criteria IS 'Conditions to stop sending followup notification';
COMMENT ON COLUMN sa.x_ntfy_flup_mas.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_flup_mas.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_flup_mas.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_flup_mas.flup_itm2tmplt_mas IS 'Reference to notificaion template master';
COMMENT ON COLUMN sa.x_ntfy_flup_mas.flup_itm2chnl_mas IS 'Reference to notificaion channel master';
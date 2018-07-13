CREATE TABLE sa.x_ntfy_flup_itm (
  objid NUMBER,
  x_priority NUMBER(1),
  x_frequency NUMBER(5),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  flup_itm2tmplt_mas NUMBER(10),
  flup_itm2chnl_mas NUMBER,
  flup_itm2flup_mas NUMBER
);
ALTER TABLE sa.x_ntfy_flup_itm ADD SUPPLEMENTAL LOG GROUP dmtsora670491694_0 (flup_itm2chnl_mas, flup_itm2flup_mas, flup_itm2tmplt_mas, objid, x_frequency, x_priority, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_flup_itm IS 'Billing notification follow-up item';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.x_priority IS 'Priority info for notification followup item';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.x_frequency IS 'Frequency of followup notification';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.flup_itm2tmplt_mas IS 'Reference to notificaion template master';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.flup_itm2chnl_mas IS 'Reference to notificaion channel master';
COMMENT ON COLUMN sa.x_ntfy_flup_itm.flup_itm2flup_mas IS 'Reference to notificaion followup master';
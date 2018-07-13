CREATE TABLE sa.x_ntfy_flup_act (
  objid NUMBER,
  x_parent NUMBER,
  x_priority NUMBER(1),
  x_actdate DATE,
  x_message VARCHAR2(4000 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  x_stopping_criteria VARCHAR2(255 BYTE),
  flup_act2flup_mas NUMBER
);
ALTER TABLE sa.x_ntfy_flup_act ADD SUPPLEMENTAL LOG GROUP dmtsora258150977_0 (flup_act2flup_mas, objid, x_actdate, x_message, x_parent, x_priority, x_stopping_criteria, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_flup_act IS 'Billing notification follow-up action';
COMMENT ON COLUMN sa.x_ntfy_flup_act.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_parent IS 'Parent info for notification followup action';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_priority IS 'Priority info for notification followup action';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_actdate IS 'Action date';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_message IS 'Encrypted Message body';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_flup_act.x_stopping_criteria IS 'Conditions to stop sending followup notification';
COMMENT ON COLUMN sa.x_ntfy_flup_act.flup_act2flup_mas IS 'Reference to notificaion followup master';
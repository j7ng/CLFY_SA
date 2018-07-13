CREATE TABLE sa.x_lifeline_action_trans (
  objid NUMBER NOT NULL,
  x_action_date DATE DEFAULT SYSDATE,
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_action_type VARCHAR2(50 BYTE) NOT NULL CONSTRAINT ll_act_type_constr CHECK (X_ACTION_TYPE IN ('ENROLLMENT', 'DE_ENROLL', 'RE_ENROLL', 'REMOVE_ESN',
                                                          'DE_REGISTER', 'UPGRADE', 'DEACTIVATE', 'BRIGHTPOINT_RETURN')),
  x_action_status VARCHAR2(30 BYTE) DEFAULT 'PENDING',
  x_update_date DATE,
  x_reason VARCHAR2(255 BYTE),
  x_new_esn VARCHAR2(30 BYTE),
  x_action2user NUMBER,
  x_action2pgm_enroll NUMBER,
  x_action2pgm_parameter NUMBER,
  x_action2web_user NUMBER,
  x_deenroll_reason VARCHAR2(200 BYTE),
  x_flash_text VARCHAR2(4000 BYTE),
  x_interact_text VARCHAR2(4000 BYTE),
  x_interact_title VARCHAR2(100 BYTE)
);
ALTER TABLE sa.x_lifeline_action_trans ADD SUPPLEMENTAL LOG GROUP dmtsora2067160461_0 (objid, x_action2pgm_enroll, x_action2pgm_parameter, x_action2user, x_action2web_user, x_action_date, x_action_status, x_action_type, x_esn, x_new_esn, x_reason, x_update_date) ALWAYS;
COMMENT ON TABLE sa.x_lifeline_action_trans IS 'SafeLink  Enrollment Transaction Table';
COMMENT ON COLUMN sa.x_lifeline_action_trans.objid IS 'Primary Key, Internal Record Number';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_action_date IS 'Sysdate at the time record was inserted.';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_esn IS 'Serial Number Phone';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_action_type IS 'Enrollment Action being registered';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_action_status IS 'Status for the Enrollment Action';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_update_date IS 'Sysdate at the time of the latest update to the record.';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_reason IS 'Comments on the latest status change.';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_new_esn IS 'Optional, serial number of new phone required for the enrollment transaction.';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_action2user IS 'Fk to table_user';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_action2pgm_enroll IS 'Fk to x_program_enrolled';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_action2pgm_parameter IS 'FK to x_program_parameters';
COMMENT ON COLUMN sa.x_lifeline_action_trans.x_action2web_user IS 'FK to table_web_user';
CREATE TABLE sa.table_x_escalation_speed (
  objid NUMBER,
  dev NUMBER,
  x_star_rank NUMBER,
  x_auto_carrier NUMBER,
  x_hours2escalate NUMBER,
  x_prev_case_count NUMBER,
  x_prev_case_days NUMBER,
  x_re_open_count NUMBER,
  x_tat_hours NUMBER,
  speed2escalation NUMBER
);
ALTER TABLE sa.table_x_escalation_speed ADD SUPPLEMENTAL LOG GROUP dmtsora663442364_0 (dev, objid, speed2escalation, x_auto_carrier, x_hours2escalate, x_prev_case_count, x_prev_case_days, x_re_open_count, x_star_rank, x_tat_hours) ALWAYS;
COMMENT ON TABLE sa.table_x_escalation_speed IS 'How fast to escalate a case type';
COMMENT ON COLUMN sa.table_x_escalation_speed.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_escalation_speed.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_escalation_speed.x_star_rank IS '1-5';
COMMENT ON COLUMN sa.table_x_escalation_speed.x_auto_carrier IS '0=No , 1=Yes';
COMMENT ON COLUMN sa.table_x_escalation_speed.x_hours2escalate IS 'Reference to ';
COMMENT ON COLUMN sa.table_x_escalation_speed.x_prev_case_count IS 'TBD';
COMMENT ON COLUMN sa.table_x_escalation_speed.x_prev_case_days IS 'TBD';
COMMENT ON COLUMN sa.table_x_escalation_speed.x_re_open_count IS 'TBD';
COMMENT ON COLUMN sa.table_x_escalation_speed.x_tat_hours IS 'TAT for Customer Display';
COMMENT ON COLUMN sa.table_x_escalation_speed.speed2escalation IS 'TBD';
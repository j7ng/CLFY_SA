CREATE TABLE sa.x_program_penalty_pend (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_penalty_amt NUMBER NOT NULL,
  x_penalty_date DATE,
  x_penalty_reason VARCHAR2(500 BYTE),
  x_penalty_status VARCHAR2(20 BYTE),
  penal_pend2prog_enroll NUMBER NOT NULL,
  penal_pend2web_user NUMBER NOT NULL,
  penal_pend2prog_param NUMBER NOT NULL,
  x_user VARCHAR2(255 BYTE),
  penal_pend2part_num NUMBER
);
ALTER TABLE sa.x_program_penalty_pend ADD SUPPLEMENTAL LOG GROUP dmtsora965008514_0 (objid, penal_pend2part_num, penal_pend2prog_enroll, penal_pend2prog_param, penal_pend2web_user, x_esn, x_penalty_amt, x_penalty_date, x_penalty_reason, x_penalty_status, x_user) ALWAYS;
COMMENT ON TABLE sa.x_program_penalty_pend IS 'Billing Programs Purchase support table, is stores penalty for payment decline charges. At this No penalties are implemented.';
COMMENT ON COLUMN sa.x_program_penalty_pend.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_program_penalty_pend.x_esn IS 'Phone Serial Number, references part_serial_no in table_part_inst';
COMMENT ON COLUMN sa.x_program_penalty_pend.x_penalty_amt IS 'Dollar Amount for the penalty to be imposed in case charges are declined.';
COMMENT ON COLUMN sa.x_program_penalty_pend.x_penalty_date IS 'Date, Penalty record is created.';
COMMENT ON COLUMN sa.x_program_penalty_pend.x_penalty_reason IS 'Potential Reason to apply penalty';
COMMENT ON COLUMN sa.x_program_penalty_pend.x_penalty_status IS 'Penalty Status: PENDING,CLEARED';
COMMENT ON COLUMN sa.x_program_penalty_pend.penal_pend2prog_enroll IS 'Reference to x_program_enrolled';
COMMENT ON COLUMN sa.x_program_penalty_pend.penal_pend2web_user IS 'Reference to table_web_user';
COMMENT ON COLUMN sa.x_program_penalty_pend.penal_pend2prog_param IS 'Reference to x_program_parameters';
COMMENT ON COLUMN sa.x_program_penalty_pend.x_user IS 'Not used, login_name';
COMMENT ON COLUMN sa.x_program_penalty_pend.penal_pend2part_num IS 'Reference to table_part_num, Associated to charge.';
CREATE TABLE sa.x_sl_deenroll_reasons (
  objid NUMBER,
  x_bill_flag VARCHAR2(2 BYTE),
  x_deenroll_flag VARCHAR2(4 BYTE),
  x_reason VARCHAR2(600 BYTE),
  x_start_date DATE DEFAULT SYSDATE,
  x_end_date DATE,
  tas_display_flag VARCHAR2(1 BYTE)
);
COMMENT ON COLUMN sa.x_sl_deenroll_reasons.objid IS 'OBJID Sequence number';
COMMENT ON COLUMN sa.x_sl_deenroll_reasons.x_bill_flag IS 'BILL FLAG';
COMMENT ON COLUMN sa.x_sl_deenroll_reasons.x_deenroll_flag IS 'DEENROLL FLAG';
COMMENT ON COLUMN sa.x_sl_deenroll_reasons.x_reason IS 'DEENROLL RESON';
COMMENT ON COLUMN sa.x_sl_deenroll_reasons.x_start_date IS 'EFFECTIVE DATE';
COMMENT ON COLUMN sa.x_sl_deenroll_reasons.x_end_date IS 'END DATE';
COMMENT ON COLUMN sa.x_sl_deenroll_reasons.tas_display_flag IS 'To know TAS display flag';
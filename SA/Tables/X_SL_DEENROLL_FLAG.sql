CREATE TABLE sa.x_sl_deenroll_flag (
  objid NUMBER,
  x_bill_flag VARCHAR2(2 BYTE),
  x_deenroll_flag VARCHAR2(4 BYTE),
  x_deenroll_logic VARCHAR2(600 BYTE),
  x_deenroll_desc VARCHAR2(600 BYTE),
  x_insert_date DATE DEFAULT SYSDATE,
  reversible VARCHAR2(2 BYTE),
  double_dipper VARCHAR2(2 BYTE),
  x_description VARCHAR2(600 BYTE),
  tas_display_flag CHAR DEFAULT 'N',
  expired_flag VARCHAR2(1 BYTE),
  expired_group VARCHAR2(600 BYTE),
  expired_days NUMBER
);
COMMENT ON COLUMN sa.x_sl_deenroll_flag.objid IS 'OBJID Sequence number';
COMMENT ON COLUMN sa.x_sl_deenroll_flag.x_bill_flag IS 'BILL FLAG';
COMMENT ON COLUMN sa.x_sl_deenroll_flag.x_deenroll_flag IS 'DEENROLL FLAG';
COMMENT ON COLUMN sa.x_sl_deenroll_flag.x_deenroll_logic IS 'DEENROLL FLAG LOGIC';
COMMENT ON COLUMN sa.x_sl_deenroll_flag.x_deenroll_desc IS 'DEENROLL FLAG FULL DESCRIPTION';
COMMENT ON COLUMN sa.x_sl_deenroll_flag.x_insert_date IS 'EFFECTIVE DATE';
COMMENT ON COLUMN sa.x_sl_deenroll_flag.reversible IS 'To know if this flag is reversible';
COMMENT ON COLUMN sa.x_sl_deenroll_flag.double_dipper IS 'To know if this a USAC double dipper';
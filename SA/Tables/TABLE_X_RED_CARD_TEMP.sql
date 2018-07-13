CREATE TABLE sa.table_x_red_card_temp (
  objid NUMBER,
  x_red_date DATE,
  x_red_code VARCHAR2(50 BYTE),
  x_redeem_days VARCHAR2(20 BYTE),
  x_red_units VARCHAR2(20 BYTE),
  x_status VARCHAR2(30 BYTE),
  x_result VARCHAR2(20 BYTE),
  temp_red_card2x_call_trans NUMBER
);
COMMENT ON TABLE sa.table_x_red_card_temp IS 'This temp table is used during the gGenCodes tuxedo routine';
COMMENT ON COLUMN sa.table_x_red_card_temp.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_red_card_temp.x_red_date IS 'Date the red card was redeemed';
COMMENT ON COLUMN sa.table_x_red_card_temp.x_red_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_red_card_temp.x_redeem_days IS 'TBD';
COMMENT ON COLUMN sa.table_x_red_card_temp.x_red_units IS 'TBD';
COMMENT ON COLUMN sa.table_x_red_card_temp.x_status IS 'TBD';
COMMENT ON COLUMN sa.table_x_red_card_temp.x_result IS 'TBD';
COMMENT ON COLUMN sa.table_x_red_card_temp.temp_red_card2x_call_trans IS 'Relation to Call Trans';
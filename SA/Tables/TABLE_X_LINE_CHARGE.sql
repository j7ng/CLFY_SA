CREATE TABLE sa.table_x_line_charge (
  objid NUMBER,
  line_charge2carrier NUMBER,
  x_icc_charge NUMBER(6,2),
  x_ld_offpeak NUMBER(6,2),
  x_ld_peak NUMBER(6,2),
  x_access_charge NUMBER(6,2),
  x_appl_discount VARCHAR2(3 BYTE),
  x_discount_flag NUMBER,
  x_discount_per_tier NUMBER,
  x_freeminutes NUMBER,
  x_from NUMBER,
  x_local_offpeak NUMBER(6,2),
  x_local_peak NUMBER(6,2),
  x_pay_suspend NUMBER,
  x_roam_charge NUMBER(6,2),
  x_tier_type VARCHAR2(10 BYTE),
  x_to NUMBER
);
ALTER TABLE sa.table_x_line_charge ADD SUPPLEMENTAL LOG GROUP dmtsora2002239773_0 (line_charge2carrier, objid, x_access_charge, x_appl_discount, x_discount_flag, x_discount_per_tier, x_freeminutes, x_from, x_icc_charge, x_ld_offpeak, x_ld_peak, x_local_offpeak, x_local_peak, x_pay_suspend, x_roam_charge, x_tier_type, x_to) ALWAYS;
COMMENT ON TABLE sa.table_x_line_charge IS 'Contains charges for the lines from the carrier markets';
COMMENT ON COLUMN sa.table_x_line_charge.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_line_charge.line_charge2carrier IS ' Carrier Relation to Line Charge';
COMMENT ON COLUMN sa.table_x_line_charge.x_icc_charge IS 'Interconnect Connectivity Charge';
COMMENT ON COLUMN sa.table_x_line_charge.x_ld_offpeak IS 'Long Distance Offpeak Charges';
COMMENT ON COLUMN sa.table_x_line_charge.x_ld_peak IS 'Long Distance Peak Charges';
COMMENT ON COLUMN sa.table_x_line_charge.x_access_charge IS 'Charges for Line Access';
COMMENT ON COLUMN sa.table_x_line_charge.x_appl_discount IS 'Discount applicable from carrier';
COMMENT ON COLUMN sa.table_x_line_charge.x_discount_flag IS 'Shows if a discount is available from a carrier market: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_line_charge.x_discount_per_tier IS 'Percentage of discount available for tier type';
COMMENT ON COLUMN sa.table_x_line_charge.x_freeminutes IS 'Freeminutes available from the carrier';
COMMENT ON COLUMN sa.table_x_line_charge.x_from IS 'From Range';
COMMENT ON COLUMN sa.table_x_line_charge.x_local_offpeak IS 'Charge for Local Offpeak Time';
COMMENT ON COLUMN sa.table_x_line_charge.x_local_peak IS 'Charge for Local Peak Time';
COMMENT ON COLUMN sa.table_x_line_charge.x_pay_suspend IS 'Flag for Pay Charges on Suspending Lines: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_line_charge.x_roam_charge IS 'Charges for Roaming';
COMMENT ON COLUMN sa.table_x_line_charge.x_tier_type IS 'Tier Type';
COMMENT ON COLUMN sa.table_x_line_charge.x_to IS 'To Range';
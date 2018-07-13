CREATE TABLE sa.table_x_purch_dtl (
  objid NUMBER,
  x_red_card_number VARCHAR2(30 BYTE),
  x_smp VARCHAR2(10 BYTE),
  x_units NUMBER,
  x_price NUMBER(19,2),
  x_purch_dtl2mod_level NUMBER,
  x_purch_dtl2redcard NUMBER,
  x_purch_dtl2x_purch_hdr NUMBER,
  x_purch_dtl2roadcard NUMBER,
  x_domain VARCHAR2(40 BYTE)
);
ALTER TABLE sa.table_x_purch_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora1154069325_0 (objid, x_domain, x_price, x_purch_dtl2mod_level, x_purch_dtl2redcard, x_purch_dtl2roadcard, x_purch_dtl2x_purch_hdr, x_red_card_number, x_smp, x_units) ALWAYS;
COMMENT ON TABLE sa.table_x_purch_dtl IS 'cc_Purchase Request Transaction History Detail - one row per PURCHASED redemption card';
COMMENT ON COLUMN sa.table_x_purch_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_red_card_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_smp IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_units IS 'number of airtime units for this red_card - copied from part_num';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_price IS 'price of this red_card (from part_num)';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_purch_dtl2mod_level IS 'part number related to this red_card';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_purch_dtl2redcard IS 'audit trail - part_inst.redcard relation to credit-card purchase';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_purch_dtl2x_purch_hdr IS 'header contains transaction hist, detail has redcard info';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_purch_dtl2roadcard IS 'audit trail - part_inst.redcard relation to credit-card purchase';
COMMENT ON COLUMN sa.table_x_purch_dtl.x_domain IS 'ILD Domain';
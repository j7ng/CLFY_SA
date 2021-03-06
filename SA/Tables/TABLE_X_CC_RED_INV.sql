CREATE TABLE sa.table_x_cc_red_inv (
  objid NUMBER,
  x_reserved_stmp DATE,
  x_red_card_number VARCHAR2(30 BYTE),
  x_smp VARCHAR2(30 BYTE),
  x_creation_date DATE,
  x_icreate_by VARCHAR2(30 BYTE),
  x_reserved_flag NUMBER,
  x_reserved_id NUMBER,
  x_cc_red_inv2mod_level NUMBER,
  x_domain VARCHAR2(30 BYTE),
  x_consumer VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_cc_red_inv ADD SUPPLEMENTAL LOG GROUP dmtsora849252441_0 (objid, x_cc_red_inv2mod_level, x_creation_date, x_domain, x_icreate_by, x_red_card_number, x_reserved_flag, x_reserved_id, x_reserved_stmp, x_smp) ALWAYS;
COMMENT ON TABLE sa.table_x_cc_red_inv IS 'REQUIRES REVISION 090800 inventory pool of non-retail red_cards available for credit-card purchase';
COMMENT ON COLUMN sa.table_x_cc_red_inv.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_reserved_stmp IS 'indicates time that this row was reserved for possible purchase';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_red_card_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_smp IS 'TBD';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_creation_date IS 'TBD';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_icreate_by IS 'TBD';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_reserved_flag IS '1 = reserved, 0 = available';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_reserved_id IS 'number generated by table_num_scheme to uniquely identify each request we send to CyberSource';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_cc_red_inv2mod_level IS 'purchasable redcard inv related thru mod level to partnum for prices';
COMMENT ON COLUMN sa.table_x_cc_red_inv.x_domain IS 'TBD';
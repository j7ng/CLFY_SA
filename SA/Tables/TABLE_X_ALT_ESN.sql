CREATE TABLE sa.table_x_alt_esn (
  objid NUMBER,
  x_date DATE,
  x_type VARCHAR2(30 BYTE),
  x_orig_esn VARCHAR2(30 BYTE),
  x_replacement_esn VARCHAR2(30 BYTE),
  x_user VARCHAR2(40 BYTE),
  x_status VARCHAR2(30 BYTE),
  x_alt_esn2case NUMBER,
  x_alt_esn2contact NUMBER,
  x_orig_esn2part_inst NUMBER,
  x_replacement_esn2part_inst NUMBER,
  x_new_sim VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_alt_esn ADD SUPPLEMENTAL LOG GROUP dmtsora1231298818_0 (objid, x_alt_esn2case, x_alt_esn2contact, x_date, x_new_sim, x_orig_esn, x_orig_esn2part_inst, x_replacement_esn, x_replacement_esn2part_inst, x_status, x_type, x_user) ALWAYS;
COMMENT ON TABLE sa.table_x_alt_esn IS 'Used for Exchnages and possibly promotions in the future';
COMMENT ON COLUMN sa.table_x_alt_esn.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_alt_esn.x_date IS 'TBD';
COMMENT ON COLUMN sa.table_x_alt_esn.x_type IS 'Type of Transaction';
COMMENT ON COLUMN sa.table_x_alt_esn.x_orig_esn IS 'TBD';
COMMENT ON COLUMN sa.table_x_alt_esn.x_replacement_esn IS 'TBD';
COMMENT ON COLUMN sa.table_x_alt_esn.x_user IS 'User originating the transaction';
COMMENT ON COLUMN sa.table_x_alt_esn.x_status IS 'TBD';
COMMENT ON COLUMN sa.table_x_alt_esn.x_alt_esn2case IS 'MTO relation to Case';
COMMENT ON COLUMN sa.table_x_alt_esn.x_alt_esn2contact IS 'MTO relation to contact';
COMMENT ON COLUMN sa.table_x_alt_esn.x_orig_esn2part_inst IS 'MTO relation to part_inst for original esn';
COMMENT ON COLUMN sa.table_x_alt_esn.x_replacement_esn2part_inst IS 'MTO relation to part_inst for replacement esn';
COMMENT ON COLUMN sa.table_x_alt_esn.x_new_sim IS 'new sim for exchange cases';
CREATE TABLE sa.table_x_contact_part_inst (
  objid NUMBER,
  x_contact_part_inst2contact NUMBER,
  x_contact_part_inst2part_inst NUMBER,
  x_esn_nick_name VARCHAR2(30 BYTE),
  x_is_default NUMBER,
  x_transfer_flag NUMBER,
  x_verified VARCHAR2(1 BYTE)
);
ALTER TABLE sa.table_x_contact_part_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1098803052_0 (objid, x_contact_part_inst2contact, x_contact_part_inst2part_inst, x_esn_nick_name, x_is_default, x_transfer_flag, x_verified) ALWAYS;
COMMENT ON TABLE sa.table_x_contact_part_inst IS 'This table defines My Account memberships linking ESNs with Contacts';
COMMENT ON COLUMN sa.table_x_contact_part_inst.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.table_x_contact_part_inst.x_contact_part_inst2contact IS 'Reference objid in table_contact';
COMMENT ON COLUMN sa.table_x_contact_part_inst.x_contact_part_inst2part_inst IS 'Reference objid in table_part_inst';
COMMENT ON COLUMN sa.table_x_contact_part_inst.x_esn_nick_name IS 'ESN Nick Name';
COMMENT ON COLUMN sa.table_x_contact_part_inst.x_is_default IS 'Is Default Flag';
COMMENT ON COLUMN sa.table_x_contact_part_inst.x_transfer_flag IS 'Transfer Flag';
COMMENT ON COLUMN sa.table_x_contact_part_inst.x_verified IS 'Verified Flag';
CREATE TABLE sa.x_ff_part_num_mapping (
  objid NUMBER,
  x_source_part_num VARCHAR2(25 BYTE),
  x_target_part_num1 VARCHAR2(25 BYTE),
  x_target_part_num2 VARCHAR2(25 BYTE),
  x_start_date DATE,
  x_end_date DATE,
  x_ff_objid NUMBER,
  x_ff_type VARCHAR2(50 BYTE),
  CONSTRAINT objid_unq UNIQUE (objid),
  CONSTRAINT src_pn_uq UNIQUE (x_source_part_num)
);
COMMENT ON TABLE sa.x_ff_part_num_mapping IS 'Table having part number mapping information for B2B fullfillent.';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.objid IS 'Internal record number.';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.x_source_part_num IS 'app part num.';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.x_target_part_num1 IS 'billing/vas/ild part num.';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.x_target_part_num2 IS 'billing part num..';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.x_start_date IS 'start date.';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.x_end_date IS 'end date.';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.x_ff_objid IS 'program_parameter objid/vas objid.';
COMMENT ON COLUMN sa.x_ff_part_num_mapping.x_ff_type IS 'program type -billing,vas,hpp,ild,etc';
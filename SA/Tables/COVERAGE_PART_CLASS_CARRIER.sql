CREATE TABLE sa.coverage_part_class_carrier (
  objid NUMBER(38) NOT NULL,
  brand VARCHAR2(80 BYTE) NOT NULL,
  short_parent_name VARCHAR2(80 BYTE),
  part_class_name VARCHAR2(30 BYTE),
  CONSTRAINT pk_coverage_part_class_carrier PRIMARY KEY (objid),
  CONSTRAINT coverage_part_class_carr_uk UNIQUE (brand,short_parent_name,part_class_name)
);
COMMENT ON COLUMN sa.coverage_part_class_carrier.brand IS 'Name of the Brand';
COMMENT ON COLUMN sa.coverage_part_class_carrier.short_parent_name IS 'through which Carrier';
COMMENT ON COLUMN sa.coverage_part_class_carrier.part_class_name IS 'Part_Class Name';
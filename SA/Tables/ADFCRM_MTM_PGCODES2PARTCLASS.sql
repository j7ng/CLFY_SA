CREATE TABLE sa.adfcrm_mtm_pgcodes2partclass (
  code_id VARCHAR2(200 BYTE) NOT NULL,
  part_class_id NUMBER NOT NULL,
  CONSTRAINT adfcrm_mtm_pgcode2partclass_pk PRIMARY KEY (code_id,part_class_id),
  CONSTRAINT adfcrm_mtm_pgcode2partclass_fk FOREIGN KEY (code_id) REFERENCES sa.adfcrm_pergencodes (code_id)
);
COMMENT ON TABLE sa.adfcrm_mtm_pgcodes2partclass IS 'Codes associated with models in order to qualify and/or condition it';
COMMENT ON COLUMN sa.adfcrm_mtm_pgcodes2partclass.code_id IS 'References to adfcrm_pergencodes.code_id';
COMMENT ON COLUMN sa.adfcrm_mtm_pgcodes2partclass.part_class_id IS 'References to table_part_class.objid';
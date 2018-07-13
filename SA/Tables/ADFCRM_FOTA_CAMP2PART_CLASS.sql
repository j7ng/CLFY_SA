CREATE TABLE sa.adfcrm_fota_camp2part_class (
  objid NUMBER NOT NULL,
  fota_hdr_objid NUMBER NOT NULL,
  part_class_objid NUMBER,
  CONSTRAINT adfcrm_fota_camp2part_class_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.adfcrm_fota_camp2part_class IS 'This table is used to store FOTA CAMPAIGN to Part Class details.';
COMMENT ON COLUMN sa.adfcrm_fota_camp2part_class.fota_hdr_objid IS 'CAMPAIGN HEADER OBJID';
COMMENT ON COLUMN sa.adfcrm_fota_camp2part_class.part_class_objid IS 'Part Class Obj Id';
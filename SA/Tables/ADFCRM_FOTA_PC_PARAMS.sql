CREATE TABLE sa.adfcrm_fota_pc_params (
  objid NUMBER NOT NULL,
  part_class_objid NUMBER NOT NULL,
  x_fota_pc_model VARCHAR2(300 BYTE),
  x_fota_pc_make VARCHAR2(300 BYTE),
  CONSTRAINT adfcrm_fota_pc_params_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.adfcrm_fota_pc_params IS 'This table is used to store Make and Model to Part Class.';
COMMENT ON COLUMN sa.adfcrm_fota_pc_params.part_class_objid IS 'Part Class Obj Id';
COMMENT ON COLUMN sa.adfcrm_fota_pc_params.x_fota_pc_model IS 'FOTA Part Class MODEL';
COMMENT ON COLUMN sa.adfcrm_fota_pc_params.x_fota_pc_make IS 'FOTA Part Class Make';
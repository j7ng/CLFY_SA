CREATE TABLE sa.table_svc_type (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(30 BYTE),
  cb_exesub NUMBER,
  sub_service VARCHAR2(30 BYTE),
  sub_field VARCHAR2(64 BYTE),
  type_alpha VARCHAR2(30 BYTE),
  "SYSTEM" NUMBER
);
ALTER TABLE sa.table_svc_type ADD SUPPLEMENTAL LOG GROUP dmtsora476657633_0 (cb_exesub, dev, objid, sub_field, sub_service, "SYSTEM", title, type_alpha) ALWAYS;
COMMENT ON TABLE sa.table_svc_type IS 'Define the type of a service request (native, CB_EXESUB and so on)';
COMMENT ON COLUMN sa.table_svc_type.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_svc_type.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_svc_type.title IS 'The title, shown in the drop down list';
COMMENT ON COLUMN sa.table_svc_type.cb_exesub IS '0 = svc_name is Tux service, 1 = svc_name is sub func. name written to subfld, subsvc=Tux service, 2: Tux service = CB_EXESUB, subsvc is CLFY_SUB';
COMMENT ON COLUMN sa.table_svc_type.sub_service IS 'COntrolled by cb_exesub, the tux service, or sub-service to call';
COMMENT ON COLUMN sa.table_svc_type.sub_field IS 'The FML field that svc_name is written to';
COMMENT ON COLUMN sa.table_svc_type.type_alpha IS 'Text to show for cb_exesub: 0 = Direct Tuxedo Service, 1 = Indirect Tuxedo, 2 = Indirect via CB_EXESUB';
COMMENT ON COLUMN sa.table_svc_type."SYSTEM" IS '1 = system - cannot be edited or deleted';
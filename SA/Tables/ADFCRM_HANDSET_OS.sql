CREATE TABLE sa.adfcrm_handset_os (
  objid NUMBER,
  display_order NUMBER,
  operating_system VARCHAR2(50 BYTE),
  os_version VARCHAR2(30 BYTE),
  os_desc VARCHAR2(100 BYTE),
  handset_manufacturer VARCHAR2(30 BYTE),
  handset_desc VARCHAR2(100 BYTE),
  script_id VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.adfcrm_handset_os IS 'TAS Handset Operating System for APN Instructions';
COMMENT ON COLUMN sa.adfcrm_handset_os.operating_system IS 'ANDROID, IOS, SENSE, etc. (use captials)';
COMMENT ON COLUMN sa.adfcrm_handset_os.os_version IS 'OS Version, 1.1, 6, etc.';
COMMENT ON COLUMN sa.adfcrm_handset_os.os_desc IS 'Honeycomb, Gingerbread, Sense, Other, etc.';
COMMENT ON COLUMN sa.adfcrm_handset_os.handset_manufacturer IS 'Samsung, Nokia, HTC, Motorolla, Etc.';
COMMENT ON COLUMN sa.adfcrm_handset_os.script_id IS 'script id';
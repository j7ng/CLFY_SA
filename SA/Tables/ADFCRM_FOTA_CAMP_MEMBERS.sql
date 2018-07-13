CREATE TABLE sa.adfcrm_fota_camp_members (
  objid NUMBER NOT NULL,
  fota_camp_objid NUMBER NOT NULL,
  esn VARCHAR2(30 BYTE),
  status VARCHAR2(50 BYTE),
  cal_trans_objid NUMBER,
  insert_date DATE NOT NULL,
  modify_date DATE NOT NULL,
  error_message VARCHAR2(500 BYTE),
  CONSTRAINT adfcrm_fota_camp_members_pk PRIMARY KEY (objid) USING INDEX sa.adfcrm_fota_camp_members_idx
);
COMMENT ON TABLE sa.adfcrm_fota_camp_members IS 'This table is used to store FOTA CAMPAIGN Memebrs details.';
COMMENT ON COLUMN sa.adfcrm_fota_camp_members.objid IS 'OBJID of CAMPAIGN Memebrs';
COMMENT ON COLUMN sa.adfcrm_fota_camp_members.fota_camp_objid IS 'CAMPAIGN OBJID';
COMMENT ON COLUMN sa.adfcrm_fota_camp_members.esn IS 'ESN from Table Part Inst';
COMMENT ON COLUMN sa.adfcrm_fota_camp_members.status IS 'Campign Memener status PENDING,COMPLETED';
COMMENT ON COLUMN sa.adfcrm_fota_camp_members.cal_trans_objid IS 'Call Trans Details';
COMMENT ON COLUMN sa.adfcrm_fota_camp_members.error_message IS 'Hold Error Message when the Status is FAILED';
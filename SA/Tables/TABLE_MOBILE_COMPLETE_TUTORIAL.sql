CREATE TABLE sa.table_mobile_complete_tutorial (
  objid NUMBER NOT NULL,
  tutorial_name VARCHAR2(100 BYTE) NOT NULL,
  tutorial_id VARCHAR2(30 BYTE) NOT NULL,
  device_id VARCHAR2(30 BYTE),
  tutorial2handset NUMBER NOT NULL
);
COMMENT ON COLUMN sa.table_mobile_complete_tutorial.objid IS 'PRIMARY KEY';
COMMENT ON COLUMN sa.table_mobile_complete_tutorial.tutorial_name IS 'NAME OF A SPECIFIC TUTORIAL SUCH AS FIND SERIAL NUMBER OR FIND PHONE NUMBER';
COMMENT ON COLUMN sa.table_mobile_complete_tutorial.tutorial_id IS 'THE TUTORIALID VALUE FROM MOBILE COMPLETE DETAIL TUTORIAL PAGE URLS';
COMMENT ON COLUMN sa.table_mobile_complete_tutorial.device_id IS 'THE DEVICEID VALUE FROM MOBILE COMPLETE DETAIL TUTORIAL PAGE URLS';
COMMENT ON COLUMN sa.table_mobile_complete_tutorial.tutorial2handset IS 'FOREIGN KEY (OBJID) TO THE TABLE TABLE_MOBILE_COMPLETE_HANDSET';
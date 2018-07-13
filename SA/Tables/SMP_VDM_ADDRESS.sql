CREATE TABLE sa.smp_vdm_address (
  sequence_num NUMBER NOT NULL,
  username VARCHAR2(256 BYTE),
  app_name VARCHAR2(256 BYTE),
  enhanced_notification NUMBER(*,0),
  "PROXY" VARCHAR2(256 BYTE),
  slotretrievaltime DATE
);
ALTER TABLE sa.smp_vdm_address ADD SUPPLEMENTAL LOG GROUP dmtsora213314334_0 (app_name, enhanced_notification, "PROXY", sequence_num, slotretrievaltime, username) ALWAYS;
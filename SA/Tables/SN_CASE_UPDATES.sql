CREATE TABLE sa.sn_case_updates (
  load_date DATE,
  casetype VARCHAR2(30 BYTE),
  casedate DATE,
  esn VARCHAR2(30 BYTE),
  newesn VARCHAR2(30 BYTE),
  trackingnumber VARCHAR2(30 BYTE),
  caseupdatefile VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.sn_case_updates IS 'THIS TABLE STORES SERVICE NET CASE UPDATES';
COMMENT ON COLUMN sa.sn_case_updates.load_date IS 'CURRENT LOAD DATE';
COMMENT ON COLUMN sa.sn_case_updates.casetype IS 'CASE TYPE';
COMMENT ON COLUMN sa.sn_case_updates.casedate IS 'CASE DATE';
COMMENT ON COLUMN sa.sn_case_updates.esn IS 'OLD ESN';
COMMENT ON COLUMN sa.sn_case_updates.newesn IS 'NEW ESN';
COMMENT ON COLUMN sa.sn_case_updates.trackingnumber IS 'TRACKING NUMBER';
COMMENT ON COLUMN sa.sn_case_updates.caseupdatefile IS 'CASE UPDATES FILE NAME';
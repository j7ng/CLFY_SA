CREATE TABLE sa.tdma_10_19 (
  esn VARCHAR2(20 BYTE),
  new_model VARCHAR2(6 BYTE),
  case_id VARCHAR2(30 BYTE)
);
ALTER TABLE sa.tdma_10_19 ADD SUPPLEMENTAL LOG GROUP dmtsora227510464_0 (case_id, esn, new_model) ALWAYS;
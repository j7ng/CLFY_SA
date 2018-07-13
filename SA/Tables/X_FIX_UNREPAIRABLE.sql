CREATE TABLE sa.x_fix_unrepairable (
  esn VARCHAR2(20 BYTE),
  esn_status VARCHAR2(10 BYTE),
  status VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_fix_unrepairable ADD SUPPLEMENTAL LOG GROUP dmtsora199010567_0 (esn, esn_status, status) ALWAYS;
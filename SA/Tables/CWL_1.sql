CREATE TABLE sa.cwl_1 (
  esn VARCHAR2(30 BYTE),
  esn_objid NUMBER
);
ALTER TABLE sa.cwl_1 ADD SUPPLEMENTAL LOG GROUP dmtsora1679386227_0 (esn, esn_objid) ALWAYS;
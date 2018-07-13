CREATE TABLE sa.cwl_3 (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  part_inst2x_pers NUMBER,
  esn_objid NUMBER
);
ALTER TABLE sa.cwl_3 ADD SUPPLEMENTAL LOG GROUP dmtsora1367434316_0 (esn, esn_objid, "MIN", part_inst2x_pers) ALWAYS;
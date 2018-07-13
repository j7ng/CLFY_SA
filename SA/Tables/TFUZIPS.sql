CREATE TABLE sa.tfuzips (
  zipcode VARCHAR2(9 BYTE),
  city VARCHAR2(32 BYTE),
  postate VARCHAR2(10 BYTE),
  pocounty VARCHAR2(29 BYTE),
  marketarea VARCHAR2(41 BYTE),
  mktid NUMBER,
  owner_a VARCHAR2(35 BYTE),
  tech_a VARCHAR2(9 BYTE),
  owner_b VARCHAR2(35 BYTE),
  tech__b VARCHAR2(9 BYTE),
  rspri_owne VARCHAR2(15 BYTE),
  digpri_own VARCHAR2(30 BYTE),
  digpri_tec VARCHAR2(14 BYTE)
);
ALTER TABLE sa.tfuzips ADD SUPPLEMENTAL LOG GROUP dmtsora1327773381_0 (city, digpri_own, digpri_tec, marketarea, mktid, owner_a, owner_b, pocounty, postate, rspri_owne, tech_a, tech__b, zipcode) ALWAYS;
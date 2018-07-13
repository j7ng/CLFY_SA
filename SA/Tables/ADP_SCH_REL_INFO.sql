CREATE TABLE sa.adp_sch_rel_info (
  type_id NUMBER NOT NULL,
  rel_name VARCHAR2(64 BYTE) NOT NULL,
  rel_type NUMBER NOT NULL,
  target_name VARCHAR2(64 BYTE) NOT NULL,
  gen_rel_id NUMBER NOT NULL,
  spec_rel_id NUMBER NOT NULL,
  inv_rel_name VARCHAR2(64 BYTE) NOT NULL,
  comments VARCHAR2(255 BYTE),
  rel_flags NUMBER NOT NULL,
  rel_phy_name VARCHAR2(64 BYTE),
  focus_fldname VARCHAR2(64 BYTE),
  flags NUMBER,
  exclusive_set VARCHAR2(64 BYTE)
);
ALTER TABLE sa.adp_sch_rel_info ADD SUPPLEMENTAL LOG GROUP dmtsora972528690_0 (comments, exclusive_set, flags, focus_fldname, gen_rel_id, inv_rel_name, rel_flags, rel_name, rel_phy_name, rel_type, spec_rel_id, target_name, type_id) ALWAYS;
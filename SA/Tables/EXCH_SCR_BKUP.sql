CREATE TABLE sa.exch_scr_bkup (
  x_scr_objid NUMBER,
  x_script_type VARCHAR2(50 BYTE),
  x_script_text LONG,
  x_language VARCHAR2(20 BYTE)
);
ALTER TABLE sa.exch_scr_bkup ADD SUPPLEMENTAL LOG GROUP dmtsora1102210086_0 (x_language, x_script_type, x_scr_objid) ALWAYS;
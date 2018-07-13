CREATE TABLE sa.x_net10_ext_esn (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  old_expy_dt DATE,
  new_expy_dt DATE,
  updt_yn CHAR,
  updt_dt DATE
);
ALTER TABLE sa.x_net10_ext_esn ADD SUPPLEMENTAL LOG GROUP dmtsora1767042244_0 (esn, "MIN", new_expy_dt, old_expy_dt, updt_dt, updt_yn) ALWAYS;
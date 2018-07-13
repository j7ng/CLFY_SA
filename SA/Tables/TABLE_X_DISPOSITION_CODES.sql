CREATE TABLE sa.table_x_disposition_codes (
  objid NUMBER,
  x_disposition_code NUMBER,
  x_disposition_desc VARCHAR2(200 BYTE)
);
ALTER TABLE sa.table_x_disposition_codes ADD SUPPLEMENTAL LOG GROUP dmtsora1754094504_0 (objid, x_disposition_code, x_disposition_desc) ALWAYS;
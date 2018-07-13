CREATE TABLE sa.x_raf_email_template (
  "ID" NUMBER,
  "TEXT" VARCHAR2(2000 BYTE),
  "TYPE" VARCHAR2(30 BYTE),
  start_date DATE,
  end_date DATE
);
ALTER TABLE sa.x_raf_email_template ADD SUPPLEMENTAL LOG GROUP dmtsora303971560_0 (end_date, "ID", start_date, "TEXT", "TYPE") ALWAYS;
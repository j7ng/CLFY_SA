CREATE TABLE sa.act_total (
  esn VARCHAR2(30 BYTE),
  phone VARCHAR2(10 BYTE),
  "ACTION" VARCHAR2(1 BYTE),
  status VARCHAR2(1 BYTE),
  datemvt DATE
);
ALTER TABLE sa.act_total ADD SUPPLEMENTAL LOG GROUP dmtsora291642168_0 ("ACTION", datemvt, esn, phone, status) ALWAYS;
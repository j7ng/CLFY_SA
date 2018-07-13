CREATE TABLE sa.table_lead_extn (
  objid NUMBER,
  dev NUMBER,
  field_name VARCHAR2(30 BYTE),
  field_value VARCHAR2(255 BYTE),
  s_field_value VARCHAR2(255 BYTE),
  lead_extn2lead NUMBER
);
ALTER TABLE sa.table_lead_extn ADD SUPPLEMENTAL LOG GROUP dmtsora315733139_0 (dev, field_name, field_value, lead_extn2lead, objid, s_field_value) ALWAYS;
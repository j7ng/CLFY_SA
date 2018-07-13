CREATE TABLE sa.table_x_act_message (
  objid NUMBER,
  x_type VARCHAR2(30 BYTE),
  x_message LONG,
  x_is_default NUMBER,
  x_act_message2x_carrier NUMBER,
  x_ivr_script VARCHAR2(10 BYTE)
);
ALTER TABLE sa.table_x_act_message ADD SUPPLEMENTAL LOG GROUP dmtsora217373658_0 (objid, x_act_message2x_carrier, x_is_default, x_ivr_script, x_type) ALWAYS;
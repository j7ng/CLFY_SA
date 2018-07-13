CREATE TABLE sa.table_x79escal (
  objid NUMBER,
  dev NUMBER,
  server_id NUMBER,
  "STATE" NUMBER,
  "TIME" VARCHAR2(30 BYTE),
  esc_level NUMBER,
  escal2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79escal ADD SUPPLEMENTAL LOG GROUP dmtsora325422128_0 (dev, escal2x79telcom_tr, esc_level, objid, server_id, "STATE", "TIME") ALWAYS;
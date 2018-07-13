CREATE TABLE sa.table_device (
  objid NUMBER,
  type_id NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  ver_clarify VARCHAR2(40 BYTE),
  ver_customer VARCHAR2(40 BYTE),
  cust_ind NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_device ADD SUPPLEMENTAL LOG GROUP dmtsora1512168909_0 (cust_ind, dev, "NAME", objid, type_id, ver_clarify, ver_customer) ALWAYS;
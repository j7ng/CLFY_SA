CREATE TABLE sa.table_exch_txn (
  objid NUMBER,
  transaction_id VARCHAR2(80 BYTE),
  s_transaction_id VARCHAR2(80 BYTE),
  standard VARCHAR2(80 BYTE),
  s_standard VARCHAR2(80 BYTE),
  "VERSION" VARCHAR2(10 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  trans_code NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_exch_txn ADD SUPPLEMENTAL LOG GROUP dmtsora953501402_0 (description, dev, "NAME", objid, standard, s_name, s_standard, s_transaction_id, transaction_id, trans_code, "VERSION") ALWAYS;
CREATE TABLE sa.table_extern_id (
  objid NUMBER,
  partner_id VARCHAR2(64 BYTE),
  extern_id VARCHAR2(64 BYTE),
  clarify_type NUMBER,
  clarify_objid NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_extern_id ADD SUPPLEMENTAL LOG GROUP dmtsora51451017_0 (clarify_objid, clarify_type, dev, extern_id, objid, partner_id) ALWAYS;
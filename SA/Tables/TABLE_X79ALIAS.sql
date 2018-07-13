CREATE TABLE sa.table_x79alias (
  objid NUMBER,
  dev NUMBER,
  "ALIAS" VARCHAR2(240 BYTE),
  s_alias VARCHAR2(240 BYTE),
  server_id NUMBER,
  alias2x79service NUMBER,
  alias2x79telcom_tr NUMBER,
  p_als2x79provider_tr NUMBER
);
ALTER TABLE sa.table_x79alias ADD SUPPLEMENTAL LOG GROUP dmtsora1781390243_0 ("ALIAS", alias2x79service, alias2x79telcom_tr, dev, objid, p_als2x79provider_tr, server_id, s_alias) ALWAYS;
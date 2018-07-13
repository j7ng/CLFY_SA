CREATE TABLE sa.table_lit_req_itm (
  objid NUMBER,
  dev NUMBER,
  quantity NUMBER,
  lit_req_itm2lit_req NUMBER,
  lit_req_itm2mod_level NUMBER
);
ALTER TABLE sa.table_lit_req_itm ADD SUPPLEMENTAL LOG GROUP dmtsora587026783_0 (dev, lit_req_itm2lit_req, lit_req_itm2mod_level, objid, quantity) ALWAYS;
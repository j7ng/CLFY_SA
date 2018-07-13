CREATE TABLE sa.cid2template (
  carrier_id FLOAT,
  x_default_queue VARCHAR2(30 BYTE),
  "TEMPLATE" VARCHAR2(20 BYTE)
);
ALTER TABLE sa.cid2template ADD SUPPLEMENTAL LOG GROUP dmtsora510520172_0 (carrier_id, "TEMPLATE", x_default_queue) ALWAYS;
CREATE TABLE sa.x_raf_blastlist (
  blast_id NUMBER,
  customer_esn VARCHAR2(30 BYTE),
  customer_email VARCHAR2(80 BYTE),
  customer_status VARCHAR2(15 BYTE),
  contact_objid NUMBER
);
ALTER TABLE sa.x_raf_blastlist ADD SUPPLEMENTAL LOG GROUP dmtsora39201420_0 (blast_id, contact_objid, customer_email, customer_esn, customer_status) ALWAYS;
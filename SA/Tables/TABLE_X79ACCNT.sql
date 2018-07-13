CREATE TABLE sa.table_x79accnt (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(64 BYTE),
  s_name VARCHAR2(64 BYTE),
  addl_text VARCHAR2(255 BYTE),
  server_id NUMBER
);
ALTER TABLE sa.table_x79accnt ADD SUPPLEMENTAL LOG GROUP dmtsora960739231_0 (addl_text, dev, "NAME", objid, server_id, s_name) ALWAYS;
COMMENT ON TABLE sa.table_x79accnt IS 'This object class contains information that describes a customer account that interacts with the carrier. Reserved; future';
COMMENT ON COLUMN sa.table_x79accnt.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x79accnt.dev IS 'Row version number for mobile50 distribution purposes';
COMMENT ON COLUMN sa.table_x79accnt."NAME" IS 'Name given to an account by the customer. Agency that may be billed by the service provider or that may take responsibility for performing network management services for the customer';
COMMENT ON COLUMN sa.table_x79accnt.addl_text IS 'Contains additional pertinent enterprise information that describes the Account. Pertains to the way the customer and the service provider interact when conducting business';
COMMENT ON COLUMN sa.table_x79accnt.server_id IS 'Exchange protocol server ID number';
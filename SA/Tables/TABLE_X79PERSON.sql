CREATE TABLE sa.table_x79person (
  objid NUMBER,
  dev NUMBER,
  per_number VARCHAR2(64 BYTE),
  "NAME" VARCHAR2(64 BYTE),
  s_name VARCHAR2(64 BYTE),
  phone VARCHAR2(64 BYTE),
  fax VARCHAR2(64 BYTE),
  email VARCHAR2(64 BYTE),
  respon VARCHAR2(64 BYTE),
  server_id NUMBER,
  person2x79accnt NUMBER
);
ALTER TABLE sa.table_x79person ADD SUPPLEMENTAL LOG GROUP dmtsora46088375_0 (dev, email, fax, "NAME", objid, person2x79accnt, per_number, phone, respon, server_id, s_name) ALWAYS;
COMMENT ON TABLE sa.table_x79person IS 'Individuals in the managers organization, who can be contacted regarding the account. Reserved; future';
COMMENT ON COLUMN sa.table_x79person.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x79person.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x79person.per_number IS 'Optional identifier of the person';
COMMENT ON COLUMN sa.table_x79person."NAME" IS 'Person s name';
COMMENT ON COLUMN sa.table_x79person.phone IS 'Phone number of the person';
COMMENT ON COLUMN sa.table_x79person.fax IS 'Fax number of the person';
COMMENT ON COLUMN sa.table_x79person.email IS 'E-mail address of the person';
COMMENT ON COLUMN sa.table_x79person.respon IS 'Full name of the Manager role person responsible for the person';
COMMENT ON COLUMN sa.table_x79person.server_id IS 'Exchange protocol server ID number';
COMMENT ON COLUMN sa.table_x79person.person2x79accnt IS 'Accounts for the person';
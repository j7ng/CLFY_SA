CREATE TABLE sa.table_csc_agreement (
  objid NUMBER,
  contract_id VARCHAR2(80 BYTE),
  s_contract_id VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(255 BYTE),
  server_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_csc_agreement ADD SUPPLEMENTAL LOG GROUP dmtsora2006787291_0 (contract_id, dev, objid, server_id, s_contract_id, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_csc_agreement IS 'The Customer Support Consortium agreement provides a means for validating entitlement to vendor services. It is a required object in the entitlement transaction';
COMMENT ON COLUMN sa.table_csc_agreement.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_agreement.contract_id IS 'Contract that is referred to by the requester. This is the contract or other type of agreement under requestor claims entitlement';
COMMENT ON COLUMN sa.table_csc_agreement."TYPE" IS 'Brief description of the contract';
COMMENT ON COLUMN sa.table_csc_agreement.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_agreement.dev IS 'Row version number for mobile distribution purposes';
CREATE TABLE sa.table_fin_accnt (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  dev NUMBER,
  last_update DATE,
  delinquent_status NUMBER,
  hier_name_ind NUMBER,
  status VARCHAR2(20 BYTE),
  fa_parent2bus_org NUMBER,
  fa_child2bus_org NUMBER
);
ALTER TABLE sa.table_fin_accnt ADD SUPPLEMENTAL LOG GROUP dmtsora1991978429_0 (delinquent_status, dev, fa_child2bus_org, fa_parent2bus_org, hier_name_ind, last_update, "NAME", objid, status, s_name) ALWAYS;
COMMENT ON TABLE sa.table_fin_accnt IS 'Financial account, BAN for billing product';
COMMENT ON COLUMN sa.table_fin_accnt.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_fin_accnt."NAME" IS 'A name for the financial account, e.g., Monthly charges of sales division';
COMMENT ON COLUMN sa.table_fin_accnt.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_fin_accnt.last_update IS 'Date time of last update';
COMMENT ON COLUMN sa.table_fin_accnt.delinquent_status IS 'Indicates whether the customer is delinquent or not, i.e., 0=No, 1=Yes, default=0';
COMMENT ON COLUMN sa.table_fin_accnt.hier_name_ind IS 'Indicates whether financial account name is derived from organization s name or not, i.e., 0=No, 1=Yes, default=0';
COMMENT ON COLUMN sa.table_fin_accnt.status IS 'Status of financial account, e.g. Active, Close';
COMMENT ON COLUMN sa.table_fin_accnt.fa_parent2bus_org IS 'Parent organization this financial account belongs to';
COMMENT ON COLUMN sa.table_fin_accnt.fa_child2bus_org IS 'Organization this financial account belongs to';
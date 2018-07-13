CREATE TABLE sa.table_blg_argmnt (
  objid NUMBER,
  dev NUMBER,
  last_update DATE,
  hier_name_ind NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  status VARCHAR2(20 BYTE),
  blg_argmnt2fin_accnt NUMBER,
  ba_parent2bus_org NUMBER,
  ba_child2bus_org NUMBER
);
ALTER TABLE sa.table_blg_argmnt ADD SUPPLEMENTAL LOG GROUP dmtsora1704417220_0 (ba_child2bus_org, ba_parent2bus_org, blg_argmnt2fin_accnt, dev, hier_name_ind, last_update, "NAME", objid, status, s_name) ALWAYS;
COMMENT ON TABLE sa.table_blg_argmnt IS 'Arrangements made for billing';
COMMENT ON COLUMN sa.table_blg_argmnt.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_blg_argmnt.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_blg_argmnt.last_update IS 'Date time of last update';
COMMENT ON COLUMN sa.table_blg_argmnt.hier_name_ind IS 'Indicates whether billing arrangement name is derived from organization s name or not, i.e., 0=No, 1=Yes, default=0';
COMMENT ON COLUMN sa.table_blg_argmnt."NAME" IS 'Name of billing arrangement';
COMMENT ON COLUMN sa.table_blg_argmnt.status IS 'Status of billing arrangement, e.g. Active, Close';
COMMENT ON COLUMN sa.table_blg_argmnt.blg_argmnt2fin_accnt IS 'Financial account having billing arrangements';
COMMENT ON COLUMN sa.table_blg_argmnt.ba_parent2bus_org IS 'Parent organization this billing arrangements belongs to';
COMMENT ON COLUMN sa.table_blg_argmnt.ba_child2bus_org IS 'Organization this billing arrangements belongs to';
CREATE TABLE sa.table_inv_locatn (
  objid NUMBER,
  location_name VARCHAR2(40 BYTE),
  location_descr VARCHAR2(80 BYTE),
  reports_to_loc VARCHAR2(20 BYTE),
  gl_acct_no VARCHAR2(20 BYTE),
  owner_type NUMBER,
  inv_type NUMBER,
  location_type VARCHAR2(20 BYTE),
  trans_auth NUMBER,
  loc_serv_level VARCHAR2(8 BYTE),
  loc_turn_ratio VARCHAR2(8 BYTE),
  "ACTIVE" NUMBER,
  default_location NUMBER,
  d_good_qty NUMBER,
  d_bad_qty NUMBER,
  inv_class NUMBER,
  dev NUMBER,
  inv_locatn2site NUMBER,
  inv_locatn2parent_loc NUMBER,
  gl_locatn2parent_gl NUMBER
);
ALTER TABLE sa.table_inv_locatn ADD SUPPLEMENTAL LOG GROUP dmtsora1704316282_0 ("ACTIVE", default_location, dev, d_bad_qty, d_good_qty, gl_acct_no, gl_locatn2parent_gl, inv_class, inv_locatn2parent_loc, inv_locatn2site, inv_type, location_descr, location_name, location_type, loc_serv_level, loc_turn_ratio, objid, owner_type, reports_to_loc, trans_auth) ALWAYS;
COMMENT ON TABLE sa.table_inv_locatn IS 'A physical inventory location or a general ledger account';
COMMENT ON COLUMN sa.table_inv_locatn.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_inv_locatn.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_inv_locatn.location_descr IS 'Description of the inventory location or GL account';
COMMENT ON COLUMN sa.table_inv_locatn.reports_to_loc IS 'The name of the parent inventory location. Note: as of CFO99, this field is no longer set by default Clarify code. CFO99 supports multiple rollups';
COMMENT ON COLUMN sa.table_inv_locatn.gl_acct_no IS 'If the object is a physical location, the GL account number. If a GL account, the field is either empty, or contains the parent GL account number';
COMMENT ON COLUMN sa.table_inv_locatn.owner_type IS 'Reserved; future';
COMMENT ON COLUMN sa.table_inv_locatn.inv_type IS 'User-assigned inventory type; defaults to inv_class';
COMMENT ON COLUMN sa.table_inv_locatn.location_type IS 'User-defined types of inventory location';
COMMENT ON COLUMN sa.table_inv_locatn.trans_auth IS 'States the type of transactions authorized for the inventory location; i.e., 0=All, 1=None, 2=Authorized Parts only. An authorized part is one for which there is a part_auth object';
COMMENT ON COLUMN sa.table_inv_locatn.loc_serv_level IS 'Reserved; future';
COMMENT ON COLUMN sa.table_inv_locatn.loc_turn_ratio IS 'Reserved; future';
COMMENT ON COLUMN sa.table_inv_locatn."ACTIVE" IS 'Indicates whether the inventory location is active; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_inv_locatn.default_location IS 'Indicates whether the object is the default inventory location for a site; i.e, 0=not default 1=default';
COMMENT ON COLUMN sa.table_inv_locatn.d_good_qty IS 'Display-only field. Used at run time by views which display good part quantity information. No data is stored in the field';
COMMENT ON COLUMN sa.table_inv_locatn.d_bad_qty IS 'Display-only field. Used at run time by views which display bad part quantity information. No data is stored in the field';
COMMENT ON COLUMN sa.table_inv_locatn.inv_class IS 'Inventory class; i.e., 0=inventory location, 1=capital GL account, 2=expense GL account';
COMMENT ON COLUMN sa.table_inv_locatn.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_inv_locatn.inv_locatn2site IS 'Reserved; not used. Replaced by relation to inv_role';
COMMENT ON COLUMN sa.table_inv_locatn.inv_locatn2parent_loc IS 'For inventory locations, the parent inventory location. Reserved; obsolete-replaced by loc_rol_itm';
COMMENT ON COLUMN sa.table_inv_locatn.gl_locatn2parent_gl IS 'For locations or GL accounts, its related GL account';
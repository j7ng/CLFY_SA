CREATE TABLE sa.table_inv_bin (
  objid NUMBER,
  bin_name VARCHAR2(20 BYTE),
  location_name VARCHAR2(40 BYTE),
  "ACTIVE" NUMBER,
  gl_acct_no VARCHAR2(20 BYTE),
  inv_class NUMBER,
  prior_active NUMBER,
  dev NUMBER,
  id_number VARCHAR2(32 BYTE),
  opened_ind NUMBER,
  fixed_ind NUMBER,
  bin_type NUMBER,
  fixed_bin_name VARCHAR2(20 BYTE),
  inv_bin2inv_locatn NUMBER,
  child2inv_bin NUMBER,
  movable_bin2inv_bin NUMBER,
  inv_bin2inv_ctrl NUMBER
);
ALTER TABLE sa.table_inv_bin ADD SUPPLEMENTAL LOG GROUP dmtsora1081599651_0 ("ACTIVE", bin_name, bin_type, child2inv_bin, dev, fixed_bin_name, fixed_ind, gl_acct_no, id_number, inv_bin2inv_ctrl, inv_bin2inv_locatn, inv_class, location_name, movable_bin2inv_bin, objid, opened_ind, prior_active) ALWAYS;
COMMENT ON TABLE sa.table_inv_bin IS 'A physical or logical location within an inventory location for the storage of parts';
COMMENT ON COLUMN sa.table_inv_bin.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_inv_bin.bin_name IS 'Unique name of the inventory bin within an inventory location';
COMMENT ON COLUMN sa.table_inv_bin.location_name IS 'Name of the inventory location in which the bin is located';
COMMENT ON COLUMN sa.table_inv_bin."ACTIVE" IS 'Indicates whether the bin is in use; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_inv_bin.gl_acct_no IS 'The GL account of the inventory bin. This is the GL account of its parent inventory location';
COMMENT ON COLUMN sa.table_inv_bin.inv_class IS 'Parent inventory location; i.e., 0=an inventory location, 1=a capital GL account, 2=expense GL account';
COMMENT ON COLUMN sa.table_inv_bin.prior_active IS 'Indicates whether the bin was in use prior to being inactivated for physical inventory; i.e., 0=was inactive, 1=was active, default=1';
COMMENT ON COLUMN sa.table_inv_bin.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_inv_bin.id_number IS 'Unique bin number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_inv_bin.opened_ind IS 'Indicates whether the bin allows parts to be moved in/out or not; i.e, 0=no, it s sealed, 1=yes it is opened, default=1';
COMMENT ON COLUMN sa.table_inv_bin.fixed_ind IS 'Indicates whether the bin is movable or not; i.e., 0=no it is fixed, 1=yes, it is moveable, default=0';
COMMENT ON COLUMN sa.table_inv_bin.bin_type IS 'User-defined type of bins; i.e., 0=fixed bin, 1=container, 2=pallet, default=0';
COMMENT ON COLUMN sa.table_inv_bin.fixed_bin_name IS 'For containers, the name of the fixed bin within which the container resides, for fixed bins this field is blank, default=';
COMMENT ON COLUMN sa.table_inv_bin.child2inv_bin IS 'For inventory bins, the child bins';
COMMENT ON COLUMN sa.table_inv_bin.movable_bin2inv_bin IS 'Fixed bin in which the container (moveable bin) is located';
COMMENT ON COLUMN sa.table_inv_bin.inv_bin2inv_ctrl IS 'Inventory control group for the bin';
CREATE TABLE sa.table_count_setup (
  objid NUMBER,
  count_name VARCHAR2(40 BYTE),
  count_descr VARCHAR2(255 BYTE),
  last_mod_date DATE,
  tag_print_date DATE,
  blind_count NUMBER,
  variance_warn NUMBER,
  gl_account VARCHAR2(20 BYTE),
  extra_tags NUMBER,
  status VARCHAR2(40 BYTE),
  count_type VARCHAR2(20 BYTE),
  dev NUMBER,
  cc_ct_date DATE,
  count_id VARCHAR2(30 BYTE),
  cutoff_date DATE,
  cutoff_duration NUMBER,
  last_ct_ind NUMBER,
  profile_type VARCHAR2(20 BYTE),
  setup2cycle_count NUMBER,
  tag_type NUMBER
);
ALTER TABLE sa.table_count_setup ADD SUPPLEMENTAL LOG GROUP dmtsora263791109_0 (blind_count, cc_ct_date, count_descr, count_id, count_name, count_type, cutoff_date, cutoff_duration, dev, extra_tags, gl_account, last_ct_ind, last_mod_date, objid, profile_type, setup2cycle_count, status, tag_print_date, tag_type, variance_warn) ALWAYS;
COMMENT ON TABLE sa.table_count_setup IS 'Describes the count profile for a particular physical inventory reconciliation';
COMMENT ON COLUMN sa.table_count_setup.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_count_setup.count_name IS 'Nameof the count profile';
COMMENT ON COLUMN sa.table_count_setup.count_descr IS 'Description for this count profile';
COMMENT ON COLUMN sa.table_count_setup.last_mod_date IS 'Date this count was last updated';
COMMENT ON COLUMN sa.table_count_setup.tag_print_date IS 'Date the tags for this count were last printed';
COMMENT ON COLUMN sa.table_count_setup.blind_count IS 'Indicates whether the count is blind; i.e., 0=false, 1=true, default=1';
COMMENT ON COLUMN sa.table_count_setup.variance_warn IS 'Indicates whether a blind count posts warning if count entered varies from perpetual; i.e., 0=false, 1=true, default=0';
COMMENT ON COLUMN sa.table_count_setup.gl_account IS 'Default variance GL account for this count reconciliation';
COMMENT ON COLUMN sa.table_count_setup.extra_tags IS 'Quantity of extra tags to be generated for each location/bin';
COMMENT ON COLUMN sa.table_count_setup.status IS 'Internal status of this count';
COMMENT ON COLUMN sa.table_count_setup.count_type IS 'Type of count profile. This is from a user_defined popup list with default name Count Type';
COMMENT ON COLUMN sa.table_count_setup.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_count_setup.cc_ct_date IS 'Date Cycle Count count is to be performed';
COMMENT ON COLUMN sa.table_count_setup.count_id IS 'Unique ID for count profile';
COMMENT ON COLUMN sa.table_count_setup.cutoff_date IS 'Date this count should be completed';
COMMENT ON COLUMN sa.table_count_setup.cutoff_duration IS 'Duration that the count must be completed in';
COMMENT ON COLUMN sa.table_count_setup.last_ct_ind IS 'Indicates whether this is the last count profile for a cycle count; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_count_setup.profile_type IS 'Type of count profile. This is from a Clarify application defined list - Physical, Cycle, Operational';
COMMENT ON COLUMN sa.table_count_setup.setup2cycle_count IS 'Related cycle count';
COMMENT ON COLUMN sa.table_count_setup.tag_type IS 'Indicates type of tag to print; i.e., 0=Tag, 1=Sheet, default=0';
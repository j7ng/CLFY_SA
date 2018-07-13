CREATE TABLE sa.mtm_partclass_x_spf_value_def (
  part_class_id NUMBER,
  spfeaturevalue_def_id NUMBER
);
COMMENT ON TABLE sa.mtm_partclass_x_spf_value_def IS 'Many to Many between part classes and service plans, this is used to determine availability of service plans for a given model and to determine the service plans offered by a sp card.';
COMMENT ON COLUMN sa.mtm_partclass_x_spf_value_def.part_class_id IS 'Reference to objid table_part_class';
COMMENT ON COLUMN sa.mtm_partclass_x_spf_value_def.spfeaturevalue_def_id IS 'Reference to objid in X_SERVICEPLANFEATUREVALUE_DEF';
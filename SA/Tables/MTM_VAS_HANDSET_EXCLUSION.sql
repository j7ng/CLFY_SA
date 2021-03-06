CREATE TABLE sa.mtm_vas_handset_exclusion (
  vas_programs_objid NUMBER,
  part_class_objid NUMBER,
  service_plan_objid NUMBER
);
COMMENT ON TABLE sa.mtm_vas_handset_exclusion IS 'MTM FROM X_VAS_PROGRAMS AND TABLE_PART_CLASS';
COMMENT ON COLUMN sa.mtm_vas_handset_exclusion.vas_programs_objid IS 'FK TO X_VAS_PROGRAMS';
COMMENT ON COLUMN sa.mtm_vas_handset_exclusion.part_class_objid IS 'FK TO TABLE_PART_CLASS';
COMMENT ON COLUMN sa.mtm_vas_handset_exclusion.service_plan_objid IS 'OBJID OF SERVICE PLAN';
CREATE TABLE sa.table_bug (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  id_number VARCHAR2(32 BYTE),
  creation_time DATE,
  initial_desc VARCHAR2(255 BYTE),
  yank_flag NUMBER,
  fixed_date DATE,
  release_rev VARCHAR2(32 BYTE),
  s_release_rev VARCHAR2(32 BYTE),
  ttest_name VARCHAR2(80 BYTE),
  history LONG,
  date_found DATE,
  cclist1 VARCHAR2(255 BYTE),
  cclist2 VARCHAR2(255 BYTE),
  cpu VARCHAR2(20 BYTE),
  os VARCHAR2(20 BYTE),
  "MEMORY" VARCHAR2(20 BYTE),
  attribute1 VARCHAR2(30 BYTE),
  attribute2 VARCHAR2(30 BYTE),
  attribute3 VARCHAR2(30 BYTE),
  attribute4 VARCHAR2(30 BYTE),
  attribute5 VARCHAR2(30 BYTE),
  attribute6 VARCHAR2(30 BYTE),
  attribute7 VARCHAR2(30 BYTE),
  attribute8 VARCHAR2(30 BYTE),
  ownership_stmp DATE,
  modify_stmp DATE,
  dist NUMBER,
  dev NUMBER,
  bug_condit2condition NUMBER(*,0),
  bug_wip2wipbin NUMBER(*,0),
  bug_currq2queue NUMBER(*,0),
  bug_prevq2queue NUMBER(*,0),
  bug_rip2ripbin NUMBER(*,0),
  bug_originator2user NUMBER(*,0),
  bug_owner2user NUMBER(*,0),
  bug_type2gbst_elm NUMBER(*,0),
  bug_priority2gbst_elm NUMBER(*,0),
  bug_sevrity2gbst_elm NUMBER(*,0),
  bug_sts2gbst_elm NUMBER(*,0),
  duplicate_bug2bug NUMBER(*,0),
  bug_domain2gbst_elm NUMBER(*,0),
  bug_class2gbst_elm NUMBER(*,0),
  instalatn2site_part NUMBER(*,0),
  bug_pid2site_part NUMBER(*,0),
  bug_desc2notes_log NUMBER(*,0),
  bug_product2part_info NUMBER(*,0),
  cr_replicate2cr_master NUMBER(*,0),
  cr_replicate2cr_root NUMBER(*,0)
);
ALTER TABLE sa.table_bug ADD SUPPLEMENTAL LOG GROUP dmtsora1508319164_1 (bug_class2gbst_elm, bug_desc2notes_log, bug_domain2gbst_elm, bug_originator2user, bug_owner2user, bug_pid2site_part, bug_priority2gbst_elm, bug_product2part_info, bug_rip2ripbin, bug_sevrity2gbst_elm, bug_sts2gbst_elm, bug_type2gbst_elm, cr_replicate2cr_master, cr_replicate2cr_root, duplicate_bug2bug, instalatn2site_part) ALWAYS;
ALTER TABLE sa.table_bug ADD SUPPLEMENTAL LOG GROUP dmtsora1508319164_0 (attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8, bug_condit2condition, bug_currq2queue, bug_prevq2queue, bug_wip2wipbin, cclist1, cclist2, cpu, creation_time, date_found, dev, dist, fixed_date, id_number, initial_desc, "MEMORY", modify_stmp, objid, os, ownership_stmp, release_rev, s_release_rev, s_title, title, ttest_name, yank_flag) ALWAYS;
COMMENT ON TABLE sa.table_bug IS 'Main change request object';
COMMENT ON COLUMN sa.table_bug.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_bug.title IS 'Title of the change request';
COMMENT ON COLUMN sa.table_bug.id_number IS 'Change request number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_bug.creation_time IS 'Creation date/time of the change request';
COMMENT ON COLUMN sa.table_bug.initial_desc IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.yank_flag IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.fixed_date IS 'Reserved; not used. Use act_entry for the CR s fixed or closed event instead';
COMMENT ON COLUMN sa.table_bug.release_rev IS 'Fixed in release version. A user-defined pop up list with default name FIX RELEASE';
COMMENT ON COLUMN sa.table_bug.ttest_name IS 'Name of test that is to be used to verify the CR';
COMMENT ON COLUMN sa.table_bug.history IS 'History text field for the change request';
COMMENT ON COLUMN sa.table_bug.date_found IS 'Creation_time of the case if the CR was created from a solution for a case';
COMMENT ON COLUMN sa.table_bug.cclist1 IS 'Recipient on carbon copy list #1';
COMMENT ON COLUMN sa.table_bug.cclist2 IS 'Recipient on carbon copy list #2';
COMMENT ON COLUMN sa.table_bug.cpu IS 'CPU the CR was found on. This is from a level of a hierarchical user-defined pop up list with default name CR_DESC and level name CPU';
COMMENT ON COLUMN sa.table_bug.os IS 'Operating System the CR was found on. This is from a level of a hierarchical user-defined pop up list with default name CR_DESC and level name OS';
COMMENT ON COLUMN sa.table_bug."MEMORY" IS 'Memory in the system the CR was found on. This is from a level of a hierarchical user-defined pop up list with default name CR_DESC and level name Memory';
COMMENT ON COLUMN sa.table_bug.attribute1 IS 'Used to store CR Class information. This is a user-defined pop up with default name CR_CLASS';
COMMENT ON COLUMN sa.table_bug.attribute2 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.attribute3 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.attribute4 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.attribute5 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.attribute6 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.attribute7 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.attribute8 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.ownership_stmp IS 'The date and time when ownership changes';
COMMENT ON COLUMN sa.table_bug.modify_stmp IS 'The date and time when object is saved';
COMMENT ON COLUMN sa.table_bug.dist IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_bug.bug_condit2condition IS 'Condition of CR; e.g., open, closed, etc';
COMMENT ON COLUMN sa.table_bug.bug_wip2wipbin IS 'WIPbin into which the CR has been accepted';
COMMENT ON COLUMN sa.table_bug.bug_currq2queue IS 'Queue to which the CR has been dispatched';
COMMENT ON COLUMN sa.table_bug.bug_prevq2queue IS 'Queue to which the CR was previously dispatched';
COMMENT ON COLUMN sa.table_bug.bug_rip2ripbin IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_bug.bug_originator2user IS 'User that created the CR';
COMMENT ON COLUMN sa.table_bug.bug_owner2user IS 'User that currently owns the CR';
COMMENT ON COLUMN sa.table_bug.bug_type2gbst_elm IS 'Relation to pop up list for CR type';
COMMENT ON COLUMN sa.table_bug.bug_priority2gbst_elm IS 'Relation to pop up list for CR priority';
COMMENT ON COLUMN sa.table_bug.bug_sevrity2gbst_elm IS 'Relation to pop up list for CR reproducibility';
COMMENT ON COLUMN sa.table_bug.bug_sts2gbst_elm IS 'Relation to pop up list for CR type. (See bug.attribute1 for CR status)';
COMMENT ON COLUMN sa.table_bug.duplicate_bug2bug IS 'Relation from the duplicate CR to its parent CR';
COMMENT ON COLUMN sa.table_bug.bug_domain2gbst_elm IS 'Relation to pop up list for CR intro phase';
COMMENT ON COLUMN sa.table_bug.bug_class2gbst_elm IS 'Relation to pop up list for CR class';
COMMENT ON COLUMN sa.table_bug.instalatn2site_part IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.bug_pid2site_part IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug.bug_desc2notes_log IS 'CR description is stored in a notes log';
COMMENT ON COLUMN sa.table_bug.bug_product2part_info IS 'Part revision of part selected for CR';
COMMENT ON COLUMN sa.table_bug.cr_replicate2cr_master IS 'Relation from replicate CR to its parent CR';
COMMENT ON COLUMN sa.table_bug.cr_replicate2cr_root IS 'Related top-level-ancestor in a chain of replicated CRs';
CREATE TABLE sa.table_fix_bug (
  objid NUMBER,
  creation_time DATE,
  description LONG,
  dev NUMBER,
  fix_bug2act_entry NUMBER(*,0),
  fxbg_oldstat2gbst_elm NUMBER(*,0),
  fxbg_newstat2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_fix_bug ADD SUPPLEMENTAL LOG GROUP dmtsora1898904508_0 (creation_time, dev, fix_bug2act_entry, fxbg_newstat2gbst_elm, fxbg_oldstat2gbst_elm, objid) ALWAYS;
COMMENT ON TABLE sa.table_fix_bug IS 'Object which records the fixing of a CR';
COMMENT ON COLUMN sa.table_fix_bug.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_fix_bug.creation_time IS 'Date/time the fix was recorded';
COMMENT ON COLUMN sa.table_fix_bug.description IS 'Description of the fix';
COMMENT ON COLUMN sa.table_fix_bug.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_fix_bug.fix_bug2act_entry IS 'Activity log entry for the fix';
COMMENT ON COLUMN sa.table_fix_bug.fxbg_oldstat2gbst_elm IS 'Change request status before fix was recorded';
COMMENT ON COLUMN sa.table_fix_bug.fxbg_newstat2gbst_elm IS 'Change request status after fix was recorded';
CREATE OR REPLACE FORCE VIEW sa.table_probdesc2bug (probdesc_objid,bug_objid,id_number,"CONDITION",s_condition,status,s_status,release_rev,s_release_rev) AS
select table_probdesc.objid, table_bug.objid,
 table_bug.id_number, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_bug.release_rev, table_bug.S_release_rev
 from mtm_probdesc12_bug28, table_probdesc, table_bug, table_condition,
  table_gbst_elm
 where table_condition.objid = table_bug.bug_condit2condition
 AND table_gbst_elm.objid = table_bug.bug_sts2gbst_elm
 AND table_probdesc.objid = mtm_probdesc12_bug28.probdesc2bug
 AND mtm_probdesc12_bug28.bug2probdesc = table_bug.objid 
 ;
COMMENT ON TABLE sa.table_probdesc2bug IS 'Change requests linked to the solution/PD; used by form Solution (321)';
COMMENT ON COLUMN sa.table_probdesc2bug.probdesc_objid IS 'Probdesc internal record number';
COMMENT ON COLUMN sa.table_probdesc2bug.bug_objid IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_probdesc2bug.id_number IS 'Change request number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_probdesc2bug."CONDITION" IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_probdesc2bug.status IS 'Name of CR status';
COMMENT ON COLUMN sa.table_probdesc2bug.release_rev IS 'Fixed in release version';
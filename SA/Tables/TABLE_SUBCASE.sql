CREATE TABLE sa.table_subcase (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  description LONG,
  reopen_flag NUMBER,
  id_number VARCHAR2(32 BYTE),
  required_date DATE,
  creation_time DATE,
  yank_flag NUMBER,
  behavior NUMBER,
  sub_type VARCHAR2(20 BYTE),
  fcs_cc_notify NUMBER,
  ownership_stmp DATE,
  modify_stmp DATE,
  dist NUMBER,
  elapsed_time NUMBER,
  warning_time DATE,
  dev NUMBER,
  subc_prevq2queue NUMBER(*,0),
  subc_currq2queue NUMBER(*,0),
  subc_wip2wipbin NUMBER(*,0),
  subcase2case NUMBER(*,0),
  subc_owner2user NUMBER(*,0),
  subc_state2condition NUMBER(*,0),
  subc_orig2user NUMBER(*,0),
  subc_empl2employee NUMBER(*,0),
  subc_priorty2gbst_elm NUMBER(*,0),
  subc_svrity2gbst_elm NUMBER(*,0),
  subc_casests2gbst_elm NUMBER(*,0),
  subc_rip2ripbin NUMBER(*,0),
  aux_subcase2act_entry NUMBER(*,0),
  subc_gen2cls_factory NUMBER(*,0),
  subcase2job NUMBER(*,0)
);
ALTER TABLE sa.table_subcase ADD SUPPLEMENTAL LOG GROUP dmtsora725158488_0 (aux_subcase2act_entry, behavior, creation_time, dev, dist, elapsed_time, fcs_cc_notify, id_number, modify_stmp, objid, ownership_stmp, reopen_flag, required_date, subcase2case, subcase2job, subc_casests2gbst_elm, subc_currq2queue, subc_empl2employee, subc_gen2cls_factory, subc_orig2user, subc_owner2user, subc_prevq2queue, subc_priorty2gbst_elm, subc_rip2ripbin, subc_state2condition, subc_svrity2gbst_elm, subc_wip2wipbin, sub_type, s_title, title, warning_time, yank_flag) ALWAYS;
COMMENT ON TABLE sa.table_subcase IS 'Subcase object which contains info on a task that is being delegated and commitment date for that task';
COMMENT ON COLUMN sa.table_subcase.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_subcase.title IS 'Subcase title';
COMMENT ON COLUMN sa.table_subcase.description IS 'Subcase description';
COMMENT ON COLUMN sa.table_subcase.reopen_flag IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_subcase.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_subcase.required_date IS 'Date and time task must be completed';
COMMENT ON COLUMN sa.table_subcase.creation_time IS 'The date and time the subcase was created';
COMMENT ON COLUMN sa.table_subcase.yank_flag IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_subcase.behavior IS 'Internal field indicating the behavior of the subcase type; i.e., 1=normal, 2=administrative subcase';
COMMENT ON COLUMN sa.table_subcase.sub_type IS 'Subcase type; general or administrative';
COMMENT ON COLUMN sa.table_subcase.fcs_cc_notify IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_subcase.ownership_stmp IS 'The date and time when ownership changes';
COMMENT ON COLUMN sa.table_subcase.modify_stmp IS 'The date and time when object is saved';
COMMENT ON COLUMN sa.table_subcase.dist IS 'Used by Task mgr for auto-generation preview; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_subcase.elapsed_time IS 'Elapsed time in seconds';
COMMENT ON COLUMN sa.table_subcase.warning_time IS 'Date and time of commitment warning';
COMMENT ON COLUMN sa.table_subcase.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_subcase.subc_prevq2queue IS 'Previous queue; used in temporary accept to record previous queue subcase was in';
COMMENT ON COLUMN sa.table_subcase.subc_currq2queue IS 'Queue subcase is dispatched to';
COMMENT ON COLUMN sa.table_subcase.subc_wip2wipbin IS 'WIPbin that subcase is accepted into';
COMMENT ON COLUMN sa.table_subcase.subcase2case IS 'Parent case';
COMMENT ON COLUMN sa.table_subcase.subc_owner2user IS 'User that owns subcase';
COMMENT ON COLUMN sa.table_subcase.subc_state2condition IS 'Subcase condition';
COMMENT ON COLUMN sa.table_subcase.subc_orig2user IS 'User that originated the subcase';
COMMENT ON COLUMN sa.table_subcase.subc_empl2employee IS 'Employee who created the subcase';
COMMENT ON COLUMN sa.table_subcase.subc_priorty2gbst_elm IS 'Subcase priority; defined as a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_subcase.subc_svrity2gbst_elm IS 'Subcase severity; defined as a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_subcase.subc_casests2gbst_elm IS 'Subcase status; defined as a Clarify-defined pop up list associated with each type of condition';
COMMENT ON COLUMN sa.table_subcase.subc_rip2ripbin IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase.aux_subcase2act_entry IS 'When a subcase is created there is a subcase-create activity log entry in the parent case.  The entry is related to the subcase created';
COMMENT ON COLUMN sa.table_subcase.subc_gen2cls_factory IS 'Template from which the subcase was generated';
COMMENT ON COLUMN sa.table_subcase.subcase2job IS 'Job which is tracking the subcase';
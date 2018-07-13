CREATE TABLE sa.table_onsite_log (
  objid NUMBER,
  creation_time DATE,
  last_modified DATE,
  billable_exp NUMBER(19,4),
  non_bill_exp NUMBER(19,4),
  total_exp NUMBER(19,4),
  notes LONG,
  resolution VARCHAR2(30 BYTE),
  internal_note VARCHAR2(255 BYTE),
  perf_by VARCHAR2(30 BYTE),
  billable_time NUMBER,
  non_bill_time NUMBER,
  total_time NUMBER,
  removed NUMBER,
  billable_mtl NUMBER(19,4),
  non_bill_mtl NUMBER(19,4),
  total_mtl NUMBER(19,4),
  billable_lbr NUMBER(19,4),
  non_bill_lbr NUMBER(19,4),
  total_lbr NUMBER(19,4),
  dev NUMBER,
  case_onsite2case NUMBER(*,0),
  subc_onsite2subcase NUMBER(*,0),
  disfe_onsit2disptchfe NUMBER(*,0),
  onsite_owner2user NUMBER(*,0),
  onsite_doer2employee NUMBER(*,0),
  detail_onsite2demand_dtl NUMBER(*,0),
  onsite_log2exchange NUMBER,
  onsite_log2part_inst NUMBER
);
ALTER TABLE sa.table_onsite_log ADD SUPPLEMENTAL LOG GROUP dmtsora194028873_0 (billable_exp, billable_lbr, billable_mtl, billable_time, case_onsite2case, creation_time, detail_onsite2demand_dtl, dev, disfe_onsit2disptchfe, internal_note, last_modified, non_bill_exp, non_bill_lbr, non_bill_mtl, non_bill_time, objid, onsite_doer2employee, onsite_log2exchange, onsite_log2part_inst, onsite_owner2user, perf_by, removed, resolution, subc_onsite2subcase, total_exp, total_lbr, total_mtl, total_time) ALWAYS;
COMMENT ON TABLE sa.table_onsite_log IS 'Log used for summarizing a users time/expenses/and or materials consumed for a case, a subcase, or a parts request; e.g., onsite time, materials, etc';
COMMENT ON COLUMN sa.table_onsite_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_onsite_log.creation_time IS 'Date and time the T&E log was created';
COMMENT ON COLUMN sa.table_onsite_log.last_modified IS 'Date and time T&E log was last modified';
COMMENT ON COLUMN sa.table_onsite_log.billable_exp IS 'Total T&E log expenses that are billable';
COMMENT ON COLUMN sa.table_onsite_log.non_bill_exp IS 'Total T&E log expenses that are not billable';
COMMENT ON COLUMN sa.table_onsite_log.total_exp IS 'Total non-billable and billable expenses';
COMMENT ON COLUMN sa.table_onsite_log.notes IS 'T&E log notes';
COMMENT ON COLUMN sa.table_onsite_log.resolution IS 'Resolution code for T&E log. From user-defined pop up with default name RESOLUTION_CODE';
COMMENT ON COLUMN sa.table_onsite_log.internal_note IS 'Notes intended for internal use only';
COMMENT ON COLUMN sa.table_onsite_log.perf_by IS 'Login name of the Person that performs the T&E task';
COMMENT ON COLUMN sa.table_onsite_log.billable_time IS 'Total T&E log elapsed time that is billable in seconds';
COMMENT ON COLUMN sa.table_onsite_log.non_bill_time IS 'Total T&E log elapsed time that is not billable in seconds';
COMMENT ON COLUMN sa.table_onsite_log.total_time IS 'Total elapsed time, both billable and non-billable in seconds';
COMMENT ON COLUMN sa.table_onsite_log.removed IS 'Indicates the logical removal of the log object; i.e., 0=present, 1=removed, default=0';
COMMENT ON COLUMN sa.table_onsite_log.billable_mtl IS 'Total material costs that are billable';
COMMENT ON COLUMN sa.table_onsite_log.non_bill_mtl IS 'Total material costs that are not billable';
COMMENT ON COLUMN sa.table_onsite_log.total_mtl IS 'Total non-billable and billable material costs';
COMMENT ON COLUMN sa.table_onsite_log.billable_lbr IS 'Total billable labor costs';
COMMENT ON COLUMN sa.table_onsite_log.non_bill_lbr IS 'Total non-billable labor costs';
COMMENT ON COLUMN sa.table_onsite_log.total_lbr IS 'Total non-billable and billable labor costs';
COMMENT ON COLUMN sa.table_onsite_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_onsite_log.case_onsite2case IS 'Related case';
COMMENT ON COLUMN sa.table_onsite_log.subc_onsite2subcase IS 'Related subcase';
COMMENT ON COLUMN sa.table_onsite_log.disfe_onsit2disptchfe IS 'Related FE dispatch';
COMMENT ON COLUMN sa.table_onsite_log.onsite_owner2user IS 'User that originated the T&E log';
COMMENT ON COLUMN sa.table_onsite_log.onsite_doer2employee IS 'Employee who performed task; used if different from the user logging the information';
COMMENT ON COLUMN sa.table_onsite_log.detail_onsite2demand_dtl IS 'Related part request';
COMMENT ON COLUMN sa.table_onsite_log.onsite_log2exchange IS 'Related exchange';
COMMENT ON COLUMN sa.table_onsite_log.onsite_log2part_inst IS 'Related part instance';
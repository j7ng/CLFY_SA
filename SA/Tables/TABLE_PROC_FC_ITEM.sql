CREATE TABLE sa.table_proc_fc_item (
  objid NUMBER,
  dev NUMBER,
  "ID" VARCHAR2(80 BYTE),
  fc_start DATE,
  fc_end DATE,
  actual_start DATE,
  actual_end DATE,
  ov_start DATE,
  ov_end DATE,
  override NUMBER,
  is_milestone NUMBER,
  iter_seqno NUMBER,
  fc_item2proc_forecast NUMBER,
  fc_item2func_group NUMBER,
  fc_item2group_inst NUMBER,
  fc_item2svc_rqst NUMBER,
  fc_item2rqst_inst NUMBER
);
ALTER TABLE sa.table_proc_fc_item ADD SUPPLEMENTAL LOG GROUP dmtsora367675169_0 (actual_end, actual_start, dev, fc_end, fc_item2func_group, fc_item2group_inst, fc_item2proc_forecast, fc_item2rqst_inst, fc_item2svc_rqst, fc_start, "ID", is_milestone, iter_seqno, objid, override, ov_end, ov_start) ALWAYS;
COMMENT ON TABLE sa.table_proc_fc_item IS 'Records forecast times for a group instance or an action instance';
COMMENT ON COLUMN sa.table_proc_fc_item.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_proc_fc_item.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_proc_fc_item."ID" IS 'Id from definition or instance - updated at actual end time';
COMMENT ON COLUMN sa.table_proc_fc_item.fc_start IS 'Forecast start time';
COMMENT ON COLUMN sa.table_proc_fc_item.fc_end IS 'Forecast end time';
COMMENT ON COLUMN sa.table_proc_fc_item.actual_start IS 'Actual start time, copied from relevent instance on creation';
COMMENT ON COLUMN sa.table_proc_fc_item.actual_end IS 'Actual end time, copied from relevent instance on completion';
COMMENT ON COLUMN sa.table_proc_fc_item.ov_start IS 'Override start time - set by user to reset forecast dates';
COMMENT ON COLUMN sa.table_proc_fc_item.ov_end IS 'Override end time - set by user to reset forecast dates';
COMMENT ON COLUMN sa.table_proc_fc_item.override IS '0=ignore override dates, 1 = use override dates';
COMMENT ON COLUMN sa.table_proc_fc_item.is_milestone IS '0 = No, 1 = Completion of this group is a milestone in the process';
COMMENT ON COLUMN sa.table_proc_fc_item.iter_seqno IS 'Sequence number of this sequential iteration group';
COMMENT ON COLUMN sa.table_proc_fc_item.fc_item2proc_forecast IS 'The related forecast instance';
COMMENT ON COLUMN sa.table_proc_fc_item.fc_item2func_group IS 'For group forecasts, the related definition';
COMMENT ON COLUMN sa.table_proc_fc_item.fc_item2group_inst IS 'For group forecasts, the related instanace';
COMMENT ON COLUMN sa.table_proc_fc_item.fc_item2svc_rqst IS 'For action forecasts, the related definition';
COMMENT ON COLUMN sa.table_proc_fc_item.fc_item2rqst_inst IS 'For action forecasts, the related instance';
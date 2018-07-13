CREATE TABLE sa.table_x79provider_tr (
  objid NUMBER,
  dev NUMBER,
  received_time VARCHAR2(30 BYTE),
  tr_found NUMBER,
  rpt_id VARCHAR2(32 BYTE),
  s_rpt_id VARCHAR2(32 BYTE),
  "STATE" NUMBER,
  closeout_narr VARCHAR2(255 BYTE),
  s_closeout_narr VARCHAR2(255 BYTE),
  mgd_obj_inst VARCHAR2(64 BYTE),
  s_mgd_obj_inst VARCHAR2(64 BYTE),
  status NUMBER,
  status_time VARCHAR2(30 BYTE),
  tr_type NUMBER,
  activity_dur NUMBER,
  restored_time VARCHAR2(30 BYTE),
  addl_trouble LONG,
  server_id NUMBER,
  clrd2x79person NUMBER,
  coord2x79person NUMBER,
  p_abt2x79service NUMBER,
  p_on2x79service NUMBER,
  ptr2x79trfmt_defn NUMBER
);
ALTER TABLE sa.table_x79provider_tr ADD SUPPLEMENTAL LOG GROUP dmtsora236353383_0 (activity_dur, closeout_narr, clrd2x79person, coord2x79person, dev, mgd_obj_inst, objid, ptr2x79trfmt_defn, p_abt2x79service, p_on2x79service, received_time, restored_time, rpt_id, server_id, "STATE", status, status_time, s_closeout_narr, s_mgd_obj_inst, s_rpt_id, tr_found, tr_type) ALWAYS;
COMMENT ON TABLE sa.table_x79provider_tr IS 'Represents an instance of a trouble report. Reserved; future';
COMMENT ON COLUMN sa.table_x79provider_tr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x79provider_tr.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x79provider_tr.received_time IS 'The creation time of the Provider Trouble Report managed object instance; generalized time ';
COMMENT ON COLUMN sa.table_x79provider_tr.tr_found IS 'When the trouble report enters the cleared state, attribute will be set: e.g., 0=pending, 1=came clear 2=central office; 3=switch trouble;, etc';
COMMENT ON COLUMN sa.table_x79provider_tr.rpt_id IS 'Identifier of the trouble report';
COMMENT ON COLUMN sa.table_x79provider_tr."STATE" IS 'State of the trouble report; i.e., 0=queued; 1=open active; 2=deferred cleared, 3=closed, 4=closed; 5=disabled';
COMMENT ON COLUMN sa.table_x79provider_tr.closeout_narr IS 'The Close Out Narrative attribute specifies additional information about the problem';
COMMENT ON COLUMN sa.table_x79provider_tr.mgd_obj_inst IS 'Identifies the managed object instance which had the trouble';
COMMENT ON COLUMN sa.table_x79provider_tr.status IS 'Status of the trouble report: e.g.,  1=screening, 2=testing, 3=dispatched in, 4=dispatched out';
COMMENT ON COLUMN sa.table_x79provider_tr.status_time IS 'Date and time the report entered the current status; x790 generalized time';
COMMENT ON COLUMN sa.table_x79provider_tr.tr_type IS 'Numeric code expressing the indicated trouble';
COMMENT ON COLUMN sa.table_x79provider_tr.activity_dur IS 'Total elapsed time of the repair activity in seconds';
COMMENT ON COLUMN sa.table_x79provider_tr.restored_time IS 'Date and time service was restored; x790 generalized time';
COMMENT ON COLUMN sa.table_x79provider_tr.addl_trouble IS 'Additional trouble information';
COMMENT ON COLUMN sa.table_x79provider_tr.server_id IS 'Exchange protocol server ID number';
COMMENT ON COLUMN sa.table_x79provider_tr.clrd2x79person IS 'Contact who cleared the trouble report';
COMMENT ON COLUMN sa.table_x79provider_tr.coord2x79person IS 'Contact who coordinated the trouble report';
COMMENT ON COLUMN sa.table_x79provider_tr.p_abt2x79service IS 'The network service the report was filed against';
COMMENT ON COLUMN sa.table_x79provider_tr.p_on2x79service IS 'The network service identifed as having the trouble';
COMMENT ON COLUMN sa.table_x79provider_tr.ptr2x79trfmt_defn IS 'Related trouble report format definition';
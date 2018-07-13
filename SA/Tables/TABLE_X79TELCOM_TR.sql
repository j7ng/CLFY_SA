CREATE TABLE sa.table_x79telcom_tr (
  objid NUMBER,
  dev NUMBER,
  received_time VARCHAR2(30 BYTE),
  tr_found NUMBER,
  rpt_id VARCHAR2(32 BYTE),
  s_rpt_id VARCHAR2(32 BYTE),
  "STATE" NUMBER,
  closeout_narr VARCHAR2(255 BYTE),
  s_closeout_narr VARCHAR2(255 BYTE),
  status NUMBER,
  status_time VARCHAR2(30 BYTE),
  tr_type NUMBER,
  restored_time VARCHAR2(30 BYTE),
  a_hrs_ind NUMBER,
  closeout_ver NUMBER,
  called_number VARCHAR2(64 BYTE),
  s_called_number VARCHAR2(64 BYTE),
  cancel_mgr_ind NUMBER,
  commit_type NUMBER,
  commit_time VARCHAR2(30 BYTE),
  req_cmmt_type NUMBER,
  dialog VARCHAR2(64 BYTE),
  s_dialog VARCHAR2(64 BYTE),
  cust_wrk_ctr VARCHAR2(64 BYTE),
  s_cust_wrk_ctr VARCHAR2(64 BYTE),
  cust_ttr_num VARCHAR2(64 BYTE),
  s_cust_ttr_num VARCHAR2(64 BYTE),
  init_mode NUMBER,
  last_update VARCHAR2(30 BYTE),
  m_org_ct_time VARCHAR2(30 BYTE),
  m_svc_chg_ind NUMBER,
  m_srch_key_1 VARCHAR2(64 BYTE),
  s_m_srch_key_1 VARCHAR2(64 BYTE),
  m_srch_key_2 VARCHAR2(64 BYTE),
  s_m_srch_key_2 VARCHAR2(64 BYTE),
  m_srch_key_3 VARCHAR2(64 BYTE),
  s_m_srch_key_3 VARCHAR2(64 BYTE),
  detected_time VARCHAR2(30 BYTE),
  tsp_priority VARCHAR2(2 BYTE),
  p_severity NUMBER,
  pf_priority NUMBER,
  repeat_report NUMBER,
  req_cmmt_time VARCHAR2(30 BYTE),
  server_id NUMBER,
  hand_off_ctr VARCHAR2(64 BYTE),
  s_hand_off_ctr VARCHAR2(64 BYTE),
  hand_off_loc VARCHAR2(64 BYTE),
  s_hand_off_loc VARCHAR2(64 BYTE),
  hand_off_time VARCHAR2(30 BYTE),
  outage_dur NUMBER,
  m_obj_fm_time VARCHAR2(30 BYTE),
  m_obj_to_time VARCHAR2(30 BYTE),
  status_window NUMBER,
  service_name VARCHAR2(255 BYTE),
  s_service_name VARCHAR2(255 BYTE),
  local_ind NUMBER,
  tr_found_ind NUMBER,
  tr_type_ind NUMBER,
  p_severity_ind NUMBER,
  status_ind NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  about2x79service NUMBER,
  on2x79service NUMBER,
  ttr2x79trfmt_defn NUMBER
);
ALTER TABLE sa.table_x79telcom_tr ADD SUPPLEMENTAL LOG GROUP dmtsora1291521638_0 (a_hrs_ind, called_number, cancel_mgr_ind, closeout_narr, closeout_ver, commit_time, commit_type, cust_ttr_num, cust_wrk_ctr, dev, dialog, init_mode, last_update, m_org_ct_time, m_srch_key_1, m_svc_chg_ind, objid, received_time, req_cmmt_type, restored_time, rpt_id, "STATE", status, status_time, s_called_number, s_closeout_narr, s_cust_ttr_num, s_cust_wrk_ctr, s_dialog, s_m_srch_key_1, s_rpt_id, tr_found, tr_type) ALWAYS;
ALTER TABLE sa.table_x79telcom_tr ADD SUPPLEMENTAL LOG GROUP dmtsora1291521638_1 (about2x79service, detected_time, hand_off_ctr, hand_off_loc, hand_off_time, local_ind, m_obj_fm_time, m_obj_to_time, m_srch_key_2, m_srch_key_3, on2x79service, outage_dur, pf_priority, p_severity, p_severity_ind, repeat_report, req_cmmt_time, server_id, service_name, status_ind, status_window, s_hand_off_ctr, s_hand_off_loc, s_m_srch_key_2, s_m_srch_key_3, s_service_name, s_title, title, tr_found_ind, tr_type_ind, tsp_priority, ttr2x79trfmt_defn) ALWAYS;
COMMENT ON TABLE sa.table_x79telcom_tr IS 'Represents an instance of a trouble report. Reserved; future';
COMMENT ON COLUMN sa.table_x79telcom_tr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x79telcom_tr.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x79telcom_tr.received_time IS 'The creation time of the Provider Trouble Report managed object instance; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.tr_found IS 'When the trouble report enters the cleared state, attribute will be set: e.g., 0=pending, 1=came clear 2=central office; 3=switch trouble;, etc';
COMMENT ON COLUMN sa.table_x79telcom_tr.rpt_id IS 'Identifier of the trouble report';
COMMENT ON COLUMN sa.table_x79telcom_tr."STATE" IS 'State of the trouble report; i.e., 0=queued; 1=open active; 2=deferred cleared, 3=closed, 4=closed; 5=disabled';
COMMENT ON COLUMN sa.table_x79telcom_tr.closeout_narr IS 'The Close Out Narrative attribute specifies additional information about the problem';
COMMENT ON COLUMN sa.table_x79telcom_tr.status IS 'Status of the trouble report: e.g.,  1=screening, 2=testing, 3=dispatched in, 4=dispatched out';
COMMENT ON COLUMN sa.table_x79telcom_tr.status_time IS 'Date and time the report entered the current status; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.tr_type IS 'Numeric code expressing the indicated trouble';
COMMENT ON COLUMN sa.table_x79telcom_tr.restored_time IS 'Date and time service was restored; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.a_hrs_ind IS 'Indicates whether customer has given the OK to repair after hours; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.closeout_ver IS 'Indicates whether the manager has verified repair completion; i.e., 0=no action, 1=verified, 2=denied, 3=denied-activity duration disputed, 4=denied--closeout narrative disputed';
COMMENT ON COLUMN sa.table_x79telcom_tr.called_number IS 'Specified the number being called at the time of trouble detection';
COMMENT ON COLUMN sa.table_x79telcom_tr.cancel_mgr_ind IS 'Indicates whether the manager has initiated the process to cancel the trouble report; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.commit_type IS 'Indicates the type time committed by the Agent; i.e., 0=onsite time; 1=cleared time, default=0 ';
COMMENT ON COLUMN sa.table_x79telcom_tr.commit_time IS 'Date and time committed by the Agent for the commit_type; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.req_cmmt_type IS 'Indicates the type time requested by the customer; i.e., 0=onsite time; 1=cleared time, default=0 ';
COMMENT ON COLUMN sa.table_x79telcom_tr.dialog IS 'Holds free-form text by Manager or Agent which can be updated at any stage of the relsolution';
COMMENT ON COLUMN sa.table_x79telcom_tr.cust_wrk_ctr IS 'Identifies the manager work center from which the trouble was entered';
COMMENT ON COLUMN sa.table_x79telcom_tr.cust_ttr_num IS 'Contains the customer s internal trouble ticket number';
COMMENT ON COLUMN sa.table_x79telcom_tr.init_mode IS 'Source of the trouble ticket; i.e., 0=mgrDirect, 1=mgrIndirect, 3=agentOriginated, 4=mgrIndirectEMail, 5=mgrIndirectFax, 6=mgrDirectPersonal, 7=mgrIndirectPhone, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.last_update IS 'Date and time of most recent update to the trouble report by either manager or agent; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.m_org_ct_time IS 'The date and time at which the maintenance organization was contacted by the agent and requested to repair the trouble; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.m_svc_chg_ind IS 'Indicates, once determined, whether the customer will be charged for the maintence; i.e., 0=no or not yet determined, 1=yes, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.m_srch_key_1 IS 'Enables the manager to filter trouble reports; e.g., accoun ID, customer ID';
COMMENT ON COLUMN sa.table_x79telcom_tr.m_srch_key_2 IS 'Enables the manager to filter trouble reports; e.g., accoun ID, customer ID';
COMMENT ON COLUMN sa.table_x79telcom_tr.m_srch_key_3 IS 'Enables the manager to filter trouble reports; e.g., accoun ID, customer ID';
COMMENT ON COLUMN sa.table_x79telcom_tr.detected_time IS 'The date and time when the trouble was detected; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.tsp_priority IS 'Conveys TSP codes between manager and agent if applicable';
COMMENT ON COLUMN sa.table_x79telcom_tr.p_severity IS 'Perceived trouble severity; i.e., 0=out of service, 1=back in service, 2=service impairment, 3=non-service affecting trouble, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.pf_priority IS 'Preferred priority-the urgency with which the manager requires resolution of the problem; 0=undefined, 1=minor, 2=major, 3=serious, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.repeat_report IS 'Whether there has been activity on the managed object recently; i.e., 0=unspecified, 1=recent installation, 2=repeat, 3=installation and repeat, 4=chronic, 5=installation and chronic, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.req_cmmt_time IS 'Commitment time requested by the customer; x790 generalized time';
COMMENT ON COLUMN sa.table_x79telcom_tr.server_id IS 'Exchange protocol server ID number';
COMMENT ON COLUMN sa.table_x79telcom_tr.hand_off_ctr IS 'Identifies the service provider s control center to which a trouble report has been referred';
COMMENT ON COLUMN sa.table_x79telcom_tr.hand_off_loc IS 'Identifies the location within a service provider control center to which a trouble report has been referred ';
COMMENT ON COLUMN sa.table_x79telcom_tr.hand_off_time IS 'Gives the date and time the hand off occurred';
COMMENT ON COLUMN sa.table_x79telcom_tr.outage_dur IS 'Elapsed time of the outage in seconds';
COMMENT ON COLUMN sa.table_x79telcom_tr.m_obj_fm_time IS 'The FROM time for repair access to the managed object. May be used in lieu of x79interval';
COMMENT ON COLUMN sa.table_x79telcom_tr.m_obj_to_time IS 'The TO time for repair access to the managed object. May be used in lieu of x79interval';
COMMENT ON COLUMN sa.table_x79telcom_tr.status_window IS 'States the maximum interval allowed (in seconds) between the Agent s notifications of progress';
COMMENT ON COLUMN sa.table_x79telcom_tr.service_name IS 'Stores the fully distinguished name of the x79service which the trouble ticket was opened against';
COMMENT ON COLUMN sa.table_x79telcom_tr.local_ind IS 'Indicates whether the TTR was originated locally or not; i.e., 0=no (originated remotely), 1=yes, default=1';
COMMENT ON COLUMN sa.table_x79telcom_tr.tr_found_ind IS 'Indicates the exchange data type of field tr_found; i.e., 0=string, 1=integer, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.tr_type_ind IS 'Indicates the exchange data type of field tr_type; i.e., 0=string, 1=integer, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.p_severity_ind IS 'Indicates the exchange data type of field p_severity; i.e., 0=string, 1=integer, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.status_ind IS 'Indicates the exchange data type of field status; i.e., 0=string, 1=integer, default=0';
COMMENT ON COLUMN sa.table_x79telcom_tr.title IS 'Title of the corresponding case on the Manager s system';
COMMENT ON COLUMN sa.table_x79telcom_tr.about2x79service IS 'The network service the report was filed against';
COMMENT ON COLUMN sa.table_x79telcom_tr.on2x79service IS 'The network service identifed as having the trouble';
COMMENT ON COLUMN sa.table_x79telcom_tr.ttr2x79trfmt_defn IS 'Related trouble report format definition';
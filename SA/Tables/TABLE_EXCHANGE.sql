CREATE TABLE sa.table_exchange (
  objid NUMBER,
  dist_mode NUMBER,
  dist_role NUMBER,
  ref_id VARCHAR2(255 BYTE),
  s_ref_id VARCHAR2(255 BYTE),
  current_state NUMBER,
  xref_last VARCHAR2(30 BYTE),
  xref_first VARCHAR2(30 BYTE),
  xref_phone VARCHAR2(20 BYTE),
  xref_fax VARCHAR2(20 BYTE),
  xref_email VARCHAR2(80 BYTE),
  rpt_last VARCHAR2(30 BYTE),
  rpt_first VARCHAR2(30 BYTE),
  rpt_phone VARCHAR2(20 BYTE),
  rpt_fax VARCHAR2(20 BYTE),
  rpt_email VARCHAR2(80 BYTE),
  contract_id VARCHAR2(40 BYTE),
  ack_action NUMBER,
  "PRIORITY" NUMBER,
  create_date DATE,
  modify_stmp DATE,
  product VARCHAR2(255 BYTE),
  ack_state NUMBER,
  ack_reason NUMBER,
  ack_ind NUMBER,
  entitle_ind NUMBER,
  confirm_ind NUMBER,
  lack_ind NUMBER,
  wait_ind NUMBER,
  response_time VARCHAR2(30 BYTE),
  workflow_status VARCHAR2(30 BYTE),
  requestor_severity NUMBER,
  prob_ind NUMBER,
  request_date DATE,
  commit_date DATE,
  exchange_id VARCHAR2(255 BYTE),
  dev NUMBER,
  partner2site NUMBER(*,0),
  exchange2case NUMBER(*,0),
  exchange2contract NUMBER(*,0),
  a_hrs_ind NUMBER,
  auth_act_type NUMBER,
  cancel_req_ind NUMBER,
  close_out_verif NUMBER,
  cmt_date_type NUMBER,
  init_mode NUMBER,
  last_close2close_exch NUMBER,
  m_org_ct_time DATE,
  m_svc_chg_ind NUMBER,
  onsite_date DATE,
  onsite_req_date DATE,
  outage_dur NUMBER,
  prfd_priority NUMBER,
  received_time DATE,
  ref_ind NUMBER,
  repeat_report NUMBER,
  req_act_type NUMBER,
  req_date_type NUMBER,
  restore_time DATE,
  status_window NUMBER,
  trouble_found NUMBER,
  trouble_type NUMBER,
  tsp_priority NUMBER
);
ALTER TABLE sa.table_exchange ADD SUPPLEMENTAL LOG GROUP dmtsora289762124_0 (ack_action, ack_ind, ack_reason, ack_state, confirm_ind, contract_id, create_date, current_state, dist_mode, dist_role, entitle_ind, lack_ind, modify_stmp, objid, "PRIORITY", prob_ind, product, ref_id, requestor_severity, response_time, rpt_email, rpt_fax, rpt_first, rpt_last, rpt_phone, s_ref_id, wait_ind, workflow_status, xref_email, xref_fax, xref_first, xref_last, xref_phone) ALWAYS;
ALTER TABLE sa.table_exchange ADD SUPPLEMENTAL LOG GROUP dmtsora289762124_1 (auth_act_type, a_hrs_ind, cancel_req_ind, close_out_verif, cmt_date_type, commit_date, dev, exchange2case, exchange2contract, exchange_id, init_mode, last_close2close_exch, m_org_ct_time, m_svc_chg_ind, onsite_date, onsite_req_date, outage_dur, partner2site, prfd_priority, received_time, ref_ind, repeat_report, request_date, req_act_type, req_date_type, restore_time, status_window, trouble_found, trouble_type, tsp_priority) ALWAYS;
COMMENT ON TABLE sa.table_exchange IS 'Represents the exchange of a request for service between service provider and service requestor';
COMMENT ON COLUMN sa.table_exchange.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_exchange.dist_mode IS 'The distribution mode; i.e., 0=unknown, 1=transfer, 2=collaborative';
COMMENT ON COLUMN sa.table_exchange.dist_role IS 'Indicates role in the distribution of the object; i.e., 0=initiator, 1=recipient';
COMMENT ON COLUMN sa.table_exchange.ref_id IS 'Identifier of the exchange partner s corresponding object';
COMMENT ON COLUMN sa.table_exchange.current_state IS 'Reflects the current state of the distributed object in my virtual machine. Map data exchange protocol state values to codes';
COMMENT ON COLUMN sa.table_exchange.xref_last IS 'Last name of the current owner working on the exchange case in the partner s system';
COMMENT ON COLUMN sa.table_exchange.xref_first IS 'First name of the current owner working on the exchange case in the partner s system';
COMMENT ON COLUMN sa.table_exchange.xref_phone IS 'Phone number of the current user/owner working on the exchange case in the partner s system which includes area code, number and extension';
COMMENT ON COLUMN sa.table_exchange.xref_fax IS 'Fax number of the current user/owner working on the exchange case in the partner s system which includes area code, number and extension';
COMMENT ON COLUMN sa.table_exchange.xref_email IS 'Email address of the current user/owner working on the exchange case in the partner s system';
COMMENT ON COLUMN sa.table_exchange.rpt_last IS 'Original reporting site contact. Contact s last name';
COMMENT ON COLUMN sa.table_exchange.rpt_first IS 'Original reporting site contact. Contact s first name';
COMMENT ON COLUMN sa.table_exchange.rpt_phone IS 'Original reporting site phone which includes area code, number and extension';
COMMENT ON COLUMN sa.table_exchange.rpt_fax IS 'Original reporting site fax number which includes area code, number and extension';
COMMENT ON COLUMN sa.table_exchange.rpt_email IS 'Original e-mail address';
COMMENT ON COLUMN sa.table_exchange.contract_id IS 'Contract ID number from display/edit field. Does not supersede relation to contract object';
COMMENT ON COLUMN sa.table_exchange.ack_action IS 'Describes the acknowledgment action; i.e., 0=reject, 1=accept';
COMMENT ON COLUMN sa.table_exchange."PRIORITY" IS 'Local priority of the exchanged incident. Default=1';
COMMENT ON COLUMN sa.table_exchange.create_date IS 'The date and time the object was created';
COMMENT ON COLUMN sa.table_exchange.modify_stmp IS 'The date and time the object was last modified';
COMMENT ON COLUMN sa.table_exchange.product IS 'Customer-defined popup with default name Exchange Product supplies the exchanged product';
COMMENT ON COLUMN sa.table_exchange.ack_state IS 'Describes the acknowledgment status; i.e., 0=no acknowledgement required, 1=service requested, 2=problem submitted, 3=closure submitted, default=0';
COMMENT ON COLUMN sa.table_exchange.ack_reason IS 'Describes the acknowledgment sub status; i.e., 0=OK, 1=no contract, 2=contract expired, 3=product not covered; 4=site not covered, 5=product not found, default=0';
COMMENT ON COLUMN sa.table_exchange.ack_ind IS 'Indicates acknowledgment of the problem submission; i.e., 0=no acknowledgement 1=acknowleged, default=0';
COMMENT ON COLUMN sa.table_exchange.entitle_ind IS 'Indicates entitlement for service of the problem submission; i.e., 0=no entitlement 1=entitled, default=0. This is the internal entitlement state';
COMMENT ON COLUMN sa.table_exchange.confirm_ind IS 'Indicates confirmation of close for the problem submission; i.e., 0=not confirmed 1=confimed, default=0';
COMMENT ON COLUMN sa.table_exchange.lack_ind IS 'Indicates whether information from requestor is lacking; i.e., 0=not lacking 1=is lacking, default=0';
COMMENT ON COLUMN sa.table_exchange.wait_ind IS 'Indicates waiting for confirmation of close for the problem submission; i.e., 0=not waiting 1=waiting, default=0';
COMMENT ON COLUMN sa.table_exchange.response_time IS 'Promised/desired response time to the customer';
COMMENT ON COLUMN sa.table_exchange.workflow_status IS 'What the status of this incident is according to the workflow';
COMMENT ON COLUMN sa.table_exchange.requestor_severity IS 'The severity of the problem as defined by the requester; Values must be in the range 1-5 with 1 being most sever. Default=1';
COMMENT ON COLUMN sa.table_exchange.prob_ind IS 'Indicates if a problem has been submitted; 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_exchange.request_date IS 'Requestor s desired completion date and time';
COMMENT ON COLUMN sa.table_exchange.commit_date IS 'Provider s committed completion date and time';
COMMENT ON COLUMN sa.table_exchange.exchange_id IS 'System-generated unique identifier of the exchange';
COMMENT ON COLUMN sa.table_exchange.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_exchange.exchange2contract IS 'Contract used for exchange entitlement';
COMMENT ON COLUMN sa.table_exchange.a_hrs_ind IS 'Customer OK to repair the service outside of normal business hours; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_exchange.auth_act_type IS 'Currently authorized activities, which is a bitstring with positions:0=after hrs repair; 1=standby; 2=after hrs standby; 3=test; 4=manager initiated; 5=distatched; 6=no-access; 7=delayed maintenance; 8=release';
COMMENT ON COLUMN sa.table_exchange.cancel_req_ind IS 'Indicates whether the manager has initiated the process to cancel a trouble report; i.e, 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_exchange.close_out_verif IS 'Whether the manager has verified repair completion, denied repair completion or take no action; i.e., 0=no action, 1=denied repair, 2=verified repair, default=0';
COMMENT ON COLUMN sa.table_exchange.cmt_date_type IS 'Code giving the type of time committed by the Provider; i.e., 0=unspecified; 1=cleared time, 2=onsite_time, default=0';
COMMENT ON COLUMN sa.table_exchange.init_mode IS 'Mode of initiation of the trouble report; i.e., 0=managerDirect, 1=managerIndirect, 2=agentOriginated, 4=managerIndirectEMail, 5=managerIndirectFax, 6=managerIndirectPersonal, 7=managerIndirectPhone, default=0';
COMMENT ON COLUMN sa.table_exchange.last_close2close_exch IS 'Most recent closing summary for the exchange';
COMMENT ON COLUMN sa.table_exchange.m_org_ct_time IS 'The date and time at which the maintenance organization was contacted by the agent and requested to repair the trouble';
COMMENT ON COLUMN sa.table_exchange.m_svc_chg_ind IS 'Indicates, once determined, whether the customer will be charged for the maintence; i.e., 0=no or not yet determined, 1=yes, default=0';
COMMENT ON COLUMN sa.table_exchange.onsite_date IS 'Used for  requesting onsite time';
COMMENT ON COLUMN sa.table_exchange.onsite_req_date IS 'Used for  requesting onsite time';
COMMENT ON COLUMN sa.table_exchange.outage_dur IS 'Derived. The amount of time between when the trouble was cleared when it was received excluding any times for delayed maintenance. Stored in seconds';
COMMENT ON COLUMN sa.table_exchange.prfd_priority IS 'X790--manager s prefered priority for the trouble; i.e., 0=undefined, 1=minor, 2=major, 3=serious, default=0';
COMMENT ON COLUMN sa.table_exchange.received_time IS 'The date and time when a trouble report was entered';
COMMENT ON COLUMN sa.table_exchange.ref_ind IS 'Indicates that the this is the reference exchange for defining default contacts/person reaches for any future exchange on the case; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_exchange.repeat_report IS 'Code giving previous actions/history on the service; i.e.,0=unspecified, 1=recent installation, 2=repeat, 3=both installation and repeat, 4=chronic, 5=both instalation and chronic';
COMMENT ON COLUMN sa.table_exchange.req_act_type IS 'Currently requested authorized activities, which is a bitstring with positions:0=after hrs repair; 1=standby; 2=after hrs standby; 3=test; 4=manager initiated; 5=distatched; 6=no-access; 7=delayed maintenance; 8=release';
COMMENT ON COLUMN sa.table_exchange.req_date_type IS 'The type of time the request_date/commit_date field is representing; i.e., 0=unspecified; 1=cleared time, 2=onsite_time, default=0';
COMMENT ON COLUMN sa.table_exchange.restore_time IS 'The date and time that the trouble was cleared. This may be different than the time that the clear event is exchanged';
COMMENT ON COLUMN sa.table_exchange.status_window IS 'States the maximum interval allowed (in seconds) between the Agent s notifications of progress';
COMMENT ON COLUMN sa.table_exchange.trouble_found IS 'X790--the actual cause of the trouble found; i.e., 0=pending, 1=cameClear, 2=centralOffice, 3=serious, default=0';
COMMENT ON COLUMN sa.table_exchange.trouble_type IS 'X790--the category of trouble that is being reported on a CNM Service or managed object; e.g., 100=noDialToneGroup, 101=noDialTone, etc., default=0';
COMMENT ON COLUMN sa.table_exchange.tsp_priority IS 'Government defined Telecommunication Service Priority codes';
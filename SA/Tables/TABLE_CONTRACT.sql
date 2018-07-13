CREATE TABLE sa.table_contract (
  objid NUMBER,
  "ID" VARCHAR2(40 BYTE),
  s_id VARCHAR2(40 BYTE),
  "TYPE" VARCHAR2(30 BYTE),
  po_number VARCHAR2(40 BYTE),
  s_po_number VARCHAR2(40 BYTE),
  start_date DATE,
  expire_date DATE,
  unit_type VARCHAR2(30 BYTE),
  units_purch NUMBER,
  units_used NUMBER,
  units_avail NUMBER,
  phone_resp NUMBER,
  onsite_resp NUMBER,
  status VARCHAR2(30 BYTE),
  notes VARCHAR2(255 BYTE),
  hours_for_pm VARCHAR2(30 BYTE),
  spec_consid NUMBER,
  pay_options VARCHAR2(30 BYTE),
  alert_ind NUMBER,
  "VERSION" VARCHAR2(10 BYTE),
  q_start_date DATE,
  quote_dur NUMBER,
  terms_cond VARCHAR2(40 BYTE),
  contr_dur VARCHAR2(40 BYTE),
  renew_prior NUMBER,
  total_tax_amt NUMBER(19,4),
  total_net NUMBER(19,4),
  total_gross NUMBER(19,4),
  arch_ind NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  q_end_date DATE,
  evergreen_ind NUMBER,
  renew_notf_ind NUMBER,
  sched_ind NUMBER,
  fsvc_end_date DATE,
  close_eff_dt DATE,
  close_crdt_ind NUMBER,
  last_update DATE,
  last_xfer DATE,
  q_issue_dt DATE,
  warr_set_ind NUMBER,
  dflt_start_dt DATE,
  dflt_end_dt DATE,
  renew_ntfy_dt DATE,
  ready_to_bill NUMBER,
  struct_type NUMBER,
  create_dt DATE,
  dev NUMBER,
  owner2user NUMBER(*,0),
  contract2condition NUMBER(*,0),
  status2gbst_elm NUMBER(*,0),
  contract2currency NUMBER(*,0),
  contract2admin NUMBER(*,0),
  contr_originator2user NUMBER(*,0),
  contr_prevq2queue NUMBER(*,0),
  contr_currq2queue NUMBER(*,0),
  contr_wip2wipbin NUMBER(*,0),
  primary2contact NUMBER(*,0),
  sell_to2bus_org NUMBER(*,0),
  contr_quote2opportunity NUMBER(*,0),
  last_save_dt DATE,
  ord_submit_dt DATE,
  tot_ship_amt NUMBER(19,4),
  handling_cost NUMBER(19,4),
  order_status VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_contract ADD SUPPLEMENTAL LOG GROUP dmtsora368615191_0 (alert_ind, arch_ind, contr_dur, expire_date, hours_for_pm, "ID", notes, objid, onsite_resp, pay_options, phone_resp, po_number, quote_dur, q_end_date, q_start_date, renew_prior, spec_consid, start_date, status, s_id, s_po_number, s_title, terms_cond, title, total_gross, total_net, total_tax_amt, "TYPE", units_avail, units_purch, units_used, unit_type, "VERSION") ALWAYS;
ALTER TABLE sa.table_contract ADD SUPPLEMENTAL LOG GROUP dmtsora368615191_1 (close_crdt_ind, close_eff_dt, contract2admin, contract2condition, contract2currency, contr_currq2queue, contr_originator2user, contr_prevq2queue, contr_quote2opportunity, contr_wip2wipbin, create_dt, dev, dflt_end_dt, dflt_start_dt, evergreen_ind, fsvc_end_date, handling_cost, last_save_dt, last_update, last_xfer, ord_submit_dt, owner2user, primary2contact, q_issue_dt, ready_to_bill, renew_notf_ind, renew_ntfy_dt, sched_ind, sell_to2bus_org, status2gbst_elm, struct_type, tot_ship_amt, warr_set_ind) ALWAYS;
ALTER TABLE sa.table_contract ADD SUPPLEMENTAL LOG GROUP dmtsora368615191_2 (order_status) ALWAYS;
COMMENT ON TABLE sa.table_contract IS 'Contract Manager Contract, Service Contract, Sales Quote, eOrder, and Shopping List header object';
COMMENT ON COLUMN sa.table_contract.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_contract."ID" IS 'Unique Identifier of the contract/quote/order/shipping list';
COMMENT ON COLUMN sa.table_contract."TYPE" IS 'The specific nature of the contract-standard. This is a user-defined pop up list with default name of CONTRACT_TYPE';
COMMENT ON COLUMN sa.table_contract.po_number IS 'The purchase order number that was used to originally start the contract coverage';
COMMENT ON COLUMN sa.table_contract.start_date IS 'The date the object becames/became effective. Where line items are involved, this is the begin effective date of the earliest line item';
COMMENT ON COLUMN sa.table_contract.expire_date IS 'The date the object ends. Where line items are involved, this is the ending service date of the latest line item';
COMMENT ON COLUMN sa.table_contract.unit_type IS 'The type of units the object is delivered in; e.g., days, calls, hours, visits, etc';
COMMENT ON COLUMN sa.table_contract.units_purch IS 'The number of units that were purchased in the object';
COMMENT ON COLUMN sa.table_contract.units_used IS 'The number of units that have been used by the object';
COMMENT ON COLUMN sa.table_contract.units_avail IS 'The number of units that are currently available for use';
COMMENT ON COLUMN sa.table_contract.phone_resp IS 'The elapsed time within which a service rep is required by the object to contact the customer via phone in seconds';
COMMENT ON COLUMN sa.table_contract.onsite_resp IS 'The elapsed time within which a field engineer is required by the object to arrive at the customer site in seconds';
COMMENT ON COLUMN sa.table_contract.status IS 'The current status of the object. This is a user-defined pop up with name depending on struct_type';
COMMENT ON COLUMN sa.table_contract.notes IS 'Notes that pertain to the object; used with special considerations flag';
COMMENT ON COLUMN sa.table_contract.hours_for_pm IS 'Specific hours that preventative maintenance procedures may be performed';
COMMENT ON COLUMN sa.table_contract.spec_consid IS 'Flag that indicates special circumstances; causes contract form to be automatically posted when contract is selected for a new case';
COMMENT ON COLUMN sa.table_contract.pay_options IS 'Specifies the method of payment for the object';
COMMENT ON COLUMN sa.table_contract.alert_ind IS 'When set to 1, indicates there is an alert related to the site';
COMMENT ON COLUMN sa.table_contract."VERSION" IS 'Version number of the object';
COMMENT ON COLUMN sa.table_contract.q_start_date IS 'The start date for the object. This is the date the offer becomes effective';
COMMENT ON COLUMN sa.table_contract.quote_dur IS 'The length of time from the start_date in seconds that the object prices are effective';
COMMENT ON COLUMN sa.table_contract.terms_cond IS 'User-defined terms and conditions. This is a user-defined popup with default name Terms and Conditions';
COMMENT ON COLUMN sa.table_contract.contr_dur IS 'The user defined duration for the object. This is from a user-defined popup';
COMMENT ON COLUMN sa.table_contract.renew_prior IS 'Number of days to be subtracted from fsvc_end_date to yield renew_ntfy_dt';
COMMENT ON COLUMN sa.table_contract.total_tax_amt IS 'The sum of all taxes applied to the object';
COMMENT ON COLUMN sa.table_contract.total_net IS 'Total net price for the object (see struct_type)';
COMMENT ON COLUMN sa.table_contract.total_gross IS 'Total gross price for the object';
COMMENT ON COLUMN sa.table_contract.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_contract.title IS 'Title of the object';
COMMENT ON COLUMN sa.table_contract.q_end_date IS 'The end date for the object. This is the last date the offer or agreement is effective';
COMMENT ON COLUMN sa.table_contract.evergreen_ind IS 'Indicates whether the object is to be auto-renewed; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contract.renew_notf_ind IS 'Indicates whether the object needs renewal notification; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_contract.sched_ind IS 'Indicates whether the object has exactly one schedule; i.e., 0=no, 1=yes, default=1. Reserved; not used';
COMMENT ON COLUMN sa.table_contract.fsvc_end_date IS 'The end date of earliest ending renewable service under the contract. Used for renewal of contracts. Accommodates non-coterminous contracts';
COMMENT ON COLUMN sa.table_contract.close_eff_dt IS 'The date the object was closed';
COMMENT ON COLUMN sa.table_contract.close_crdt_ind IS 'Indicates whether or not to issue credit upon premature close; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contract.last_update IS 'Date time of last update to the object';
COMMENT ON COLUMN sa.table_contract.last_xfer IS 'Date time of last transfer to trans_record. Reserved; obsolete';
COMMENT ON COLUMN sa.table_contract.q_issue_dt IS 'The date the object was issued to the prospect';
COMMENT ON COLUMN sa.table_contract.warr_set_ind IS 'Indicates whether or not te set line item start dates to end of part warranty date; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contract.dflt_start_dt IS 'The default start date of contracted service for all line items';
COMMENT ON COLUMN sa.table_contract.dflt_end_dt IS 'The default last day of contracted service for all line items';
COMMENT ON COLUMN sa.table_contract.renew_ntfy_dt IS 'Date on which renewal notification is to be sent.  Calculated from renew_cycle and fsvc_end_date';
COMMENT ON COLUMN sa.table_contract.ready_to_bill IS 'If the contract is ready for new billing record generation it will be set to 1';
COMMENT ON COLUMN sa.table_contract.struct_type IS 'The record type of the object; i.e., 0=service contract, 1=sales item, 2=eOrder, 3=shopping list';
COMMENT ON COLUMN sa.table_contract.create_dt IS 'The create date of the object';
COMMENT ON COLUMN sa.table_contract.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_contract.owner2user IS 'Current owner of the object';
COMMENT ON COLUMN sa.table_contract.contract2condition IS 'State in the life-cycle of the object';
COMMENT ON COLUMN sa.table_contract.status2gbst_elm IS 'Status of the object';
COMMENT ON COLUMN sa.table_contract.contract2currency IS 'Currency object is denominated in';
COMMENT ON COLUMN sa.table_contract.contract2admin IS 'Current administrator of the object';
COMMENT ON COLUMN sa.table_contract.contr_originator2user IS 'User that originated the object';
COMMENT ON COLUMN sa.table_contract.contr_prevq2queue IS 'Used to record which queue the object was accepted from; for temporary accept';
COMMENT ON COLUMN sa.table_contract.contr_currq2queue IS 'Queue the object is dispatched to';
COMMENT ON COLUMN sa.table_contract.contr_wip2wipbin IS 'WIPbin for the object';
COMMENT ON COLUMN sa.table_contract.primary2contact IS 'Primary contact for the sale';
COMMENT ON COLUMN sa.table_contract.sell_to2bus_org IS 'The sell-to account';
COMMENT ON COLUMN sa.table_contract.contr_quote2opportunity IS 'Related opportunities';
COMMENT ON COLUMN sa.table_contract.last_save_dt IS 'Date the object was last saved';
COMMENT ON COLUMN sa.table_contract.ord_submit_dt IS 'Date the order was submitted';
COMMENT ON COLUMN sa.table_contract.tot_ship_amt IS 'The sum of all shipping charges for the object';
COMMENT ON COLUMN sa.table_contract.handling_cost IS 'The sum of all handling costs for the object';
COMMENT ON COLUMN sa.table_contract.order_status IS 'Quote/Order status';
CREATE TABLE sa.table_opportunity (
  objid NUMBER,
  "ID" VARCHAR2(32 BYTE),
  s_id VARCHAR2(32 BYTE),
  objective VARCHAR2(255 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  proj_name VARCHAR2(50 BYTE),
  purch_date DATE,
  comm_status NUMBER,
  comm_pct NUMBER,
  comm_amt NUMBER,
  rtng_teles NUMBER,
  rtng_telem NUMBER,
  rtng_flds NUMBER,
  comp_psn VARCHAR2(40 BYTE),
  rtng_cmnt VARCHAR2(255 BYTE),
  cust_need VARCHAR2(255 BYTE),
  strengths VARCHAR2(255 BYTE),
  weaknesses VARCHAR2(255 BYTE),
  date_ident DATE,
  next_steps VARCHAR2(255 BYTE),
  frcst_cls_dt DATE,
  frcst_cls_amount NUMBER(19,4),
  frcst_cls_prb NUMBER,
  frcst_cls_cmt VARCHAR2(255 BYTE),
  frcst_cls_cfd VARCHAR2(50 BYTE),
  quantity VARCHAR2(25 BYTE),
  win_result NUMBER,
  arch_ind NUMBER,
  dev NUMBER,
  opp_state2condition NUMBER(*,0),
  opp_wip2wipbin NUMBER(*,0),
  opp_currq2queue NUMBER(*,0),
  opp_prevq2queue NUMBER(*,0),
  opp_originator2user NUMBER(*,0),
  opp_owner2user NUMBER(*,0),
  opp_sts2gbst_elm NUMBER(*,0),
  opp2currency NUMBER(*,0),
  opp2life_cycle NUMBER(*,0),
  opp2lead_source NUMBER(*,0),
  opp2territory NUMBER(*,0),
  opp2cycle_stage NUMBER(*,0),
  commission NUMBER(19,4),
  update_stamp DATE
);
ALTER TABLE sa.table_opportunity ADD SUPPLEMENTAL LOG GROUP dmtsora209975185_0 (arch_ind, comm_amt, comm_pct, comm_status, comp_psn, cust_need, date_ident, dev, frcst_cls_amount, frcst_cls_cfd, frcst_cls_cmt, frcst_cls_dt, frcst_cls_prb, "ID", "NAME", next_steps, objective, objid, opp_currq2queue, opp_state2condition, opp_wip2wipbin, proj_name, purch_date, quantity, rtng_cmnt, rtng_flds, rtng_telem, rtng_teles, strengths, s_id, s_name, weaknesses, win_result) ALWAYS;
ALTER TABLE sa.table_opportunity ADD SUPPLEMENTAL LOG GROUP dmtsora209975185_1 (commission, opp2currency, opp2cycle_stage, opp2lead_source, opp2life_cycle, opp2territory, opp_originator2user, opp_owner2user, opp_prevq2queue, opp_sts2gbst_elm, update_stamp) ALWAYS;
COMMENT ON TABLE sa.table_opportunity IS 'Contains information about a potential business transaction with a prospect or customer';
COMMENT ON COLUMN sa.table_opportunity.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_opportunity."ID" IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_opportunity.objective IS 'Sales objective for this opportunity';
COMMENT ON COLUMN sa.table_opportunity."NAME" IS 'Name given to the opportunity';
COMMENT ON COLUMN sa.table_opportunity.proj_name IS 'Customer s project name for the opportunity';
COMMENT ON COLUMN sa.table_opportunity.purch_date IS 'When the opportunity is expected to close';
COMMENT ON COLUMN sa.table_opportunity.comm_status IS 'Status of the commission; i.e., 0=unpaid, 1=partial, 2=paid';
COMMENT ON COLUMN sa.table_opportunity.comm_pct IS 'Commission percentage';
COMMENT ON COLUMN sa.table_opportunity.comm_amt IS 'Amount of the commission. Reserved; obsolete';
COMMENT ON COLUMN sa.table_opportunity.rtng_teles IS 'The telesales rating';
COMMENT ON COLUMN sa.table_opportunity.rtng_telem IS 'The telemarketing rating';
COMMENT ON COLUMN sa.table_opportunity.rtng_flds IS 'The field sales rating';
COMMENT ON COLUMN sa.table_opportunity.comp_psn IS 'How we rank in the opportunity as compared to our competitor. This is a user-defined pop up';
COMMENT ON COLUMN sa.table_opportunity.rtng_cmnt IS 'Comments about the various ratings';
COMMENT ON COLUMN sa.table_opportunity.cust_need IS 'What the customer actually needs';
COMMENT ON COLUMN sa.table_opportunity.strengths IS 'Company strengths within the opportunity';
COMMENT ON COLUMN sa.table_opportunity.weaknesses IS 'Company vulnerabilities within the opportunity';
COMMENT ON COLUMN sa.table_opportunity.date_ident IS 'Date the opportunity was identified. Reserved; not used';
COMMENT ON COLUMN sa.table_opportunity.next_steps IS 'What needs to happen next';
COMMENT ON COLUMN sa.table_opportunity.frcst_cls_dt IS 'Forecasted close date';
COMMENT ON COLUMN sa.table_opportunity.frcst_cls_amount IS 'Forecasted close amount';
COMMENT ON COLUMN sa.table_opportunity.frcst_cls_prb IS 'Forecasted close probability';
COMMENT ON COLUMN sa.table_opportunity.frcst_cls_cmt IS 'Forecast close comments';
COMMENT ON COLUMN sa.table_opportunity.frcst_cls_cfd IS 'Forecast close confidence-the degree of confidence in the forecasts';
COMMENT ON COLUMN sa.table_opportunity.quantity IS 'Statement of the quantities involved with the opportunity';
COMMENT ON COLUMN sa.table_opportunity.win_result IS 'For closed opportunities, the win/loss result; i.e., 0=unknown/open, 1=won, 2=lost';
COMMENT ON COLUMN sa.table_opportunity.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_opportunity.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_opportunity.opp_state2condition IS 'The condition of the opportunity';
COMMENT ON COLUMN sa.table_opportunity.opp_wip2wipbin IS 'WIPbin into which the opportunity has been accepted';
COMMENT ON COLUMN sa.table_opportunity.opp_currq2queue IS 'Queue to which the opportunity has been dispatched';
COMMENT ON COLUMN sa.table_opportunity.opp_prevq2queue IS 'Queue to which the opportunity was previously dispatched';
COMMENT ON COLUMN sa.table_opportunity.opp_originator2user IS 'User that created the opportunity';
COMMENT ON COLUMN sa.table_opportunity.opp_owner2user IS 'User that currently owns the opportunity';
COMMENT ON COLUMN sa.table_opportunity.opp_sts2gbst_elm IS 'Status of the opportunity object';
COMMENT ON COLUMN sa.table_opportunity.opp2currency IS 'Currency in which the opportunity is denominated';
COMMENT ON COLUMN sa.table_opportunity.opp2life_cycle IS 'Life cycle to which the opportunity belongs';
COMMENT ON COLUMN sa.table_opportunity.opp2lead_source IS 'Related lead source';
COMMENT ON COLUMN sa.table_opportunity.opp2territory IS 'Territory to which the opportunity is assigned';
COMMENT ON COLUMN sa.table_opportunity.opp2cycle_stage IS 'Stage of the sales cycle';
COMMENT ON COLUMN sa.table_opportunity.commission IS 'Commission amount for the opportunity. Reserved; future';
COMMENT ON COLUMN sa.table_opportunity.update_stamp IS 'Date/time of last update to the opportunity';
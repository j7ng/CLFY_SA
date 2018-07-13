CREATE TABLE sa.table_contr_schedule (
  objid NUMBER,
  schedule_id VARCHAR2(40 BYTE),
  s_schedule_id VARCHAR2(40 BYTE),
  schedule_title VARCHAR2(80 BYTE),
  gross_line_pr NUMBER(19,4),
  net_line_pr NUMBER(19,4),
  sched_adj_amt NUMBER(19,4),
  sched_tax_pct NUMBER(19,4),
  sched_tax_amt NUMBER(19,4),
  sched_net_amt NUMBER(19,4),
  fob VARCHAR2(40 BYTE),
  close_eff_dt DATE,
  close_crdt_ind NUMBER,
  last_update DATE,
  last_xfer DATE,
  start_dt DATE,
  due_offset NUMBER,
  frequency NUMBER,
  invc_terms VARCHAR2(80 BYTE),
  bill_group VARCHAR2(30 BYTE),
  bill_option NUMBER,
  itm_start_dt DATE,
  itm_end_dt DATE,
  cycle_start_dt DATE,
  ship_attn VARCHAR2(30 BYTE),
  s_ship_attn VARCHAR2(30 BYTE),
  ship_attn2 VARCHAR2(40 BYTE),
  s_ship_attn2 VARCHAR2(40 BYTE),
  bill_attn VARCHAR2(30 BYTE),
  s_bill_attn VARCHAR2(30 BYTE),
  bill_attn2 VARCHAR2(40 BYTE),
  s_bill_attn2 VARCHAR2(40 BYTE),
  fsvc_end_dt DATE,
  fsvc_start_dt DATE,
  lsvc_end_dt DATE,
  cycle_chg_ind NUMBER,
  ship_via VARCHAR2(80 BYTE),
  dev NUMBER,
  schedule2contract NUMBER(*,0),
  bill_to2site NUMBER(*,0),
  ship_to2site NUMBER(*,0),
  default_prog2price_prog NUMBER(*,0),
  bill_addr2address NUMBER(*,0),
  ship_addr2address NUMBER(*,0),
  handling_cost NUMBER(19,4),
  item_count NUMBER,
  last_p_line_no NUMBER,
  ship_amt NUMBER(19,4),
  total_grand NUMBER(19,4)
);
ALTER TABLE sa.table_contr_schedule ADD SUPPLEMENTAL LOG GROUP dmtsora1049501713_1 (bill_addr2address, bill_to2site, cycle_chg_ind, default_prog2price_prog, dev, fsvc_start_dt, handling_cost, item_count, last_p_line_no, lsvc_end_dt, schedule2contract, ship_addr2address, ship_amt, ship_to2site, ship_via, total_grand) ALWAYS;
ALTER TABLE sa.table_contr_schedule ADD SUPPLEMENTAL LOG GROUP dmtsora1049501713_0 (bill_attn, bill_attn2, bill_group, bill_option, close_crdt_ind, close_eff_dt, cycle_start_dt, due_offset, fob, frequency, fsvc_end_dt, gross_line_pr, invc_terms, itm_end_dt, itm_start_dt, last_update, last_xfer, net_line_pr, objid, schedule_id, schedule_title, sched_adj_amt, sched_net_amt, sched_tax_amt, sched_tax_pct, ship_attn, ship_attn2, start_dt, s_bill_attn, s_bill_attn2, s_schedule_id, s_ship_attn, s_ship_attn2) ALWAYS;
COMMENT ON TABLE sa.table_contr_schedule IS 'Contract or quote schedule object';
COMMENT ON COLUMN sa.table_contr_schedule.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_contr_schedule.schedule_id IS 'Unique-within contract/order/quote object identifier';
COMMENT ON COLUMN sa.table_contr_schedule.schedule_title IS 'Contract schedule short description';
COMMENT ON COLUMN sa.table_contr_schedule.gross_line_pr IS 'Sum of all related line item gross prices';
COMMENT ON COLUMN sa.table_contr_schedule.net_line_pr IS 'Sum of all related line item net prices';
COMMENT ON COLUMN sa.table_contr_schedule.sched_adj_amt IS 'Net of amount of schedule-level adjustments';
COMMENT ON COLUMN sa.table_contr_schedule.sched_tax_pct IS 'Tax percentage applied to the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.sched_tax_amt IS 'Tax amount applied to the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.sched_net_amt IS 'Net_line_pr adjusted by Sched_adj_amt';
COMMENT ON COLUMN sa.table_contr_schedule.fob IS 'Identifies the FOB for the schedule. This is a user-defined popup with default name FOB';
COMMENT ON COLUMN sa.table_contr_schedule.close_eff_dt IS 'If the schedule is prematurely closed, the date when the close becomes effective';
COMMENT ON COLUMN sa.table_contr_schedule.close_crdt_ind IS 'Indicates whether or not to issue credit upon premature close; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contr_schedule.last_update IS 'Date time of last update to the schedule/quote';
COMMENT ON COLUMN sa.table_contr_schedule.last_xfer IS 'Date time of last transfer to trans_record';
COMMENT ON COLUMN sa.table_contr_schedule.start_dt IS 'The start date of the billing';
COMMENT ON COLUMN sa.table_contr_schedule.due_offset IS 'The number of days in advance of the expected payment date that determines the invoice date';
COMMENT ON COLUMN sa.table_contr_schedule.frequency IS 'Frequency of the billing: i.e., 0=annual, 1=semi-annual, 2=quarterly, 3=monthly, 4=one-time, default=0';
COMMENT ON COLUMN sa.table_contr_schedule.invc_terms IS 'Billing terms to appear on the invoice';
COMMENT ON COLUMN sa.table_contr_schedule.bill_group IS 'Billing group. This is from a user-defined popup list with default name BILLING_GROUP';
COMMENT ON COLUMN sa.table_contr_schedule.bill_option IS 'Billing option; i.e., 0=in advance, 1=in arrears';
COMMENT ON COLUMN sa.table_contr_schedule.itm_start_dt IS 'The earliest contr_itm.chg_start_dt among all contr_itm related to the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.itm_end_dt IS 'The latest contr_itm.chg_end_dt among all contr_itm related to the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.cycle_start_dt IS 'The starting date of the billing cycle. Used with schedule frequency to calculate the periodic as of billing dates';
COMMENT ON COLUMN sa.table_contr_schedule.ship_attn IS 'First name of the person shipment will be directed to';
COMMENT ON COLUMN sa.table_contr_schedule.ship_attn2 IS 'Last name of the person shipment will be directed to';
COMMENT ON COLUMN sa.table_contr_schedule.bill_attn IS 'First name of the person billing will be directed to';
COMMENT ON COLUMN sa.table_contr_schedule.bill_attn2 IS 'Last name of the person billing will be directed to';
COMMENT ON COLUMN sa.table_contr_schedule.fsvc_end_dt IS 'The earliest service end date among all contr_itm related to the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.fsvc_start_dt IS 'The earliest service start date among all contr_itm related to the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.lsvc_end_dt IS 'The latest service end date among all contr_itm related to the schedule ';
COMMENT ON COLUMN sa.table_contr_schedule.cycle_chg_ind IS 'Billing cycle change indicator; i.e., 0=not changed, 1=changed. Used to signal that the schedule needs to be re-amortized';
COMMENT ON COLUMN sa.table_contr_schedule.ship_via IS 'Requested means of shipment. This is from a Clarify-defined popup list with default name SHIP_VIA';
COMMENT ON COLUMN sa.table_contr_schedule.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_contr_schedule.bill_to2site IS 'Identifies the bill-to site for the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.ship_to2site IS 'Identifies the ship-to site for the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.default_prog2price_prog IS 'Identifies the default price schedule for the contract schedule';
COMMENT ON COLUMN sa.table_contr_schedule.bill_addr2address IS 'Identifies the billing address for the contract schedule';
COMMENT ON COLUMN sa.table_contr_schedule.ship_addr2address IS 'Identifies the shipping address for the contract schedule';
COMMENT ON COLUMN sa.table_contr_schedule.handling_cost IS 'The sum of all handling costs for the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.item_count IS 'The number of lines in the schedule, parent and child included';
COMMENT ON COLUMN sa.table_contr_schedule.last_p_line_no IS 'Value of p_line_no assigned to the last related contr_itm';
COMMENT ON COLUMN sa.table_contr_schedule.ship_amt IS 'The sum of all shipping charges applied to the schedule';
COMMENT ON COLUMN sa.table_contr_schedule.total_grand IS 'Sum of the sched_net_amt, sched_tax_amt, ship_amt, and handling_cost fields on the schedule.  It represents the sum total of all charges, surcharges, and discounts of the contr_schedule. Used where contract.struct_type=2';
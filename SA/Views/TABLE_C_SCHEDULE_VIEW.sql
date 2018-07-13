CREATE OR REPLACE FORCE VIEW sa.table_c_schedule_view (objid,schedule_id,s_schedule_id,schedule_title,gross_line_pr,net_line_pr,sched_adj_amt,sched_tax_pct,sched_tax_amt,sched_net_amt,fob,close_eff_dt,close_crdt_ind,last_update,last_xfer,start_dt,due_offset,frequency,invc_terms,bill_group,bill_option,price_prog_name,s_price_prog_name,price_prog_desc,price_prog_type,price_prog_eff_dt,price_prog_exp_dt,price_prog_active,site_id,site_name,s_site_name,contract_objid,chg_start_dt,chg_end_dt) AS
select table_contr_schedule.objid, table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id,
 table_contr_schedule.schedule_title, table_contr_schedule.gross_line_pr,
 table_contr_schedule.net_line_pr, table_contr_schedule.sched_adj_amt,
 table_contr_schedule.sched_tax_pct, table_contr_schedule.sched_tax_amt,
 table_contr_schedule.sched_net_amt, table_contr_schedule.fob,
 table_contr_schedule.close_eff_dt, table_contr_schedule.close_crdt_ind,
 table_contr_schedule.last_update, table_contr_schedule.last_xfer,
 table_contr_schedule.start_dt, table_contr_schedule.due_offset,
 table_contr_schedule.frequency, table_contr_schedule.invc_terms,
 table_contr_schedule.bill_group, table_contr_schedule.bill_option,
 table_price_prog.name, table_price_prog.S_name, table_price_prog.description,
 table_price_prog.type, table_price_prog.effective_date,
 table_price_prog.expire_date, table_price_prog.active,
 table_site.site_id, table_site.name, table_site.S_name,
 table_contr_schedule.schedule2contract, table_contr_schedule.itm_start_dt,
 table_contr_schedule.itm_end_dt
 from table_contr_schedule, table_price_prog, table_site
 where table_site.objid (+) = table_contr_schedule.bill_to2site
 AND table_price_prog.objid (+) = table_contr_schedule.default_prog2price_prog
 AND table_contr_schedule.schedule2contract IS NOT NULL
 ;
COMMENT ON TABLE sa.table_c_schedule_view IS 'Used by forms Contract (9133), Contract <ID> (9134), Line Items (9136, 9675), Schedules (9137, 9676), Payment Options (9141, 9677), Quote (9162, 9673) and others';
COMMENT ON COLUMN sa.table_c_schedule_view.objid IS 'Contr_schedule internal record number';
COMMENT ON COLUMN sa.table_c_schedule_view.schedule_id IS 'Contract ID number';
COMMENT ON COLUMN sa.table_c_schedule_view.schedule_title IS 'Contract schedule short description';
COMMENT ON COLUMN sa.table_c_schedule_view.gross_line_pr IS 'Sum of all related line item gross prices for the schedule';
COMMENT ON COLUMN sa.table_c_schedule_view.net_line_pr IS 'Sum of all related line item adjusted prices for the schedule';
COMMENT ON COLUMN sa.table_c_schedule_view.sched_adj_amt IS 'Net of related line item price adjustments. Reserved; not used';
COMMENT ON COLUMN sa.table_c_schedule_view.sched_tax_pct IS 'Total tax percentage applied to the schedule';
COMMENT ON COLUMN sa.table_c_schedule_view.sched_tax_amt IS 'Placeholder for any tax amount applied to the schedule';
COMMENT ON COLUMN sa.table_c_schedule_view.sched_net_amt IS 'Net of all price adjustments applied directly to the schedule';
COMMENT ON COLUMN sa.table_c_schedule_view.fob IS 'Identifies the FOB for the schedule';
COMMENT ON COLUMN sa.table_c_schedule_view.close_eff_dt IS 'If the schedule is prematurely closed, the date when the close becomes effective';
COMMENT ON COLUMN sa.table_c_schedule_view.close_crdt_ind IS 'Indicates whether or not to issue credit upon premature close; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_c_schedule_view.last_update IS 'Date time of last update to the schedule/quote';
COMMENT ON COLUMN sa.table_c_schedule_view.last_xfer IS 'Date time of last transfer to trans_record';
COMMENT ON COLUMN sa.table_c_schedule_view.start_dt IS 'The start date of the billing';
COMMENT ON COLUMN sa.table_c_schedule_view.due_offset IS 'The number of days in advance of the expected payment date that determines the invoice date';
COMMENT ON COLUMN sa.table_c_schedule_view.frequency IS 'Frequency of the billing: i.e., 0=annual, 1=semi-annual,2=quarterly,3=monthly,4=one-time, default=0';
COMMENT ON COLUMN sa.table_c_schedule_view.invc_terms IS 'Billing terms to appear on the invoice';
COMMENT ON COLUMN sa.table_c_schedule_view.bill_group IS 'Billing group. This is from a user-defined popup list with default name BILLING_GROUP';
COMMENT ON COLUMN sa.table_c_schedule_view.bill_option IS 'Billing option; i.e., 1=in advance, 2=in arrears';
COMMENT ON COLUMN sa.table_c_schedule_view.price_prog_name IS 'Name for the pricing program';
COMMENT ON COLUMN sa.table_c_schedule_view.price_prog_desc IS 'Description of the pricing program';
COMMENT ON COLUMN sa.table_c_schedule_view.price_prog_type IS 'Price type; i.e., 0=Standard Cost, Transfer Price, List Price, Repair Price, or Exchange Price';
COMMENT ON COLUMN sa.table_c_schedule_view.price_prog_eff_dt IS 'Date the price program becomes effective';
COMMENT ON COLUMN sa.table_c_schedule_view.price_prog_exp_dt IS 'Last date the price program is effective';
COMMENT ON COLUMN sa.table_c_schedule_view.price_prog_active IS 'Indicates whether the price program is active; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_c_schedule_view.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_c_schedule_view.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_c_schedule_view.contract_objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_c_schedule_view.chg_start_dt IS 'The earliest contr_itm.chg_start_dt among all contr_itm related to the schedule';
COMMENT ON COLUMN sa.table_c_schedule_view.chg_end_dt IS 'The latest contr_itm.chg_end_dt among all contr_itm related to the schedule';
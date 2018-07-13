CREATE OR REPLACE FORCE VIEW sa.table_pd_amt_line (period_amt_objid,contr_itm_objid,site_part_objid,mod_level_objid,part_num_objid,bill_prd_amt,prd_start_dt,prd_end_dt,rec_type,status,pay_due_dt,last_gen_dt,ref_start_dt,ref_end_dt,contract_id,s_contract_id,schedule_id,s_schedule_id,schedule_title,bill_group,frequency,bill_option,item_start_dt,item_end_dt,due_offset,cycle_start_dt,line_no,svc_start_date,svc_end_date,chg_start_dt,chg_end_dt,quantity,pro_prc,net_prc,cov_site_id,s_cov_site_id,part_num,s_part_num,unit_measure,serial_no,s_serial_no,currency,bill_to_site_id,s_bill_to_site_id,po_id,org_id,s_org_id,create_dt,appl_id,last_update,first_bill_dt,extracted_dt,extract_trk_id,status_dt,invoice_no,arch_ind,gross_prd_amt) AS
select table_period_amt.objid, table_contr_itm.objid,
 table_contr_itm.contr_itm2site_part, table_mod_level.objid,
 table_mod_level.part_info2part_num, table_period_amt.bill_prd_amt,
 table_period_amt.prd_start_dt, table_period_amt.prd_end_dt,
 table_period_amt.rec_type, table_period_amt.status,
 table_period_amt.pay_due_dt, table_period_amt.last_gen_dt,
 table_period_amt.ref_start_dt, table_period_amt.ref_end_dt,
 table_period_amt.contract_id, table_period_amt.S_contract_id, table_period_amt.schedule_id, table_period_amt.S_schedule_id,
 table_period_amt.schedule_title, table_period_amt.bill_group,
 table_period_amt.frequency, table_period_amt.bill_option,
 table_period_amt.item_start_dt, table_period_amt.item_end_dt,
 table_period_amt.due_offset, table_period_amt.cycle_start_dt,
 table_period_amt.line_no, table_period_amt.svc_start_date,
 table_period_amt.svc_end_date, table_period_amt.chg_start_dt,
 table_period_amt.chg_end_dt, table_period_amt.quantity,
 table_period_amt.pro_prc, table_period_amt.net_prc,
 table_period_amt.cov_site_id, table_period_amt.S_cov_site_id, table_period_amt.part_number, table_period_amt.S_part_number,
 table_period_amt.unit_measure, table_period_amt.serial_no, table_period_amt.S_serial_no,
 table_period_amt.currency, table_period_amt.bill_to_site_id, table_period_amt.S_bill_to_site_id,
 table_period_amt.po_id, table_period_amt.org_id, table_period_amt.S_org_id,
 table_period_amt.create_dt, table_period_amt.appl_id,
 table_period_amt.last_update, table_period_amt.first_bill_dt,
 table_period_amt.extracted_dt, table_period_amt.extract_trk_id,
 table_period_amt.status_dt, table_period_amt.invoice_no,
 table_period_amt.arch_ind, table_period_amt.gross_prd_amt
 from table_period_amt, table_contr_itm, table_mod_level
 where table_contr_itm.objid = table_period_amt.period2contr_itm
 AND table_mod_level.part_info2part_num IS NOT NULL
 AND table_mod_level.objid = table_contr_itm.contr_itm2mod_level
 AND table_contr_itm.contr_itm2site_part IS NOT NULL
 ;
COMMENT ON TABLE sa.table_pd_amt_line IS 'This view may be used to export period_amt and line item level information. It provides the fields and the relations to tables likely to be used to furnish supporting information';
COMMENT ON COLUMN sa.table_pd_amt_line.period_amt_objid IS 'Period_amt internal record number';
COMMENT ON COLUMN sa.table_pd_amt_line.contr_itm_objid IS 'Contr_itm internal record number';
COMMENT ON COLUMN sa.table_pd_amt_line.site_part_objid IS 'Site_part internal record number';
COMMENT ON COLUMN sa.table_pd_amt_line.mod_level_objid IS 'Mod_level internal record number';
COMMENT ON COLUMN sa.table_pd_amt_line.part_num_objid IS 'Part_num internal record number';
COMMENT ON COLUMN sa.table_pd_amt_line.bill_prd_amt IS 'The amount billed';
COMMENT ON COLUMN sa.table_pd_amt_line.prd_start_dt IS 'The start date of the current billing period';
COMMENT ON COLUMN sa.table_pd_amt_line.prd_end_dt IS 'The last date of the current billing period';
COMMENT ON COLUMN sa.table_pd_amt_line.rec_type IS 'Type of detail record: i.e., 1=Invoice, 2=credit memo, 3=debit memo';
COMMENT ON COLUMN sa.table_pd_amt_line.status IS 'Status of the record: i.e., 0=hold, 1=approved, 2=disapproved';
COMMENT ON COLUMN sa.table_pd_amt_line.pay_due_dt IS 'Date when payment is due; usually equals either prd_start_dt or prd_end_dt';
COMMENT ON COLUMN sa.table_pd_amt_line.last_gen_dt IS 'The date time that the object was generated. This corresponds to a run of the aggregator function';
COMMENT ON COLUMN sa.table_pd_amt_line.ref_start_dt IS 'The start date of the reference billing period';
COMMENT ON COLUMN sa.table_pd_amt_line.ref_end_dt IS 'The last date of the reference billing period';
COMMENT ON COLUMN sa.table_pd_amt_line.contract_id IS 'Contract that is referred to by the requester. This is the contract or other type of agreement under requestor claims entitlement';
COMMENT ON COLUMN sa.table_pd_amt_line.schedule_id IS 'Contract schedule ID number';
COMMENT ON COLUMN sa.table_pd_amt_line.schedule_title IS 'Contract schedule short description';
COMMENT ON COLUMN sa.table_pd_amt_line.bill_group IS 'Billing group. This is from a user-defined popup list with default name BILLING_GROUP';
COMMENT ON COLUMN sa.table_pd_amt_line.frequency IS 'Frequency of the billing: i.e., 0=annual, 1=semi-annual, 2=quarterly, 3=monthly, 4=one-time, default=0';
COMMENT ON COLUMN sa.table_pd_amt_line.bill_option IS 'Billing option; i.e., 1=in advance, 2=in arrears';
COMMENT ON COLUMN sa.table_pd_amt_line.item_start_dt IS 'The starting date for the contract line item';
COMMENT ON COLUMN sa.table_pd_amt_line.item_end_dt IS 'The ending date for the line item';
COMMENT ON COLUMN sa.table_pd_amt_line.due_offset IS 'The number of days in advance of the expected payment date that determines the invoice date';
COMMENT ON COLUMN sa.table_pd_amt_line.cycle_start_dt IS 'The starting date of the billing cycle. Used with schedule frequency to calculate the periodic "as of" billing dates';
COMMENT ON COLUMN sa.table_pd_amt_line.line_no IS 'Sequential line number of parent lines. For child lines,=parent s p_line_no';
COMMENT ON COLUMN sa.table_pd_amt_line.svc_start_date IS 'The starting date for the line item';
COMMENT ON COLUMN sa.table_pd_amt_line.svc_end_date IS 'The ending date for the line item';
COMMENT ON COLUMN sa.table_pd_amt_line.chg_start_dt IS 'The date from which charges start to accrue';
COMMENT ON COLUMN sa.table_pd_amt_line.chg_end_dt IS 'The last date through which charges accrue';
COMMENT ON COLUMN sa.table_pd_amt_line.quantity IS 'Contracted/Quoted quantity of the part';
COMMENT ON COLUMN sa.table_pd_amt_line.pro_prc IS 'The prorated price of the item';
COMMENT ON COLUMN sa.table_pd_amt_line.net_prc IS 'The price after all adjustments (price factors) have been applied';
COMMENT ON COLUMN sa.table_pd_amt_line.cov_site_id IS 'The price after all adjustments (price factors) have been applied';
COMMENT ON COLUMN sa.table_pd_amt_line.part_num IS 'Part number/name';
COMMENT ON COLUMN sa.table_pd_amt_line.unit_measure IS 'Unit of measure for part number; e.g., roll, set, etc';
COMMENT ON COLUMN sa.table_pd_amt_line.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_pd_amt_line.currency IS 'Name of the currency';
COMMENT ON COLUMN sa.table_pd_amt_line.bill_to_site_id IS 'Site ID of bill to site for the contract';
COMMENT ON COLUMN sa.table_pd_amt_line.po_id IS 'The unique purchase order ID';
COMMENT ON COLUMN sa.table_pd_amt_line.org_id IS 'User-specified ID number of the organization';
COMMENT ON COLUMN sa.table_pd_amt_line.create_dt IS 'Date time the object was created';
COMMENT ON COLUMN sa.table_pd_amt_line.appl_id IS 'Clarify application identifier';
COMMENT ON COLUMN sa.table_pd_amt_line.last_update IS 'Date time of last update to the corresponding contract item';
COMMENT ON COLUMN sa.table_pd_amt_line.first_bill_dt IS 'Date time billing started';
COMMENT ON COLUMN sa.table_pd_amt_line.extracted_dt IS 'Date the item was extracted from the contract';
COMMENT ON COLUMN sa.table_pd_amt_line.extract_trk_id IS 'Identifier used to track the period amount object';
COMMENT ON COLUMN sa.table_pd_amt_line.status_dt IS 'Date time of last status change of the corresponding contract item';
COMMENT ON COLUMN sa.table_pd_amt_line.invoice_no IS 'Contract invoice number';
COMMENT ON COLUMN sa.table_pd_amt_line.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_pd_amt_line.gross_prd_amt IS 'Contains the undiscounted value of the line';
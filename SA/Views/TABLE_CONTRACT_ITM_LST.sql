CREATE OR REPLACE FORCE VIEW sa.table_contract_itm_lst (objid,line_no,parent_line_no,create_date,start_date,end_date,unit_type,units_purch,units_used,units_avail,price,net_price,quote_item,pro_price,extension,quantity,quote_sn,prod_sales_ord,taxable,chg_start_dt,chg_end_dt,credit_ind,cancel_dt,last_mod_dt,last_xfer_dt,oride_price,renew_ind,auto_inst_ind,qty_based_ind,comments,product,s_product,mod_level_objid,rev,s_rev,description,s_description,cover_site_objid,cover_site_id,warranty_dt,serial_no,s_serial_no,sched_objid,child_cnt,part_num_objid,model_num,s_model_num,sn_track,is_sppt_prog,prog_type,p_standalone,p_as_parent,p_as_child,site_part_qty,prorate_type,site_part_objid,unit_measure,price_inst_objid,cover_site_name,s_cover_site_name,po_objid,line_no_txt,d_adj_fxd,d_adj_pct,d_adj_type,d_adj_extn,tot_adj,rollup_prc,handling_cost,tot_ship_amt,status,total_tax_amt,valid_prc_ind,gross_prc,line_key,instance_id,"ACTION") AS
select table_contr_itm.objid, table_contr_itm.line_no,
 table_contr_itm.p_line_no, table_contr_itm.create_date,
 table_contr_itm.start_date, table_contr_itm.end_date,
 table_contr_itm.unit_type, table_contr_itm.units_purch,
 table_contr_itm.units_used, table_contr_itm.units_avail,
 table_contr_itm.prc, table_contr_itm.net_prc,
 table_contr_itm.quote_item, table_contr_itm.pro_prc,
 table_contr_itm.extn, table_contr_itm.quantity,
 table_contr_itm.quote_sn, table_contr_itm.prod_sales_ord,
 table_contr_itm.taxable, table_contr_itm.chg_start_dt,
 table_contr_itm.chg_end_dt, table_contr_itm.credit_ind,
 table_contr_itm.cancel_dt, table_contr_itm.last_mod_dt,
 table_contr_itm.last_xfer_dt, table_contr_itm.oride_price,
 table_contr_itm.renew_ind, table_contr_itm.auto_inst_ind,
 table_contr_itm.qty_based_ind, table_contr_itm.comments,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.objid,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_part_num.description, table_part_num.S_description,
 table_cover_by_site.objid, table_cover_by_site.site_id,
 table_site_part.warranty_date, table_site_part.serial_no, table_site_part.S_serial_no,
 table_contr_itm.contr_itm2contr_schedule, table_contr_itm.child_cnt,
 table_part_num.objid, table_part_num.model_num, table_part_num.S_model_num,
 table_part_num.sn_track, table_part_num.is_sppt_prog,
 table_part_num.prog_type, table_part_num.p_standalone,
 table_part_num.p_as_parent, table_part_num.p_as_child,
 table_site_part.quantity, table_contr_itm.prorate_type,
 table_site_part.objid, table_part_num.unit_measure,
 table_contr_itm.contr_itm2price_inst, table_cover_by_site.name, table_cover_by_site.S_name,
 table_contr_itm.contr_itm2purchase_ord, table_contr_itm.line_no_txt,
 table_contr_itm.d_adj_fxd, table_contr_itm.d_adj_pct,
 table_contr_itm.d_adj_type, table_contr_itm.d_adj_extn,
 table_contr_itm.tot_adj, table_contr_itm.rollup_prc,
 table_contr_itm.handling_cost, table_contr_itm.tot_ship_amt,
 table_contr_itm.status, table_contr_itm.total_tax_amt,
 table_contr_itm.valid_prc_ind, table_contr_itm.gross_prc,
 table_contr_itm.line_key, table_contr_itm.instance_id,
 table_contr_itm.action
 from table_site table_cover_by_site, table_contr_itm, table_part_num, table_mod_level,
  table_site_part
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_contr_itm.contr_itm2mod_level
 AND table_site_part.objid = table_contr_itm.contr_itm2site_part
 AND table_cover_by_site.objid = table_contr_itm.quoted_at2site
 AND table_contr_itm.contr_itm2contr_schedule IS NOT NULL
 ;
COMMENT ON TABLE sa.table_contract_itm_lst IS 'Used by forms Contract (9133), Contract<ID> (9134), More Info (9135, 9674), Line Items (9136, 9675), Schedules (9140, 9676), Payment Options (9141, 9677), Quote (9672) and Quote<ID> (9673)';
COMMENT ON COLUMN sa.table_contract_itm_lst.objid IS 'Contract line item objid';
COMMENT ON COLUMN sa.table_contract_itm_lst.line_no IS 'Contract line item line no';
COMMENT ON COLUMN sa.table_contract_itm_lst.parent_line_no IS 'Line number of the parent contract item';
COMMENT ON COLUMN sa.table_contract_itm_lst.create_date IS 'The create date for the line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.start_date IS 'The starting date for the line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.end_date IS 'The ending date for the line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.unit_type IS 'The type of unit the contract is delivered by; e.g., day, case, etc';
COMMENT ON COLUMN sa.table_contract_itm_lst.units_purch IS 'The number of units purchased for the line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.units_used IS 'The number of line item units which  remaining';
COMMENT ON COLUMN sa.table_contract_itm_lst.units_avail IS 'The number of line item units which  still unused';
COMMENT ON COLUMN sa.table_contract_itm_lst.price IS 'The price which was copied from the price schedule (price_inst)';
COMMENT ON COLUMN sa.table_contract_itm_lst.net_price IS 'The price after all adjustments (price factors) have been applied';
COMMENT ON COLUMN sa.table_contract_itm_lst.quote_item IS 'Defines whether the line item is to be priced on the quote worksheet; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_contract_itm_lst.pro_price IS 'The prorated price of the item';
COMMENT ON COLUMN sa.table_contract_itm_lst.extension IS 'The extended price of the item before price factors were applied. It is determined by quantity * price or quantity * rate as appropriate';
COMMENT ON COLUMN sa.table_contract_itm_lst.quantity IS 'Contracted/Quoted quantity of the part';
COMMENT ON COLUMN sa.table_contract_itm_lst.quote_sn IS 'The serial number of the product to be installed under the contract line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.prod_sales_ord IS 'The sales order of the product to be installed under the contract line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.taxable IS 'Indicates whether the item is taxable; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_contract_itm_lst.chg_start_dt IS 'The date from which charges start to accrue';
COMMENT ON COLUMN sa.table_contract_itm_lst.chg_end_dt IS 'The last date through which charges accrue';
COMMENT ON COLUMN sa.table_contract_itm_lst.credit_ind IS 'If line is canceled or closed, whether or not credit is to be issued: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_contract_itm_lst.cancel_dt IS 'If a line is canceled or closed, the date when the cancel or close becomes effective';
COMMENT ON COLUMN sa.table_contract_itm_lst.last_mod_dt IS 'The date/time indicating the last time the row was updated to reflect a mid-term change. If any of the billing related columns in this record change then this column is updated';
COMMENT ON COLUMN sa.table_contract_itm_lst.last_xfer_dt IS 'The date/time that the set of billing records for this line item were transferred into Trans_record';
COMMENT ON COLUMN sa.table_contract_itm_lst.oride_price IS 'The value of a manually overridden price';
COMMENT ON COLUMN sa.table_contract_itm_lst.renew_ind IS 'Indicates whether a line item is to be renewed or not: 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contract_itm_lst.auto_inst_ind IS 'Indicates whether indicates whether a generic part is to be auto installed: 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contract_itm_lst.qty_based_ind IS 'Indicates whether a service line item is qty or time based: 0=time, 1=qty, default=0';
COMMENT ON COLUMN sa.table_contract_itm_lst.comments IS 'Comments about the line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.product IS 'Contract line item part number';
COMMENT ON COLUMN sa.table_contract_itm_lst.mod_level_objid IS 'Mod_level internal record number';
COMMENT ON COLUMN sa.table_contract_itm_lst.rev IS 'Contract line item mod level';
COMMENT ON COLUMN sa.table_contract_itm_lst.description IS 'Contract line item description';
COMMENT ON COLUMN sa.table_contract_itm_lst.cover_site_objid IS 'Covered site internal record number';
COMMENT ON COLUMN sa.table_contract_itm_lst.cover_site_id IS 'Covered site unique ID number';
COMMENT ON COLUMN sa.table_contract_itm_lst.warranty_dt IS 'Contract line item warranty date';
COMMENT ON COLUMN sa.table_contract_itm_lst.serial_no IS 'Contract line item serial no';
COMMENT ON COLUMN sa.table_contract_itm_lst.sched_objid IS 'Contr_schedule internal record number';
COMMENT ON COLUMN sa.table_contract_itm_lst.child_cnt IS 'For a parent line, the number of child contr_itm lines under it';
COMMENT ON COLUMN sa.table_contract_itm_lst.part_num_objid IS 'Part_num internal record number';
COMMENT ON COLUMN sa.table_contract_itm_lst.model_num IS 'Contract line item part number';
COMMENT ON COLUMN sa.table_contract_itm_lst.sn_track IS 'Contract line item part number';
COMMENT ON COLUMN sa.table_contract_itm_lst.is_sppt_prog IS 'Indicates if line is support program';
COMMENT ON COLUMN sa.table_contract_itm_lst.prog_type IS 'Indicates if line is support program';
COMMENT ON COLUMN sa.table_contract_itm_lst.p_standalone IS 'Indicates if line is support program';
COMMENT ON COLUMN sa.table_contract_itm_lst.p_as_parent IS 'Indicates if line is support program';
COMMENT ON COLUMN sa.table_contract_itm_lst.p_as_child IS 'Indicates if line is support program';
COMMENT ON COLUMN sa.table_contract_itm_lst.site_part_qty IS 'Installed part quantity; equal to 1 for serialized parts';
COMMENT ON COLUMN sa.table_contract_itm_lst.prorate_type IS 'The type of proration for this lineitem';
COMMENT ON COLUMN sa.table_contract_itm_lst.site_part_objid IS 'Site_part internal record number';
COMMENT ON COLUMN sa.table_contract_itm_lst.unit_measure IS 'Unit of measure for part number; e.g., roll, set, etc';
COMMENT ON COLUMN sa.table_contract_itm_lst.price_inst_objid IS 'Price_inst internal record number';
COMMENT ON COLUMN sa.table_contract_itm_lst.cover_site_name IS 'Covered site name';
COMMENT ON COLUMN sa.table_contract_itm_lst.po_objid IS 'Purchase_ord internal record number';
COMMENT ON COLUMN sa.table_contract_itm_lst.line_no_txt IS 'Concatination of parent and child line numbers delimited by a period';
COMMENT ON COLUMN sa.table_contract_itm_lst.d_adj_fxd IS 'A single, fixed price adjustment placed directly against the line';
COMMENT ON COLUMN sa.table_contract_itm_lst.d_adj_pct IS 'A single, percentage adjustment placed directly against the line';
COMMENT ON COLUMN sa.table_contract_itm_lst.d_adj_type IS 'Type of single adjustment: either discount or surcharge';
COMMENT ON COLUMN sa.table_contract_itm_lst.d_adj_extn IS 'The extended amount of a single adjustment; whether a fixed value or the result of d_adj_pct * unit price';
COMMENT ON COLUMN sa.table_contract_itm_lst.tot_adj IS 'The sum of all adjustments against the line';
COMMENT ON COLUMN sa.table_contract_itm_lst.rollup_prc IS 'The sum of the net_prc field on all child items and the current item. If no child items, it is the same as the net_prc value of the current item';
COMMENT ON COLUMN sa.table_contract_itm_lst.handling_cost IS 'The sum of all handling costs for the item. Used where contract.struct_type=2';
COMMENT ON COLUMN sa.table_contract_itm_lst.tot_ship_amt IS 'The sum of all shipping charges for the item';
COMMENT ON COLUMN sa.table_contract_itm_lst.status IS 'Current status of an order line item. This is a user-defined popup with default name Order Line Status';
COMMENT ON COLUMN sa.table_contract_itm_lst.total_tax_amt IS 'The sum of all taxes applied to the item. Used where contract.struct_type=2';
COMMENT ON COLUMN sa.table_contract_itm_lst.valid_prc_ind IS 'Indicates whether a valid price for the item was found; i.e., 0=no valid price found; 1=valid price found, default=1. Used in re-pricing';
COMMENT ON COLUMN sa.table_contract_itm_lst.gross_prc IS 'For childless items this is the item s non-extended base price, for parent items this is the sum of the extended base prices of all its child items plus its own non-extended base price';
COMMENT ON COLUMN sa.table_contract_itm_lst.line_key IS 'The Configurator line item identifier corresponding to the contract schedule line item';
COMMENT ON COLUMN sa.table_contract_itm_lst.instance_id IS 'Installed part unique instnace id';
COMMENT ON COLUMN sa.table_contract_itm_lst."ACTION" IS 'MACD action';
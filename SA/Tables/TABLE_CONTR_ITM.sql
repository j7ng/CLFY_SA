CREATE TABLE sa.table_contr_itm (
  objid NUMBER,
  create_date DATE,
  start_date DATE,
  end_date DATE,
  unit_type VARCHAR2(30 BYTE),
  units_purch NUMBER,
  units_used NUMBER,
  units_avail NUMBER,
  prc NUMBER(19,4),
  net_prc NUMBER(19,4),
  line_no NUMBER,
  quote_item NUMBER,
  pro_prc NUMBER(19,4),
  extn NUMBER(19,4),
  quantity NUMBER,
  quote_sn VARCHAR2(40 BYTE),
  prod_sales_ord VARCHAR2(40 BYTE),
  taxable NUMBER,
  chg_start_dt DATE,
  chg_end_dt DATE,
  credit_ind NUMBER,
  cancel_dt DATE,
  last_mod_dt DATE,
  last_xfer_dt DATE,
  oride_price NUMBER(19,4),
  renew_ind NUMBER,
  auto_inst_ind NUMBER,
  qty_based_ind NUMBER,
  comments VARCHAR2(255 BYTE),
  p_line_no NUMBER,
  child_cnt NUMBER,
  prorate_type NUMBER,
  line_no_txt VARCHAR2(20 BYTE),
  dev NUMBER,
  contr_itm2price_inst NUMBER(*,0),
  contr_itm2contr_schedule NUMBER(*,0),
  quoted_at2site NUMBER(*,0),
  covered_by2site NUMBER(*,0),
  child2contr_itm NUMBER(*,0),
  contr_itm2purchase_ord NUMBER(*,0),
  contr_itm2mod_level NUMBER(*,0),
  contr_itm2site_part NUMBER(*,0),
  sccssr_itm2contr_itm NUMBER(*,0),
  bill_attn VARCHAR2(30 BYTE),
  s_bill_attn VARCHAR2(30 BYTE),
  bill_attn2 VARCHAR2(40 BYTE),
  s_bill_attn2 VARCHAR2(40 BYTE),
  bill_itm2address NUMBER,
  contr_itm2ship_parts NUMBER,
  d_adj_extn NUMBER(19,4),
  d_adj_fxd NUMBER(19,4),
  d_adj_pct NUMBER(19,4),
  d_adj_type VARCHAR2(40 BYTE),
  gross_prc NUMBER(19,4),
  handling_cost NUMBER(19,4),
  rollup_prc NUMBER(19,4),
  status VARCHAR2(20 BYTE),
  tot_adj NUMBER(19,4),
  tot_ship_amt NUMBER(19,4),
  total_tax_amt NUMBER(19,4),
  valid_prc_ind NUMBER,
  line_key VARCHAR2(40 BYTE),
  "ACTION" VARCHAR2(20 BYTE),
  instance_id VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_contr_itm ADD SUPPLEMENTAL LOG GROUP dmtsora709058452_0 (auto_inst_ind, cancel_dt, chg_end_dt, chg_start_dt, child_cnt, comments, create_date, credit_ind, end_date, extn, last_mod_dt, last_xfer_dt, line_no, line_no_txt, net_prc, objid, oride_price, prc, prod_sales_ord, prorate_type, pro_prc, p_line_no, qty_based_ind, quantity, quote_item, quote_sn, renew_ind, start_date, taxable, units_avail, units_purch, units_used, unit_type) ALWAYS;
ALTER TABLE sa.table_contr_itm ADD SUPPLEMENTAL LOG GROUP dmtsora709058452_1 ("ACTION", bill_attn, bill_attn2, bill_itm2address, child2contr_itm, contr_itm2contr_schedule, contr_itm2mod_level, contr_itm2price_inst, contr_itm2purchase_ord, contr_itm2ship_parts, contr_itm2site_part, covered_by2site, dev, d_adj_extn, d_adj_fxd, d_adj_pct, d_adj_type, gross_prc, handling_cost, instance_id, line_key, quoted_at2site, rollup_prc, sccssr_itm2contr_itm, status, s_bill_attn, s_bill_attn2, total_tax_amt, tot_adj, tot_ship_amt, valid_prc_ind) ALWAYS;
COMMENT ON TABLE sa.table_contr_itm IS 'Line items on a contract or quote';
COMMENT ON COLUMN sa.table_contr_itm.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_contr_itm.create_date IS 'The create date for the line item';
COMMENT ON COLUMN sa.table_contr_itm.start_date IS 'The effective date for the line item';
COMMENT ON COLUMN sa.table_contr_itm.end_date IS 'The last effective date for the line item';
COMMENT ON COLUMN sa.table_contr_itm.unit_type IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contr_itm.units_purch IS 'Number of line item units purchased';
COMMENT ON COLUMN sa.table_contr_itm.units_used IS 'The number of line item units used up';
COMMENT ON COLUMN sa.table_contr_itm.units_avail IS 'The number of line item units remaining';
COMMENT ON COLUMN sa.table_contr_itm.prc IS 'The unit price of the product, which was copied from the related price_inst';
COMMENT ON COLUMN sa.table_contr_itm.net_prc IS 'The price of the order item after adjustments have been applied. Extn +/- adjs';
COMMENT ON COLUMN sa.table_contr_itm.line_no IS 'Sequential line number of the contr_itm within its parent item. 0=line has no parent';
COMMENT ON COLUMN sa.table_contr_itm.quote_item IS 'Defines whether or not line counts toward total price. (i.e. if it s a giveaway)';
COMMENT ON COLUMN sa.table_contr_itm.pro_prc IS 'The prorated price of the item';
COMMENT ON COLUMN sa.table_contr_itm.extn IS 'Rollup_Prc * quantity';
COMMENT ON COLUMN sa.table_contr_itm.quantity IS 'Number of products purchased';
COMMENT ON COLUMN sa.table_contr_itm.quote_sn IS 'The serial number of the product to be installed under the contract line item';
COMMENT ON COLUMN sa.table_contr_itm.prod_sales_ord IS 'The sales order of the product to be installed under the contract line item';
COMMENT ON COLUMN sa.table_contr_itm.taxable IS 'Indicates whether the item is taxable; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_contr_itm.chg_start_dt IS 'The date from which charges start to accrue';
COMMENT ON COLUMN sa.table_contr_itm.chg_end_dt IS 'The last date through which charges accrue';
COMMENT ON COLUMN sa.table_contr_itm.credit_ind IS 'If line is canceled or closed, whether or not credit is to be issued: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_contr_itm.cancel_dt IS 'If a line is canceled or closed, the date when the cancel or close becomes effective';
COMMENT ON COLUMN sa.table_contr_itm.last_mod_dt IS 'The date/time indicating the last time the row was updated to reflect a mid-term change. If any of the billing related columns in this record change then this column is updated';
COMMENT ON COLUMN sa.table_contr_itm.last_xfer_dt IS 'The date/time that the set of billing records for this line item were transferred into Trans_record';
COMMENT ON COLUMN sa.table_contr_itm.oride_price IS 'The value of a manually overridden price';
COMMENT ON COLUMN sa.table_contr_itm.renew_ind IS 'Indicates whether a line item is to be renewed or not: 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_contr_itm.auto_inst_ind IS 'Indicates whether indicates whether a generic part is to be auto installed: 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contr_itm.qty_based_ind IS 'Indicates whether a service line item is qty or time based: 0=time, 1=qty, default=0';
COMMENT ON COLUMN sa.table_contr_itm.comments IS 'Comments about the line item';
COMMENT ON COLUMN sa.table_contr_itm.p_line_no IS 'Sequential line number of parent lines. For child lines it equals parent s p_line_no';
COMMENT ON COLUMN sa.table_contr_itm.child_cnt IS 'For a parent line, the number of child contr_itm lines under it';
COMMENT ON COLUMN sa.table_contr_itm.prorate_type IS 'How the line will be prorated; i.e., 0=no proration, 1=30-day-month basis, 2=actual-number-of-days-in-month basis; defaul=0';
COMMENT ON COLUMN sa.table_contr_itm.line_no_txt IS 'Sequential line number of line within its parent line.=0 if line has no parent';
COMMENT ON COLUMN sa.table_contr_itm.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_contr_itm.contr_itm2price_inst IS 'Price instance used to get the price of the item';
COMMENT ON COLUMN sa.table_contr_itm.contr_itm2contr_schedule IS 'Contract/quote schedule on which the line item appears';
COMMENT ON COLUMN sa.table_contr_itm.quoted_at2site IS 'Site the item is quoted at';
COMMENT ON COLUMN sa.table_contr_itm.covered_by2site IS 'For site-based support programs, the site which is covered';
COMMENT ON COLUMN sa.table_contr_itm.child2contr_itm IS 'For line item hierarchy, the parent item';
COMMENT ON COLUMN sa.table_contr_itm.contr_itm2purchase_ord IS 'Payment method for the line item. It may differ from that of the contract schedule';
COMMENT ON COLUMN sa.table_contr_itm.contr_itm2mod_level IS 'Related part revision';
COMMENT ON COLUMN sa.table_contr_itm.contr_itm2site_part IS 'Installed part covered by this item';
COMMENT ON COLUMN sa.table_contr_itm.sccssr_itm2contr_itm IS 'Reserved; future';
COMMENT ON COLUMN sa.table_contr_itm.bill_attn IS 'First name of the person billing will be directed to. If used will override corresponding field on contr_schedule';
COMMENT ON COLUMN sa.table_contr_itm.bill_attn2 IS 'Last name of the person billing will be directed to. If used will override corresponding field on contr_schedule';
COMMENT ON COLUMN sa.table_contr_itm.bill_itm2address IS 'Billing address which overrides the schedule s billing address for the item';
COMMENT ON COLUMN sa.table_contr_itm.contr_itm2ship_parts IS 'Shipping information which overrides the schedule s shipping information';
COMMENT ON COLUMN sa.table_contr_itm.d_adj_extn IS 'The extended amount of a single adjustment; whether a fixed value or the result of d_adj_pct * unit price';
COMMENT ON COLUMN sa.table_contr_itm.d_adj_fxd IS 'Single and last applied Line level adjustment. Used if d_adj_type is fixed';
COMMENT ON COLUMN sa.table_contr_itm.d_adj_pct IS 'Single and last applied Line level percent adjustment. Used if d_adj_type is percent';
COMMENT ON COLUMN sa.table_contr_itm.d_adj_type IS 'Type of adjustment, "Discount-Fixed Amount", "Surcharge-Fixed Amount", "Discount-Percentage", "Surcharge-Percentage"';
COMMENT ON COLUMN sa.table_contr_itm.gross_prc IS 'Sum (child.prc * child.quantity) + prc';
COMMENT ON COLUMN sa.table_contr_itm.handling_cost IS 'The sum of all handling costs for the item. Used where contract.struct_type=2';
COMMENT ON COLUMN sa.table_contr_itm.rollup_prc IS 'Sum (child.net_prc) + prc';
COMMENT ON COLUMN sa.table_contr_itm.status IS 'Current status of an order line item. This is a user-defined popup with default name Order Line Status';
COMMENT ON COLUMN sa.table_contr_itm.tot_adj IS 'The sum of all adjustments against the line';
COMMENT ON COLUMN sa.table_contr_itm.tot_ship_amt IS 'The sum of all shipping charges for the item';
COMMENT ON COLUMN sa.table_contr_itm.total_tax_amt IS 'The sum of all taxes applied to the item. Used where contract.struct_type=2';
COMMENT ON COLUMN sa.table_contr_itm.valid_prc_ind IS 'Indicates whether a valid price for the item was found; i.e., 0=no valid price found; 1=valid price found, default=1. Used in re-pricing';
COMMENT ON COLUMN sa.table_contr_itm.line_key IS 'The Configurator line item identifier corresponding to the item';
COMMENT ON COLUMN sa.table_contr_itm."ACTION" IS 'MACD action';
COMMENT ON COLUMN sa.table_contr_itm.instance_id IS 'Installed part unique instnace id';
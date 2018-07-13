CREATE OR REPLACE FORCE VIEW sa.table_p_factor_view (objid,factor_id,"NAME",description,"TYPE",start_date,end_date,precedence,"ACTIVE",fixed_amt,percentage,factor_base,eligible_hdr,eligible_dtl,currency_objid,cur_name,s_cur_name,cur_symbol,cur_desc,sub_scale) AS
select table_price_factor.objid, table_price_factor.factor_id,
 table_price_factor.name, table_price_factor.description,
 table_price_factor.type, table_price_factor.start_date,
 table_price_factor.end_date, table_price_factor.precedence,
 table_price_factor.active, table_price_factor.fxd_amt,
 table_price_factor.pct, table_price_factor.factor_base,
 table_price_factor.eligible_hdr, table_price_factor.eligible_dtl,
 table_currency.objid, table_currency.name, table_currency.S_name,
 table_currency.symbol, table_currency.description,
 table_currency.sub_scale
 from table_price_factor, table_currency
 where table_currency.objid = table_price_factor.factor2currency
 ;
COMMENT ON TABLE sa.table_p_factor_view IS 'Gets price adjustments. Used by forms Line Adjustments (9138) and Schedule Adjustmens(9679)';
COMMENT ON COLUMN sa.table_p_factor_view.objid IS 'Price_factor internal record number';
COMMENT ON COLUMN sa.table_p_factor_view.factor_id IS 'The unique identifier of the discount or surcharge';
COMMENT ON COLUMN sa.table_p_factor_view."NAME" IS 'The name of the discount or surcharge';
COMMENT ON COLUMN sa.table_p_factor_view.description IS 'The description of the discount or surcharge';
COMMENT ON COLUMN sa.table_p_factor_view."TYPE" IS 'Indicates whether the factor is a discount or surcharge';
COMMENT ON COLUMN sa.table_p_factor_view.start_date IS 'Date the price factor becomes effective';
COMMENT ON COLUMN sa.table_p_factor_view.end_date IS 'Last date the price factor is effective';
COMMENT ON COLUMN sa.table_p_factor_view.precedence IS 'The order in which the price factor should be applied against the base price';
COMMENT ON COLUMN sa.table_p_factor_view."ACTIVE" IS 'Indicates if the discount or surcharge is currently available for selection in the process of building quotes or contracts; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_p_factor_view.fixed_amt IS 'Gives a fixed currency amount for the discount or surcharge';
COMMENT ON COLUMN sa.table_p_factor_view.percentage IS 'The percentage to be applied as a discount or surcharge';
COMMENT ON COLUMN sa.table_p_factor_view.factor_base IS 'How the price factor is applied; i.e. 1=against the base price, 2=against the net price';
COMMENT ON COLUMN sa.table_p_factor_view.eligible_hdr IS 'Indicates whether this factor can be applied at the quote/contract header level; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_p_factor_view.eligible_dtl IS 'Indicates whether this factor can be applied at the quote/contract detail level; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_p_factor_view.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_p_factor_view.cur_name IS 'Name of the currency';
COMMENT ON COLUMN sa.table_p_factor_view.cur_symbol IS 'Symbol for the currency; e.g., $ for US dollar';
COMMENT ON COLUMN sa.table_p_factor_view.cur_desc IS 'Description of the currency';
COMMENT ON COLUMN sa.table_p_factor_view.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';
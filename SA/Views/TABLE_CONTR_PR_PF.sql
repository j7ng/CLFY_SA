CREATE OR REPLACE FORCE VIEW sa.table_contr_pr_pf (pr_objid,pf_objid,pr_amt,pr_perc,pr_precedence,pr_notes,pr_symbol,pr_base,pr_type,pf_id,pf_name,pf_desc,pf_type,pf_start,pf_end,pf_precedence,pf_active,pf_amt,pf_perc,pf_eli_hdr,pf_eli_dtl,pf_base,pr_eff_start,pr_eff_end,pr_ext_amt,pr_is_man_adj) AS
select table_contr_pr.objid, table_price_factor.objid,
 table_contr_pr.fxd_amt, table_contr_pr.pct,
 table_contr_pr.precedence, table_contr_pr.notes,
 table_contr_pr.symbol, table_contr_pr.factor_base,
 table_contr_pr.type, table_price_factor.factor_id,
 table_price_factor.name, table_price_factor.description,
 table_price_factor.type, table_price_factor.start_date,
 table_price_factor.end_date, table_price_factor.precedence,
 table_price_factor.active, table_price_factor.fxd_amt,
 table_price_factor.pct, table_price_factor.eligible_hdr,
 table_price_factor.eligible_dtl, table_price_factor.factor_base,
 table_contr_pr.eff_start_dt, table_contr_pr.eff_end_dt,
 table_contr_pr.extended_amt, table_contr_pr.is_man_adj
 from table_contr_pr, table_price_factor
 where table_price_factor.objid = table_contr_pr.contr_pr2price_factor
 ;
COMMENT ON TABLE sa.table_contr_pr_pf IS 'Used by forms Contract (9133), Contract <ID> (9134), More Info (9135, 9674), Line Items (9136, 9175), Line Adjustments (9138), Schedules (9140, 9176), Quote (9672), Quote <ID> (9673) and Schd Adjustments (9679)';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_objid IS 'Internal record number of the contr_pr object';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_objid IS 'Internal record number of the price_factor object';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_amt IS 'Indicate a fixed currency amount applied to the price';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_perc IS 'The percentage applied to the price';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_precedence IS 'The order in which the price factor should be applied against the base price';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_notes IS 'Notes about the applied price factor';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_symbol IS 'Currency symbol for the applied price factor; e.g., $ for US dollar';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_base IS 'How the price factor was applied; i.e. 1=against the base price, 2=against the net price';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_type IS 'Indicates whether the applied price factor was a discount or surcharge';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_id IS 'Internal record number of the price_factor object';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_name IS 'The name of the discount or surcharge';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_desc IS 'The description of the discount or surcharge';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_type IS 'Indicates whether the price factor is a discount or surcharge';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_start IS 'First day the price factor became effective';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_end IS 'Last day the price factor was effective';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_precedence IS 'The order in which the price factor should be applied against the base price';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_active IS 'Indicates if the discount or surcharge is currently available for selection in the process of building quotes or contracts; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_amt IS 'Gives a fixed currency amount for the discount or surcharge';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_perc IS 'The percentage to be applied as a discount or surcharge';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_eli_hdr IS 'Indicates whether this factor can be applied at the quote/contract header level; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_eli_dtl IS 'Indicates whether this factor can be applied at the quote/contract detail level; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_contr_pr_pf.pf_base IS 'How the price factor is applied; i.e. 1=against the base price, 2=against the net price';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_eff_start IS 'The date that the price factor becomes effective';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_eff_end IS 'Last day the price factor was effective';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_ext_amt IS 'The extended amount whether fixed amount or percentage';
COMMENT ON COLUMN sa.table_contr_pr_pf.pr_is_man_adj IS 'Indicates whether the adjustment was predefined: i.e., 0=predefined, 1=manual adjustment';
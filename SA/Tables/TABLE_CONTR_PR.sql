CREATE TABLE sa.table_contr_pr (
  objid NUMBER,
  fxd_amt NUMBER(19,4),
  pct NUMBER(19,4),
  precedence NUMBER,
  notes VARCHAR2(80 BYTE),
  symbol VARCHAR2(5 BYTE),
  factor_base NUMBER,
  "TYPE" VARCHAR2(40 BYTE),
  eff_start_dt DATE,
  eff_end_dt DATE,
  extended_amt NUMBER(19,4),
  is_man_adj NUMBER,
  dev NUMBER,
  contr_pr2contr_itm NUMBER(*,0),
  contr_pr2price_factor NUMBER(*,0),
  contr_pr2contr_schedule NUMBER(*,0)
);
ALTER TABLE sa.table_contr_pr ADD SUPPLEMENTAL LOG GROUP dmtsora987043569_0 (contr_pr2contr_itm, contr_pr2contr_schedule, contr_pr2price_factor, dev, eff_end_dt, eff_start_dt, extended_amt, factor_base, fxd_amt, is_man_adj, notes, objid, pct, precedence, symbol, "TYPE") ALWAYS;
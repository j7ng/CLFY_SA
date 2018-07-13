CREATE TABLE sa.table_x_case_promotions (
  objid NUMBER,
  dev NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_annual_plan NUMBER,
  case_promo2promotion NUMBER,
  case_promo2promo_grp NUMBER,
  case_promo2case NUMBER
);
ALTER TABLE sa.table_x_case_promotions ADD SUPPLEMENTAL LOG GROUP dmtsora1419619887_0 (case_promo2case, case_promo2promotion, case_promo2promo_grp, dev, objid, x_annual_plan, x_end_date, x_start_date) ALWAYS;
COMMENT ON TABLE sa.table_x_case_promotions IS 'Promotions Associated to ESN at the time of case creation';
COMMENT ON COLUMN sa.table_x_case_promotions.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_promotions.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_case_promotions.x_start_date IS 'Start Date of the Promotion';
COMMENT ON COLUMN sa.table_x_case_promotions.x_end_date IS 'End Date of the promotion';
COMMENT ON COLUMN sa.table_x_case_promotions.x_annual_plan IS 'Annual Plan Promo';
COMMENT ON COLUMN sa.table_x_case_promotions.case_promo2promotion IS 'TBD';
COMMENT ON COLUMN sa.table_x_case_promotions.case_promo2promo_grp IS 'TBD';
COMMENT ON COLUMN sa.table_x_case_promotions.case_promo2case IS 'TBD';
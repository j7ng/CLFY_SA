CREATE OR REPLACE FORCE VIEW sa.table_x_case_promo_view (x_id_number,x_start_date,x_annual_plan,x_end_date,x_case_promo_objid,x_promo_code,x_units,x_access_days,x_group_name) AS
select table_case.id_number, table_x_case_promotions.x_start_date,
 table_x_case_promotions.x_annual_plan, table_x_case_promotions.x_end_date,
 table_x_case_promotions.dev, table_x_promotion.x_promo_code,
 table_x_promotion.x_units, table_x_promotion.x_access_days,
 table_x_promotion_group.group_name
 from table_case, table_x_case_promotions, table_x_promotion,
  table_x_promotion_group
 where table_case.objid = table_x_case_promotions.case_promo2case
 AND table_x_promotion.objid = table_x_case_promotions.case_promo2promotion
 AND table_x_promotion_group.objid = table_x_case_promotions.case_promo2promo_grp
 ;
COMMENT ON TABLE sa.table_x_case_promo_view IS 'Case Promo View';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_start_date IS 'Start Date of the Promotion';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_annual_plan IS 'Annual Plan Promo';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_end_date IS 'End Date of the promotion';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_case_promo_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_promo_code IS 'Promotion Code';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_units IS 'Units on the card associated with the promotion';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_access_days IS 'Access Days for which the card is vaild';
COMMENT ON COLUMN sa.table_x_case_promo_view.x_group_name IS 'Name for promotion group';
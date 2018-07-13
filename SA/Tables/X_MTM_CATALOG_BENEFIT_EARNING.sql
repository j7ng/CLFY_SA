CREATE TABLE sa.x_mtm_catalog_benefit_earning (
  objid NUMBER NOT NULL,
  catalog_objid NUMBER NOT NULL,
  benefit_earning_objid NUMBER NOT NULL,
  CONSTRAINT x_mtm_cat_ben_earn_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_mtm_catalog_benefit_earning IS 'Captures which reward catalog is being published';
COMMENT ON COLUMN sa.x_mtm_catalog_benefit_earning.objid IS 'Primary Key';
COMMENT ON COLUMN sa.x_mtm_catalog_benefit_earning.catalog_objid IS 'Refers table_reward_catalog.objid';
COMMENT ON COLUMN sa.x_mtm_catalog_benefit_earning.benefit_earning_objid IS 'Referes x_reward_benefit_earning.objid';
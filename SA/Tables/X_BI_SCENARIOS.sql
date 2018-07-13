CREATE TABLE sa.x_bi_scenarios (
  objid NUMBER(22) NOT NULL,
  x_service_plan_type VARCHAR2(50 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT tf_x_bi_scenarios_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_bi_scenarios IS 'Source for the BI with the flow id details';
COMMENT ON COLUMN sa.x_bi_scenarios.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_bi_scenarios.x_service_plan_type IS 'Gives the details like which service plan user is holding like limited, unlimited or all you need';
COMMENT ON COLUMN sa.x_bi_scenarios.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_bi_scenarios.update_timestamp IS 'Last date when the record was last modified';
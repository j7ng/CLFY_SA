CREATE TABLE sa.dynamic_trans_sum_params (
  objid NUMBER NOT NULL,
  source_system VARCHAR2(10 BYTE) NOT NULL,
  brand_name VARCHAR2(20 BYTE) NOT NULL,
  transaction_type VARCHAR2(20 BYTE),
  retention_type VARCHAR2(30 BYTE),
  language VARCHAR2(10 BYTE),
  param_name VARCHAR2(50 BYTE) NOT NULL,
  param_value VARCHAR2(2000 BYTE) NOT NULL,
  description VARCHAR2(255 BYTE),
  creation_date DATE,
  modified_date DATE
);
COMMENT ON TABLE sa.dynamic_trans_sum_params IS 'Stores parameters for Dynamic Transaction Summary';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.objid IS 'Sequence Number: Obj ID';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.source_system IS 'Source System';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.brand_name IS 'Brand Name';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.transaction_type IS 'Transaction Type';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.retention_type IS 'Retention Type';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.language IS 'Language';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.param_name IS 'Parameter Name';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.param_value IS 'Parameter Vaule';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.description IS 'Description';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.creation_date IS 'Date Created';
COMMENT ON COLUMN sa.dynamic_trans_sum_params.modified_date IS 'Date Modified';
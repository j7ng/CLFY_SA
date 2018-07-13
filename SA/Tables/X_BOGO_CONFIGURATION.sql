CREATE TABLE sa.x_bogo_configuration (
  objid NUMBER(25) NOT NULL,
  brand VARCHAR2(240 BYTE) NOT NULL,
  bogo_part_number VARCHAR2(240 BYTE) NOT NULL,
  card_pin_part_class VARCHAR2(240 BYTE),
  esn_part_class VARCHAR2(240 BYTE),
  esn_part_number VARCHAR2(240 BYTE),
  esn_dealer_id VARCHAR2(240 BYTE),
  esn_dealer_name VARCHAR2(240 BYTE),
  eligible_service_plan NUMBER(25),
  channel VARCHAR2(240 BYTE),
  action_type VARCHAR2(240 BYTE),
  tsp_id NUMBER(25),
  msg_script_id VARCHAR2(240 BYTE),
  bogo_start_date TIMESTAMP,
  bogo_end_date TIMESTAMP,
  appl_execution_id NUMBER(25),
  bogo_status VARCHAR2(240 BYTE),
  created_by NUMBER(25),
  created_date TIMESTAMP,
  updated_by NUMBER(25),
  updated_date TIMESTAMP,
  CONSTRAINT x_bogo_configuration_pk PRIMARY KEY (objid) USING INDEX sa.pk1_bogo_configuration
);
COMMENT ON TABLE sa.x_bogo_configuration IS 'TF BOGO detailed information used for front-end applications';
COMMENT ON COLUMN sa.x_bogo_configuration.objid IS 'Table Primary Key';
COMMENT ON COLUMN sa.x_bogo_configuration.brand IS 'Brand or main Tracfone business entity';
COMMENT ON COLUMN sa.x_bogo_configuration.bogo_part_number IS 'BOGO free card part number from table_part_num';
COMMENT ON COLUMN sa.x_bogo_configuration.card_pin_part_class IS 'Redemption card part class from table_part_class';
COMMENT ON COLUMN sa.x_bogo_configuration.esn_part_class IS 'ESN part class from table_part_class';
COMMENT ON COLUMN sa.x_bogo_configuration.esn_part_number IS 'ESN part number from table_part_num';
COMMENT ON COLUMN sa.x_bogo_configuration.esn_dealer_id IS 'ESN dealer ID from table_inv_bin table';
COMMENT ON COLUMN sa.x_bogo_configuration.esn_dealer_name IS 'Dealer name assigned only in this table';
COMMENT ON COLUMN sa.x_bogo_configuration.eligible_service_plan IS 'Service plan ID from x_service_plan table for redemption card';
COMMENT ON COLUMN sa.x_bogo_configuration.channel IS 'Channel or method of data input from table x_bogo_channel';
COMMENT ON COLUMN sa.x_bogo_configuration.action_type IS 'Action associated with the activity for the BOGO application';
COMMENT ON COLUMN sa.x_bogo_configuration.tsp_id IS 'TSP unique value for Tracfone Branded Stores';
COMMENT ON COLUMN sa.x_bogo_configuration.msg_script_id IS 'Message script ID with verbiage for execution front-end';
COMMENT ON COLUMN sa.x_bogo_configuration.bogo_start_date IS 'Effective start date for BOGO';
COMMENT ON COLUMN sa.x_bogo_configuration.bogo_end_date IS 'Effective end date for BOGO';
COMMENT ON COLUMN sa.x_bogo_configuration.appl_execution_id IS 'Front-end application Execution ID used to identify a group of records';
COMMENT ON COLUMN sa.x_bogo_configuration.bogo_status IS 'Status of the BOGO record used for application criteria';
COMMENT ON COLUMN sa.x_bogo_configuration.created_by IS 'User ID who created record from front-end application';
COMMENT ON COLUMN sa.x_bogo_configuration.created_date IS 'date and time when record was created from front-end application';
COMMENT ON COLUMN sa.x_bogo_configuration.updated_by IS 'User ID who updated record from front-end application';
COMMENT ON COLUMN sa.x_bogo_configuration.updated_date IS 'date and time when record was updated from front-end application';
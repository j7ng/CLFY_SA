CREATE TABLE sa.x_service_order_stage (
  objid NUMBER(22) NOT NULL,
  account_group_member_id NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE),
  sim VARCHAR2(30 BYTE),
  zipcode VARCHAR2(10 BYTE),
  service_plan_id NUMBER(22),
  case_id NUMBER(22),
  smp VARCHAR2(30 BYTE),
  status VARCHAR2(30 BYTE) NOT NULL,
  "TYPE" VARCHAR2(30 BYTE),
  program_param_id NUMBER(22),
  pmt_source_id VARCHAR2(30 BYTE),
  part_num VARCHAR2(30 BYTE),
  web_objid NUMBER(22),
  bus_org_id VARCHAR2(40 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  discount_code_list sa.discount_code_tab,
  CONSTRAINT x_service_order_stage_pk PRIMARY KEY (objid)
)
NESTED TABLE discount_code_list STORE AS discount_code_list_sos_nt;
COMMENT ON TABLE sa.x_service_order_stage IS 'Store pre-activation information for all devices.';
COMMENT ON COLUMN sa.x_service_order_stage.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_service_order_stage.account_group_member_id IS 'Unique identifier of the account group member.';
COMMENT ON COLUMN sa.x_service_order_stage.esn IS 'Member ESN to be activated.';
COMMENT ON COLUMN sa.x_service_order_stage.sim IS 'SIM.';
COMMENT ON COLUMN sa.x_service_order_stage.zipcode IS 'Zipcode to be activated.';
COMMENT ON COLUMN sa.x_service_order_stage.service_plan_id IS 'In case of enrollment, enrolling service plan id.';
COMMENT ON COLUMN sa.x_service_order_stage.case_id IS 'Populated if the esn requires port.';
COMMENT ON COLUMN sa.x_service_order_stage.status IS 'PAYMENT_PENDING: initial status when inserted, QUEUED: when payment is completed, PROCESSING: when activation job picks record, COMPLETED: when activation job completes successfully, FAILED: when activation job failed.';
COMMENT ON COLUMN sa.x_service_order_stage."TYPE" IS 'ACTIVATION, PORT, REACTIVATION, EXCHANGE, GENCODE: used after PPE is active.';
COMMENT ON COLUMN sa.x_service_order_stage.program_param_id IS 'For enrollment.';
COMMENT ON COLUMN sa.x_service_order_stage.pmt_source_id IS 'Payment Source Identifier.';
COMMENT ON COLUMN sa.x_service_order_stage.discount_code_list IS 'Nested table column to store list of applicable discount codes for a PIN which are sent by BRM / front end';
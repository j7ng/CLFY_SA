CREATE TABLE sa.x_portout_winback_log (
  objid NUMBER NOT NULL,
  "MIN" VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  request_no VARCHAR2(100 BYTE),
  short_parent_name VARCHAR2(100 BYTE),
  desired_due_date DATE,
  nnsp VARCHAR2(100 BYTE),
  directional_indicator VARCHAR2(100 BYTE),
  osp_account_no VARCHAR2(100 BYTE),
  portout_carrier VARCHAR2(50 BYTE),
  winback_case_objid NUMBER,
  winback_case_id_number VARCHAR2(255 BYTE),
  winback_offer_status VARCHAR2(100 BYTE),
  port_out_status VARCHAR2(30 BYTE),
  status_message VARCHAR2(4000 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  request_xml XMLTYPE,
  sp_objid NUMBER(22),
  promo_type VARCHAR2(30 BYTE),
  CONSTRAINT pk_portout_winback_log PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_portout_winback_log IS 'PORT OUT REQUEST LOG TABLE';
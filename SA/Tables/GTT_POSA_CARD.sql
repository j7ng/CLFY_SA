CREATE GLOBAL TEMPORARY TABLE sa.gtt_posa_card (
  objid NUMBER NOT NULL,
  tf_part_num_parent VARCHAR2(100 BYTE) NOT NULL,
  tf_serial_num VARCHAR2(100 BYTE) NOT NULL,
  toss_att_customer VARCHAR2(100 BYTE),
  toss_att_location VARCHAR2(100 BYTE),
  toss_posa_code VARCHAR2(100 BYTE),
  toss_posa_date DATE,
  tf_extract_flag VARCHAR2(1 BYTE),
  tf_extract_date DATE,
  toss_site_id VARCHAR2(40 BYTE),
  toss_posa_action VARCHAR2(40 BYTE),
  remote_trans_id VARCHAR2(20 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  toss_att_trans_date DATE,
  access_code VARCHAR2(30 BYTE),
  auth_code VARCHAR2(30 BYTE),
  reg_no VARCHAR2(30 BYTE),
  upc VARCHAR2(30 BYTE),
  CONSTRAINT pk_gtt_posa_card PRIMARY KEY (objid)
)
ON COMMIT PRESERVE ROWS;
COMMENT ON TABLE sa.gtt_posa_card IS 'Global Temporary table to hold a posa card dummy record';
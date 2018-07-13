CREATE TABLE sa.mtm_bogo_bi_info (
  objid NUMBER(10) NOT NULL,
  bogo_objid NUMBER(10),
  esn VARCHAR2(30 BYTE),
  call_trans_objid NUMBER(22),
  orignal_red_code VARCHAR2(30 BYTE),
  x_smp VARCHAR2(30 BYTE),
  bogo_part_num_red_code VARCHAR2(30 BYTE),
  transaction_dt DATE,
  original_red_code VARCHAR2(30 BYTE),
  bogo_smp VARCHAR2(30 BYTE),
  bogo_part_num VARCHAR2(30 BYTE),
  bogo_red_card_pin VARCHAR2(30 BYTE),
  tsp_id VARCHAR2(15 BYTE),
  CONSTRAINT mtm_bogo_bi_info_pk PRIMARY KEY (objid) USING INDEX sa.ux1_mtm_bogo_bi_info
);
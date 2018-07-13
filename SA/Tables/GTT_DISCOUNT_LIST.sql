CREATE GLOBAL TEMPORARY TABLE sa.gtt_discount_list (
  call_trans_objid NUMBER NOT NULL,
  discount_code VARCHAR2(100 BYTE) NOT NULL,
  insert_timestamp DATE,
  update_timestamp DATE,
  CONSTRAINT pk_gtt_discount_list PRIMARY KEY (call_trans_objid,discount_code)
)
ON COMMIT PRESERVE ROWS;
COMMENT ON TABLE sa.gtt_discount_list IS 'Global Temporary table to hold discount list';
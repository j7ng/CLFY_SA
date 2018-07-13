CREATE TABLE sa.x_ct_sync_spr_trigger (
  esn VARCHAR2(30 BYTE) NOT NULL,
  action_type VARCHAR2(20 BYTE) NOT NULL,
  call_trans_reason VARCHAR2(100 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  "ROW_NUMBER" NUMBER(38),
  sub_sourcesystem VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_ct_sync_spr_trigger PRIMARY KEY (esn,action_type)
);
COMMENT ON COLUMN sa.x_ct_sync_spr_trigger.sub_sourcesystem IS 'Source System of the Transaction for brand';
COMMENT ON COLUMN sa.x_ct_sync_spr_trigger.insert_timestamp IS 'Insert time stamp for the transaction';
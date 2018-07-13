CREATE TABLE sa.x_ct_sync_spr_trigger_bkp_2 (
  esn VARCHAR2(30 BYTE) NOT NULL,
  action_type VARCHAR2(20 BYTE),
  call_trans_reason VARCHAR2(100 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  "ROW_NUMBER" NUMBER(38)
);
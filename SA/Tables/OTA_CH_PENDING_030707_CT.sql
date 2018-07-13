CREATE TABLE sa.ota_ch_pending_030707_ct (
  esn VARCHAR2(20 BYTE),
  smp VARCHAR2(30 BYTE),
  x_transact_date DATE,
  x_sourcesystem VARCHAR2(30 BYTE),
  x_total_units NUMBER,
  x_action_type VARCHAR2(20 BYTE),
  x_result VARCHAR2(20 BYTE),
  x_code_accepted VARCHAR2(10 BYTE),
  call_trans_objid NUMBER,
  rc_call_trans_objid NUMBER,
  rc_result VARCHAR2(100 BYTE),
  rc_red_code VARCHAR2(20 BYTE),
  rc_red_date DATE,
  ota_pend_seq NUMBER,
  ota_pend_code VARCHAR2(200 BYTE),
  yes_accept_seq NUMBER,
  yes_accept_code VARCHAR2(200 BYTE)
);
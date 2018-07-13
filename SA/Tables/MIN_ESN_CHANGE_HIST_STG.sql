CREATE TABLE sa.min_esn_change_hist_stg (
  s_transaction_id NUMBER(38),
  s_attached_date DATE,
  s_x_min VARCHAR2(30 BYTE),
  s_x_old_esn VARCHAR2(30 BYTE),
  s__x_detach_dt DATE,
  s_x_new_esn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.min_esn_change_hist_stg ADD SUPPLEMENTAL LOG GROUP dmtsora144000039_0 (s_attached_date, s_transaction_id, s_x_min, s_x_new_esn, s_x_old_esn, s__x_detach_dt) ALWAYS;
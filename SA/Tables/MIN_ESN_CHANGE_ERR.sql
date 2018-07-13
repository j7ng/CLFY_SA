CREATE TABLE sa.min_esn_change_err (
  s_x_transaction_id NUMBER(38),
  s_x_attached_date DATE,
  s_x_min VARCHAR2(30 BYTE),
  s_x_old_esn VARCHAR2(30 BYTE),
  s_x_detach_dt DATE,
  s_x_new_esn VARCHAR2(30 BYTE),
  error_text VARCHAR2(2000 BYTE)
);
ALTER TABLE sa.min_esn_change_err ADD SUPPLEMENTAL LOG GROUP dmtsora901861116_0 (error_text, s_x_attached_date, s_x_detach_dt, s_x_min, s_x_new_esn, s_x_old_esn, s_x_transaction_id) ALWAYS;
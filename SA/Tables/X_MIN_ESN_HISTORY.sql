CREATE TABLE sa.x_min_esn_history (
  x_transaction_id NUMBER(38) NOT NULL,
  x_min VARCHAR2(30 BYTE) NOT NULL,
  x_attached_dt DATE,
  x_old_esn VARCHAR2(30 BYTE) NOT NULL,
  x_detach_dt DATE NOT NULL,
  x_new_esn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_min_esn_history ADD SUPPLEMENTAL LOG GROUP dmtsora2131209586_0 (x_attached_dt, x_detach_dt, x_min, x_new_esn, x_old_esn, x_transaction_id) ALWAYS;
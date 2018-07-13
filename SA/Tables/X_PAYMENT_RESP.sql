CREATE TABLE sa.x_payment_resp (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(30 BYTE),
  x_attempt VARCHAR2(1 BYTE),
  x_resp_code VARCHAR2(255 BYTE),
  x_decline VARCHAR2(1 BYTE),
  x_reversal VARCHAR2(1 BYTE),
  x_cycle_date DATE,
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_payment_resp ADD SUPPLEMENTAL LOG GROUP dmtsora1515099939_0 (objid, x_attempt, x_cycle_date, x_decline, x_esn, x_resp_code, x_reversal, x_update_stamp, x_update_status, x_update_user) ALWAYS;
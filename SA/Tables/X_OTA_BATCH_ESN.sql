CREATE TABLE sa.x_ota_batch_esn (
  batch_id VARCHAR2(30 BYTE) NOT NULL,
  esn VARCHAR2(30 BYTE) NOT NULL,
  "MIN" VARCHAR2(30 BYTE),
  contact_objid NUMBER,
  zip_code VARCHAR2(10 BYTE),
  iccid VARCHAR2(30 BYTE),
  x_restricted_use NUMBER,
  status NUMBER,
  action_type NUMBER,
  x_call_trans_objid NUMBER,
  creation_date DATE,
  sent_date DATE,
  resent_date DATE,
  expiration_date DATE
);
ALTER TABLE sa.x_ota_batch_esn ADD SUPPLEMENTAL LOG GROUP dmtsora1636591203_0 (action_type, batch_id, contact_objid, creation_date, esn, expiration_date, iccid, "MIN", resent_date, sent_date, status, x_call_trans_objid, x_restricted_use, zip_code) ALWAYS;
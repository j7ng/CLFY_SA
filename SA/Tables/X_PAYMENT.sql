CREATE TABLE sa.x_payment (
  objid NUMBER NOT NULL,
  x_trans_id VARCHAR2(50 BYTE),
  x_rel_trans_id VARCHAR2(50 BYTE),
  x_order_id VARCHAR2(50 BYTE) NOT NULL,
  x_pymt_status VARCHAR2(50 BYTE) NOT NULL,
  x_status_desc VARCHAR2(255 BYTE),
  x_create_date DATE NOT NULL,
  x_update_date DATE NOT NULL,
  x_amount NUMBER(19,2) NOT NULL,
  x_tax_amount NUMBER(19,2),
  CONSTRAINT x_pymt_objid_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_payment IS 'STORES INFORMATION ABOUT PAYMENT';
COMMENT ON COLUMN sa.x_payment.objid IS 'INTERNAL RECORD ID';
COMMENT ON COLUMN sa.x_payment.x_trans_id IS 'UUID ? OF CURRENT TRANSACTION';
COMMENT ON COLUMN sa.x_payment.x_rel_trans_id IS 'UUID- OF PREVIOUS TRANSACTION';
COMMENT ON COLUMN sa.x_payment.x_order_id IS 'PURCHASE ORDER ID TO BE SENT BY CLIENTS WHILE PLACING THE TRANSACTION';
COMMENT ON COLUMN sa.x_payment.x_pymt_status IS 'PAYMENT STATUS';
COMMENT ON COLUMN sa.x_payment.x_create_date IS 'RECORD CREATE TIMESTAMP';
COMMENT ON COLUMN sa.x_payment.x_update_date IS 'RECORD UPDATE TIMESTAMP';
COMMENT ON COLUMN sa.x_payment.x_amount IS 'TOTAL TRANSACTION AMOUNT';
COMMENT ON COLUMN sa.x_payment.x_tax_amount IS 'TOTAL TAX AMOUNT';
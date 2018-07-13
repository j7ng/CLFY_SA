CREATE TABLE sa.x_republik_refund_ext (
  toss_order_id NUMBER NOT NULL,
  pt_ext_record_id VARCHAR2(1 BYTE) DEFAULT 'E',
  pt_ext_record_mop_type VARCHAR2(2 BYTE) DEFAULT 'EC',
  pt_ext_sequnce VARCHAR2(3 BYTE) DEFAULT '001',
  pt_bank_id VARCHAR2(9 BYTE),
  pt_filler1 VARCHAR2(5 BYTE),
  pt_account_type VARCHAR2(1 BYTE) DEFAULT 'C',
  pt_pref_delivery_method VARCHAR2(1 BYTE) DEFAULT 'A',
  pt_reserved VARCHAR2(16 BYTE),
  pt_ecp_auth_method VARCHAR2(1 BYTE) DEFAULT 'T',
  pt_filler2 VARCHAR2(57 BYTE)
);
ALTER TABLE sa.x_republik_refund_ext ADD SUPPLEMENTAL LOG GROUP dmtsora368020685_0 (pt_account_type, pt_bank_id, pt_ecp_auth_method, pt_ext_record_id, pt_ext_record_mop_type, pt_ext_sequnce, pt_filler1, pt_filler2, pt_pref_delivery_method, pt_reserved, toss_order_id) ALWAYS;
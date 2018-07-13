CREATE TABLE sa.table_mobile_complete_handset (
  objid NUMBER NOT NULL,
  brand_name VARCHAR2(30 BYTE) NOT NULL,
  part_class VARCHAR2(30 BYTE) NOT NULL,
  cust_id VARCHAR2(30 BYTE),
  locale VARCHAR2(16 BYTE)
);
COMMENT ON COLUMN sa.table_mobile_complete_handset.objid IS 'PRIMARY KEY';
COMMENT ON COLUMN sa.table_mobile_complete_handset.brand_name IS 'BRAND NAME EITHER ?NET10? OR ?TRACFONE?';
COMMENT ON COLUMN sa.table_mobile_complete_handset.part_class IS 'HANDSET MODEL PART CLASS DEFINED IN THE TABLE SA.TABLE_PART_CLASS';
COMMENT ON COLUMN sa.table_mobile_complete_handset.cust_id IS 'THE CUSTID VALUE FROM MOBILE COMPLETE HANDSET TUTORIAL HOME PAGE URL';
COMMENT ON COLUMN sa.table_mobile_complete_handset.locale IS 'EITHER EN_US OR ES_US';
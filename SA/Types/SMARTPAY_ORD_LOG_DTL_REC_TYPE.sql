CREATE OR REPLACE TYPE sa.SMARTPAY_ORD_LOG_DTL_REC_TYPE
IS
  OBJECT
  (
    GROUP_ID                      VARCHAR2(20 BYTE),
    ESN                           VARCHAR2(30 BYTE),
    SMP                           VARCHAR2(30 BYTE),
    SP_ORD_LOG_DTL2SP_ORD_LOG_HDR NUMBER,
    QUANTITY                      NUMBER,
    PRODUCT_AMOUNT                NUMBER(19, 2),
    PRODUCT_TYPE                  VARCHAR2(50 BYTE),
    PRODUCT_DESCRIPTION           VARCHAR2(255 BYTE),
    MERCHANT_PRODUCT_SKU          VARCHAR2(30 BYTE)
  );
/
CREATE OR REPLACE TYPE sa.typ_bill_hist_rec
IS
  object
  (
    payment_id        VARCHAR2(30),
    PAYMENT_DATE      DATE,
    PAYMENT_STATUS    VARCHAR2(200),
    PAYMENT_AMOUNT    VARCHAR2(100),
    payment_source_id VARCHAR2(100),
    org_name        VARCHAR2(50),
    org_id            VARCHAR2(50),
    buyer_id          VARCHAR2(50),
    MIN               VARCHAR2(30),
    esn               VARCHAR2(30),
    phone_nick_name   VARCHAR2(30),
    subtotal_amount   NUMBER(19,2) ,
    sales_TAX_AMOUNT  NUMBER(19,2),
    USF_TAXAMOUNT     NUMBER,
    E911_TAX_AMOUNT   NUMBER,
    RCRF_TAX_AMOUNT   NUMBER,
    bill_amount       NUMBER,
    DISCOUNT_AMOUNT   NUMBER);
/
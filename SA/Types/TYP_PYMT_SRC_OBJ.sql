CREATE OR REPLACE type sa.typ_pymt_src_obj
IS
  object
  (
    PAYMENT_SOURCE_ID   varchar2(50),
    PAYMENT_TYPE        varchar2(30),
    PAYMENT_STATUS      varchar2(20),
    IS_DEFAULT          number,
    USER_ID             varchar2(80),
    X_CUSTOMER_CC_NUMBER varchar2(100),
    x_cc_type  varchar2(50) )
/
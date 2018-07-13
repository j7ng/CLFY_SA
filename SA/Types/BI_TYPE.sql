CREATE OR REPLACE TYPE sa.bi_type
AS
  OBJECT
  (
    measure_unit    VARCHAR2(50),
    transaction_id  NUMBER(22) ,
    bucket_id       VARCHAR2(30),
    bucket_balance  VARCHAR2(30) ,
    bucket_value    VARCHAR2(30),
    expiration_date DATE,
    bucket_type     VARCHAR2(50)
    );
/
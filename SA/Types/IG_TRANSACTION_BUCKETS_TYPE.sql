CREATE OR REPLACE TYPE sa.ig_transaction_buckets_type AS OBJECT
(
    transaction_id       NUMBER,
    bucket_id            VARCHAR2(30),
    recharge_date        DATE,
    bucket_balance       VARCHAR2(30),
    bucket_value         VARCHAR2(30),
    expiration_date      DATE,
    direction            VARCHAR2(30),
    benefit_type         VARCHAR2(100),
    bucket_type          VARCHAR2(100)
 )
/
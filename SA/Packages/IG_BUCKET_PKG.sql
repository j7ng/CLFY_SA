CREATE OR REPLACE PACKAGE sa.ig_bucket_pkg aS
  cursor c1 is
    select bucket_id,
           bucket_balance,
           bucket_value ,
           expiration_date,
           recharge_date,
           direction,
     benefit_type,
     bucket_type
      from gw1.ig_transaction_buckets;
  TYPE refcur_t IS REF CURSOR RETURN c1%rowtype;
END ig_bucket_pkg;
/
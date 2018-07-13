CREATE OR REPLACE TYPE sa.ig_transaction_bucket_type IS OBJECT
(
    bucket_id 		    VARCHAR2(100),
    CONSTRUCTOR       FUNCTION ig_transaction_bucket_type RETURN SELF AS  RESULT
);
/
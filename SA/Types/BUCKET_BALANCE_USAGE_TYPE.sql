CREATE OR REPLACE TYPE sa.bucket_balance_usage_type
AS
  OBJECT
  (
    OBJID                   NUMBER,
    BALANCE_BUCKET2X_SWB_TX NUMBER,
    X_TYPE                  VARCHAR2(80),
    X_VALUE                 VARCHAR2(80),
    BUCKET_USAGE            VARCHAR2(80),
    RECHARGE_DATE           DATE,
    EXPIRATION_DATE         DATE,
    BUCKET_DESC             VARCHAR2(80) ,
	BUCKET_GROUP            VARCHAR2(50),
    CONSTRUCTOR  FUNCTION bucket_balance_usage_type RETURN SELF AS  RESULT
  );
/
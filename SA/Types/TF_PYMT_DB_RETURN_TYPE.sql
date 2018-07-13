CREATE OR REPLACE TYPE sa.TF_PYMT_DB_RETURN_TYPE  IS OBJECT (
CUSTOMER_FIRST_NAME                           VARCHAR2(500),
CUSTOMER_LAST_NAME                            VARCHAR2(500),
PROGRAM_NOTIFY_OBJ_ID                         VARCHAR2(500),
PURCHASE_HEADER_ID                            VARCHAR2(500),
PROGRAM_ENROLL_ID                             VARCHAR2(500),
REQUEST_TYPE                                  VARCHAR2(500),
ICS_RCODE                                     VARCHAR2(500),
ESN                                           VARCHAR2(500),
LANGUAGE                                      VARCHAR2(500),
PROGRAM_ID                                    VARCHAR2(500),
PROGRAM_NAME                                  VARCHAR2(500),
SOURCE_SYSTEM                                 VARCHAR2(500),
ORG_ID                                        VARCHAR2(500),
WEB_USER_ID                                   VARCHAR2(500),
PAYMENT_SOURCE_ID                             VARCHAR2(500),
BILL_AMOUNT                                   NUMBER,
PYMT_TYPE                                     VARCHAR2(500),
BILL_REQUEST_TIME                             VARCHAR2(500),
MERCHANT_REF_NUMBER                           VARCHAR2(500),
GRACE_PERIOD                                  NUMBER,
FILLER_ONE                                    VARCHAR2(2000),
FILLER_TWO                                    VARCHAR2(2000),
FILLER_THREE                                  VARCHAR2(2000),
FILLER_FOUR                                   VARCHAR2(2000),
FILLER_FIVE                                   VARCHAR2(2000),
EXP_DATE                                      DATE
)
/
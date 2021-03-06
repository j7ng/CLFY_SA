CREATE OR REPLACE TYPE sa.TF_PYMT_RESPONSE_TYPE  IS OBJECT (
PROCESS_TYPE                         VARCHAR2(2000),
PROCESS_RESPONSE                     VARCHAR2(2000),
AVS                                  VARCHAR2(2000),
AUTH_AUTH_AMOUNT                     VARCHAR2(2000),
AUTH_AUTH_AVS                        VARCHAR2(2000),
AUTH_AUTH_CODE                       VARCHAR2(2000),
AUTH_AUTH_RESPONSE                   VARCHAR2(2000),
AUTH_AUTH_TIME                       VARCHAR2(2000),
AUTH_CV_RESULT                       VARCHAR2(2000),
AUTH_RCODE                           VARCHAR2(2000),
AUTH_REQUEST_ID                      VARCHAR2(2000),
AUTH_RFLAG                           VARCHAR2(2000),
AUTH_RMSG                            VARCHAR2(2000),
BILL_BILL_AMOUNT                     VARCHAR2(2000),
BILL_BILL_REQUEST_TIME               VARCHAR2(2000),
BILL_RCODE                           VARCHAR2(2000),
BILL_RFLAG                           VARCHAR2(2000),
BILL_RMSG                            VARCHAR2(2000),
BILL_TRANS_REF_NO                    VARCHAR2(2000),
ICS_RCODE                            VARCHAR2(2000),
ICS_RFLAG                            VARCHAR2(2000),
ICS_RMSG                             VARCHAR2(2000),
REQUEST_ID                           VARCHAR2(2000),
SCORE_FACTORS                        VARCHAR2(2000),
SCORE_HOST_SEVERITY                  VARCHAR2(2000),
SCORE_RCODE                          VARCHAR2(2000),
SCORE_RFLAG                          VARCHAR2(2000),
SCORE_RMSG                           VARCHAR2(2000),
SCORE_SCORE_RESULT                   VARCHAR2(2000),
SCORE_TIME_LOCAL                     VARCHAR2(2000),
TIME_LOCAL                           VARCHAR2(2000),
HOST_SEVERITY                        VARCHAR2(2000),
SCORE_IFS4_SCORE                     VARCHAR2(2000),
FACTORS                              VARCHAR2(2000),
CREDIT_CREDIT_AMOUNT                 VARCHAR2(2000),
CREDIT_CREDIT_REQUEST_TIME           VARCHAR2(2000),
CREDIT_RCODE                         VARCHAR2(2000),
CREDIT_RFLAG                         VARCHAR2(2000),
CREDIT_RMSG                          VARCHAR2(2000),
CREDIT_TRANS_REF_NO                  VARCHAR2(2000),
CREDIT_AUTH_RESPONSE                 VARCHAR2(2000),
OUT_STATUS                           VARCHAR2(2000),
ACH_TRANS                            TF_PYMT_ACH_TRANS_TYPE,
DB_RESPONSE                          TF_PYMT_DB_RETURN_TYPE,
FILLER_ONE                           VARCHAR2(2000),
FILLER_TWO                           VARCHAR2(2000),
FILLER_THREE                         VARCHAR2(2000),
FILLER_FOUR                          VARCHAR2(2000),
FILLER_FIVE                          VARCHAR2(2000),
ERROR_CODE                           VARCHAR2(1000),
ERROR_DESC                           VARCHAR2(1000)
)
/
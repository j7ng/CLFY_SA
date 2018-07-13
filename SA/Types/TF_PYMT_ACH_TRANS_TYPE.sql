CREATE OR REPLACE TYPE sa.TF_PYMT_ACH_TRANS_TYPE  IS OBJECT (
DEBIT_REQUEST_ID                           VARCHAR2(2000),
DEBIT_AVS_CODE                             VARCHAR2(2000),
DEBIT_AVS_RAW                              VARCHAR2(2000),
DEBIT_ECP_REASONCODE                       VARCHAR2(2000),
DEBIT_ECP_TRANS_ID                         VARCHAR2(2000),
DEBIT_ECP_RESULT_CODE                      VARCHAR2(2000),
DEBIT_ECP_RCODE                            VARCHAR2(2000),
DEBIT_ECP_RFLAG                            VARCHAR2(2000),
DEBIT_ECP_RMSG                             VARCHAR2(2000),
DEBIT_ECP_REF_NO                           VARCHAR2(2000),
DEBIT_ECP_REF_NUMBER                       VARCHAR2(2000),
DEBIT_SETTLEMENT_METHOD                    VARCHAR2(2000),
DEBIT_SUBMIT_TIME                          VARCHAR2(2000),
DEBIT_TOTAL_AMOUNT                         VARCHAR2(2000),
DEBIT_FILLER_ONE                           VARCHAR2(2000),
DEBIT_FILLER_TWO                           VARCHAR2(2000),
DEBIT_FILLER_THREE                         VARCHAR2(2000),
DEBIT_FILLER_FOUR                          VARCHAR2(2000),
DEBIT_FILLER_FIVE                          VARCHAR2(2000)
)
/
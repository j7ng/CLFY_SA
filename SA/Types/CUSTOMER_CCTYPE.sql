CREATE OR REPLACE TYPE sa.CUSTOMER_CCTYPE  IS OBJECT (
         CUST_ENCRYPTED_CC               VARCHAR2 (20),
         CUST_ACH                        VARCHAR2 (20),
         CUST_EXP_DATE                   VARCHAR2 (20),
         CUST_FRAUD_FLAG                 VARCHAR2 (20));
/
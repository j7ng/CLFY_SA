CREATE OR REPLACE TYPE sa.CUSTOMER_DETAILS  IS OBJECT (
     CUST_LAST_NAME                   VARCHAR2(100),
     CUST_FIRST_NAME                  VARCHAR2(100),
     CUST_ESN                         VARCHAR2(100),
     CUST_ADDRESS                     CUSTOMER_ADDRESSTAB,
     CUST_EMAIL                       CUSTOMER_EMAILTYPE,
     CUST_SMS                         CUSTOMER_SMSTYPE,
     CUST_CC                          CUSTOMER_CCTYPE);
/
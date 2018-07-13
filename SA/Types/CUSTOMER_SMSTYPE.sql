CREATE OR REPLACE TYPE sa.CUSTOMER_SMSTYPE  IS OBJECT (
      CUST_DLL                             VARCHAR2 (20),
      CUST_MIN                             VARCHAR2 (20),
      TEXT_MESSAGE                         VARCHAR2 (200));
/
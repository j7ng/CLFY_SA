CREATE OR REPLACE TYPE sa.CUSTOMER_ADDRESSTYPE IS OBJECT (
        CUST_ADDRESS_TYPE                VARCHAR2(100),
        CUST_ADDRESS1                    VARCHAR2(100),
        CUST_ADDRESS2                    VARCHAR2(100),
        CUST_ADDRESS3                    VARCHAR2(100),
        CUST_CITY                        VARCHAR2(100),
        CUST_STATE                       VARCHAR2(100),
        CUST_ZIP                         VARCHAR2(100),
        CUST_COUNTRY                     VARCHAR2(100));
/
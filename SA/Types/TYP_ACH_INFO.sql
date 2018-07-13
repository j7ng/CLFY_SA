CREATE OR REPLACE type sa.typ_ACH_info AS object (
routing_number    VARCHAR2(100),
account_number VARCHAR2(400),
account_type      VARCHAR2(100),
customer_acct_key VARCHAR2(400),
customer_acct_enc VARCHAR2(400),
cert              VARCHAR2(100),
key_algo          VARCHAR2(128),
cc_algo           VARCHAR2(128),
constructor FUNCTION typ_ACH_info RETURN self AS result )
/
CREATE OR REPLACE type body sa.typ_ACH_info IS constructor FUNCTION typ_ACH_info RETURN self AS result IS
BEGIN
RETURN;
END;
END;
/
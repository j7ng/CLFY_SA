CREATE OR REPLACE TYPE sa.simout_log_obj
AS
OBJECT
(
  CLIENT_TRANS_ID     VARCHAR2  (100),
  CLIENT_ID           VARCHAR2  (30),
  ESN                 VARCHAR2  (30),
  SIM                 VARCHAR2  (30),
  BRAND               VARCHAR2  (30),
  SOURCE_SYSTEM       VARCHAR2  (30),
  DEALER_ID           VARCHAR2  (80),
  STORE_ID            VARCHAR2  (80),
  TERMINAL_ID         VARCHAR2  (80),
  PHONE_MAKE          VARCHAR2  (100),
  PHONE_MODEL         VARCHAR2  (100),
  RETRY_FLAG          VARCHAR2  (1),
  VD_TRANS_ID         VARCHAR2  (20),
  INSERT_DATE         VARCHAR2  (200),
  REGISTER_STATUS     VARCHAR2  (100)
);
/
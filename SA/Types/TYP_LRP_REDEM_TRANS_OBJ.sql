CREATE OR REPLACE TYPE sa."TYP_LRP_REDEM_TRANS_OBJ" FORCE IS OBJECT (
OBJID                                 NUMBER        ,
TRANS_DATE                            DATE          ,
WEB_ACCOUNT_ID                        VARCHAR2(100) ,
SUBSCRIBER_ID                         VARCHAR2(100) ,
MIN                                   VARCHAR2(100) ,
ESN                                   VARCHAR2(100) ,
OLD_MIN                               VARCHAR2(100) ,
OLD_ESN                               VARCHAR2(100) ,
TRANS_TYPE                            VARCHAR2(100) ,
TRANS_DESC                            VARCHAR2(100) ,
AMOUNT                                NUMBER(12,2)  ,
BENEFIT_TYPE_CODE                     VARCHAR2(100) ,
ACTION                                VARCHAR2(100) ,
ACTION_TYPE                           VARCHAR2(100) ,
ACTION_REASON                         VARCHAR2(100) ,
BENEFIT_TRANS2BENEFIT_TRANS           NUMBER        ,
SVC_PLAN_PIN                          VARCHAR2(100) ,
SVC_PLAN_ID                           VARCHAR2(100) ,
BRAND                                 VARCHAR2(100) ,
BENEFIT_TRANS2BENEFIT                 NUMBER        ,
TRANSACTION_STATUS			              VARCHAR2(30)  ,                       -- CR41473 LRP2
MATURITY_DATE	                        DATE     ,                            -- CR41473 LRP2
EXPIRATION_DATE	                      DATE     ,                            -- CR41473 LRP2
SOURCE		                            VARCHAR2 (30) ,                       -- CR41473 LRP2
SOURCE_TRANS_ID	                      VARCHAR2 (30) ,                       -- CR41473 LRP2
	STATIC FUNCTION INITIALIZE RETURN TYP_LRP_REDEM_TRANS_OBJ
);
/
CREATE OR REPLACE TYPE BODY sa."TYP_LRP_REDEM_TRANS_OBJ" IS
	STATIC FUNCTION INITIALIZE RETURN TYP_LRP_REDEM_TRANS_OBJ IS
	BEGIN
		RETURN  sa.TYP_LRP_REDEM_TRANS_OBJ (NULL					--OBJID
											,NULL                   --TRANS_DATE
											,NULL                   --WEB_ACCOUNT_ID
											,NULL                   --SUBSCRIBER_ID
											,NULL                   --MIN
											,NULL                   --ESN
											,NULL                   --OLD_MIN
											,NULL                   --OLD_ESN
											,NULL                   --TRANS_TYPE
											,NULL                   --TRANS_DESC
											,NULL                   --AMOUNT
											,NULL                   --BENEFIT_TYPE_CODE
											,NULL                   --ACTION
											,NULL                   --ACTION_TYPE
											,NULL                   --ACTION_REASON
											,NULL                   --BENEFIT_TRANS2BENEFIT_TRANS
											,NULL                   --SVC_PLAN_PIN
											,NULL                   --SVC_PLAN_ID
											,NULL                   --BRAND
											,NULL                   --BENEFIT_TRANS2BENEFIT
                      ,NULL                   --TRANSACTION_STATUS				        -- CR41473 LRP2
                      ,NULL                   --MATURITY_DATE	                    -- CR41473 LRP2
                      ,NULL                   --EXPIRATION_DATE	                  -- CR41473 LRP2
                      ,NULL                   --SOURCE		                        -- CR41473 LRP2
                      ,NULL                   --SOURCE_TRANS_ID	                  -- CR41473 LRP2
	);

	END INITIALIZE;
END;
/
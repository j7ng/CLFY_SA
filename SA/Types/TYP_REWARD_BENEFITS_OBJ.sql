CREATE OR REPLACE TYPE sa.TYP_REWARD_BENEFITS_OBJ FORCE IS OBJECT (
     BENEFIT_ID               NUMBER
    ,BENEFIT_TYPE_CODE        VARCHAR2(100)
    ,BENEFIT_PROGRAM_NAME     VARCHAR2(100)
    ,BENEFIT_UNIT             VARCHAR2(100)
    ,BENEFIT_QUANTITY         NUMBER
    ,PENDING_QUANTITY         NUMBER                        -- CR41473 LRP2
    ,TOTAL_QUANTITY           NUMBER                        -- CR41473 LRP2
    ,BENEFIT_VALUE            NUMBER
    ,PARTIAL_USAGE_ALLOWED    VARCHAR2(1)
    ,PURCH_USAGE_ALLOWED      PURCH_USAGE_ALLOW
    ,MIN_THRESHOLD            NUMBER
    ,ENROLLMENT_DATE          DATE
    ,CREATED_DATE             DATE                        -- CR41473 LRP2
    ,ACCOUNT_STATUS           VARCHAR2(30)                -- CR41473 LRP2
    ,PROGRAM_NAME             VARCHAR2(100)               -- CR41473 LRP2
    ,EXPIRY_DATE              DATE                        -- CR41473 LRP2
    ,EXPIRED_QUANTITY         NUMBER						          -- CR41473 LRP2
    ,ENROLLMENT_TYPE          VARCHAR2(100)               -- CR41473 LRP2
    ,LOYALTY_TIER             NUMBER                      -- CR41473 LRP2
    ,REDEEMED_QUANTITY        NUMBER                      -- CR49726 LRP Redesign
	,STATIC FUNCTION INITIALIZE RETURN TYP_REWARD_BENEFITS_OBJ
);
/
CREATE OR REPLACE TYPE BODY sa.TYP_REWARD_BENEFITS_OBJ IS
	STATIC FUNCTION INITIALIZE RETURN TYP_REWARD_BENEFITS_OBJ IS
	BEGIN
		RETURN  sa.TYP_REWARD_BENEFITS_OBJ (NULL				        --BENEFIT_ID
                                        ,NULL               --BENEFIT_TYPE_CODE
                                        ,NULL               --BENEFIT_PROGRAM_NAME
                                        ,NULL               --BENEFIT_UNIT
                                        ,NULL               --BENEFIT_QUANTITY
                                        ,NULL               --PENDING_QUANTITY      			-- CR41473 LRP2
                                        ,NULL               --TOTAL_QUANTITY        			-- CR41473 LRP2
                                        ,NULL               --BENEFIT_VALUE
                                        ,NULL               --PARTIAL_USAGE_ALLOWED
                                        ,NULL               --PURCH_USAGE_ALLOWED
                                        ,NULL               --MIN_THRESHOLD
                                        ,NULL               --ENROLLMENT_DATE
                                        ,NULL               --CREATED_DATE
                                        ,NULL               --ACCOUNT_STATUS
                                        ,NULL               --PROGRAM_NAME
                                        ,NULL               --EXPIRY_DATE
                                        ,NULL               --EXPIRED_QUANTITY
                                        ,NULL               --ENROLLMENT_TYPE       			-- CR41473 LRP2
                                        ,NULL               --LOYALTY_TIER          			-- CR41473 LRP2
                                        ,NULL               --REDEEMED_QUANTITY           -- CR49726 LRP Redesign
                                        );
	END INITIALIZE;
END;
/
CREATE OR REPLACE TYPE sa.TYP_BENEFITS_INFO IS OBJECT (
BENEFIT_PROGRAM_NAME     VARCHAR2(100)
,BENEFIT_TYPE_CODE             VARCHAR2(100)
,BENEFIT_UNIT             VARCHAR2(100)
,PARTIAL_USAGE_ALLOWED    VARCHAR2(1)
,PURCH_USAGE_ALLOWED      PURCH_USAGE_ALLOW
,MIN_THRESHOLD            NUMBER
,MAX_THRESHOLD            NUMBER
,BENEFIT_EARNING_RULES    BEN_EARNINGS_RULE_TBL
,CONVERSION_RATIO         NUMBER
,STATIC FUNCTION INITIALIZE RETURN TYP_BENEFITS_INFO
);
/
CREATE OR REPLACE TYPE BODY sa."TYP_BENEFITS_INFO" IS
	STATIC FUNCTION INITIALIZE RETURN TYP_BENEFITS_INFO IS
	BEGIN
		RETURN  sa.TYP_BENEFITS_INFO (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
	END INITIALIZE;
END;
/
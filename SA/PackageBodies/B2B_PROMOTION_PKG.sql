CREATE OR REPLACE PACKAGE BODY sa.B2B_PROMOTION_PKG AS
  /***************************************************************************************************************
 Program Name       :  	FN_CHECK_ST_BUNDLE_FAMILY
 Program Type       :  	Function
 Program Arguments  :  	IP_ESN
                        IP_PROMO_OBJID
 Returns            :  	Number
 Program Called     :  	SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
 Description        :  	This function will let us know, if a B2B ESN is eligible for a promotion.
                        Business will insert record into SA.X_B2B_PROMO_ORG table to link relation between
                        organization and promotion.
 Modified By            Modification     CR             Description
                          Date           Number
 =============          ============     ======      ===================================
 Jai Arza   			        08/25/2015     35567	         Initial Creation
***************************************************************************************************************/
	FUNCTION FN_CHECK_B2B_PROMO_BY_ORG
    (
      IP_ESN              IN sa.X_PROGRAM_ENROLLED.X_ESN%TYPE
      , IP_PROMO_OBJID    IN sa.TABLE_X_PROMOTION.OBJID%TYPE
    )
    RETURN NUMBER
		AS
    LV_EXIST    PLS_INTEGER := 0;
  BEGIN
      IF IP_ESN IS NULL OR IP_PROMO_OBJID IS NULL THEN
        RETURN 0;
      END IF;

      SELECT  COUNT(*)
      INTO    LV_EXIST
      FROM    sa.X_B2B_PROMO_ORG B2B
              , sa.TABLE_SITE S
              , sa.X_SITE_WEB_ACCOUNTS SW
              , sa.TABLE_WEB_USER WEB
              , sa.TABLE_X_CONTACT_PART_INST CPI
              , sa.TABLE_PART_INST PI
      WHERE   1 = 1
      AND     B2B.X_PROMO_OBJID = IP_PROMO_OBJID
      AND     S.X_COMMERCE_ID = B2B.X_COMMERCE_ID
      AND     S.OBJID = SW.SITE_WEB_ACCT2SITE
      AND     SW.SITE_WEB_ACCT2WEB_USER = WEB.OBJID
      AND     WEB.WEB_USER2CONTACT = CPI.X_CONTACT_PART_INST2CONTACT
      AND     CPI.X_CONTACT_PART_INST2PART_INST = PI.OBJID
      AND     PI.PART_SERIAL_NO = IP_ESN
      ;
      IF LV_EXIST = 0 THEN
        RETURN 0;
      ELSE
        RETURN 1;
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
		sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error for IP_ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID, --p_action
									SYSDATE, --p_error_date
									IP_ESN, --p_key
									'SA.B2B_PROMOTION_PKG.FN_CHECK_B2B_PROMO_BY_ORG',--p_program_name
									'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
												);
		RAISE;
  END FN_CHECK_B2B_PROMO_BY_ORG;
/************************************************************************************************************
 Program Name       :  	SP_INSERT_X_B2B_PROMO_ORG
 Program Type       :  	Procedure
 Program Arguments  :  	IP_COMMERCE_ID
                        IP_PROMO_CODE
                        IP_X_START_DATE
                        IP_X_END_DATE
                        IP_USER_CREATED
 Returns            :  	OP_ERROR_CODE
                        OP_ERROR_MSG
 Program Called     :  	SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
 Description        :  	This procedure will insert data into table SA.X_B2B_PROMO_ORG
 Modified By            Modification     CR             Description
                          Date           Number
 =============          ============     ======      ===================================
 Jai Arza   			        08/25/2015     35567	         Initial Creation
***************************************************************************************************************/
	PROCEDURE SP_INSERT_X_B2B_PROMO_ORG
		(IP_COMMERCE_ID		IN	sa.X_B2B_PROMO_ORG.X_COMMERCE_ID%TYPE
		, IP_PROMO_CODE		IN	sa.X_B2B_PROMO_ORG.X_PROMO_CODE%TYPE
		, IP_X_START_DATE	IN	sa.X_B2B_PROMO_ORG.X_START_DATE%TYPE
		, IP_X_END_DATE		IN	sa.X_B2B_PROMO_ORG.X_END_DATE%TYPE
		, IP_USER_CREATED	IN	sa.X_B2B_PROMO_ORG.USER_CREATED%TYPE
		, OP_ERROR_CODE     OUT NUMBER
		, OP_ERROR_MSG      OUT VARCHAR2)
		 AS
		LV_SITE_EXIST			PLS_INTEGER := 0;
		LV_PROMO_OBJID			sa.TABLE_X_PROMOTION.OBJID%TYPE := NULL;
		LV_PROMO_GROUP_OBJID	sa.TABLE_X_PROMOTION_GROUP.OBJID%TYPE := NULL;
		LV_X_B2B_PROMO_ORG		sa.X_B2B_PROMO_ORG.OBJID%TYPE;
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Start of SP_INSERT_X_B2B_PROMO_ORG');
		OP_ERROR_CODE := 0;
		OP_ERROR_MSG := 'Success';
		SELECT 	COUNT(*)
		INTO	LV_SITE_EXIST
		FROM 	TABLE_SITE S
        WHERE 	1=1
        AND     S.X_COMMERCE_ID = IP_COMMERCE_ID
        ;
		DBMS_OUTPUT.PUT_LINE('LV_SITE_EXIST:'||LV_SITE_EXIST);
		IF LV_SITE_EXIST = 0 THEN
			OP_ERROR_CODE := 1;
			OP_ERROR_MSG := 'Organization id does not exist in SA.TABLE_SITE.X_COMMERCE_ID.';
			RETURN;
		END IF;

		BEGIN
			SELECT 	P.OBJID
			INTO 	LV_PROMO_OBJID
			FROM 	sa.TABLE_X_PROMOTION P
			WHERE 	P.X_PROMO_CODE=IP_PROMO_CODE;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				OP_ERROR_CODE := 1;
				OP_ERROR_MSG := 'Promotion code does not exist in SA.TABLE_X_PROMOTION.X_PROMO_CODE. Please provide a valid promo';
				RETURN;
		END;
		DBMS_OUTPUT.PUT_LINE('LV_PROMO_OBJID:'||LV_PROMO_OBJID);
		SELECT 	PMTM.X_PROMO_MTM2X_PROMO_GROUP
		INTO	LV_PROMO_GROUP_OBJID
		FROM	sa.TABLE_X_PROMOTION_MTM PMTM
		WHERE 	PMTM.X_PROMO_MTM2X_PROMOTION = LV_PROMO_OBJID;

		DBMS_OUTPUT.PUT_LINE('LV_PROMO_GROUP_OBJID:'||LV_PROMO_GROUP_OBJID);
		SELECT sa.SEQU_X_B2B_PROMO_ORG.NEXTVAL INTO LV_X_B2B_PROMO_ORG FROM DUAL;
		DBMS_OUTPUT.PUT_LINE('LV_X_B2B_PROMO_ORG:'||LV_X_B2B_PROMO_ORG);
		INSERT INTO sa.X_B2B_PROMO_ORG
			( 	OBJID
				, X_COMMERCE_ID
				, X_PROMO_OBJID
				, X_PROMO_CODE
				, X_PROMO_GROUP_OBJID
				, X_START_DATE
				, X_END_DATE
				, DATE_CREATED
				, USER_CREATED
				, DATE_UPDATED
				, USER_UPDATED)
		VALUES
			( 	LV_X_B2B_PROMO_ORG	--OBJID
				, IP_COMMERCE_ID		--X_COMMERCE_ID
				, LV_PROMO_OBJID		--X_PROMO_OBJID
				, IP_PROMO_CODE			--X_PROMO_CODE
				, LV_PROMO_GROUP_OBJID		--X_PROMO_GROUP_OBJID
				, IP_X_START_DATE
				, IP_X_END_DATE
				, SYSDATE				--DATE_CREATED
				, IP_USER_CREATED		--USER_CREATED
				, SYSDATE				--DATE_UPDATED
				, IP_USER_CREATED		--USER_UPDATED
				)
		;
		DBMS_OUTPUT.PUT_LINE('Number of records inserted: ' || TO_CHAR(SQL%ROWCOUNT)|| ' for objid:'||LV_X_B2B_PROMO_ORG);
		COMMIT;
    OP_ERROR_CODE := 0;
		OP_ERROR_MSG := 'Success';
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error while inserting data for IP_COMMERCE_ID:'||IP_COMMERCE_ID||', IP_PROMO_CODE:'||IP_PROMO_CODE, --p_action
									SYSDATE, --p_error_date
									IP_COMMERCE_ID, --p_key
									'SA.B2B_PROMOTION_PKG.SP_INSERT_X_B2B_PROMO_ORG',--p_program_name
									'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
												);
			OP_ERROR_CODE := 1;
			OP_ERROR_MSG := 'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
			RAISE;
	END SP_INSERT_X_B2B_PROMO_ORG;
END B2B_PROMOTION_PKG;
/
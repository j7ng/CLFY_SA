CREATE OR REPLACE PACKAGE BODY sa.PKG_FLIP_ENROLLED_ESN_PROMO
AS
 /***************************************************************************************************************
 Program Name : SP_GET_PROMO_USAGE_COUNT
 Program Type : Function
 Program Arguments : None
 Returns : None
 Program Called : None
 Description : This function will return how many times this promo is used by a specific ESN
 ***************************************************************************************************************/
FUNCTION FN_GET_PROMO_USAGE_COUNT(
 IP_ESN IN VARCHAR2 ,
 IP_PROMO_OBJID IN NUMBER )
RETURN NUMBER
IS
	CURSOR CUR_ESN_DETAIL
	IS
	SELECT BO.ORG_ID BRAND_NAME ,
	PI.*
	FROM TABLE_PART_INST PI ,
	TABLE_MOD_LEVEL ML ,
	TABLE_PART_NUM PN ,
	TABLE_BUS_ORG BO
	WHERE 1 = 1
	AND PART_SERIAL_NO = IP_ESN
	AND ML.OBJID = PI.N_PART_INST2PART_MOD
	AND PN.OBJID = ML.PART_INFO2PART_NUM
	AND BO.OBJID = PN.PART_NUM2BUS_ORG;
	REC_ESN_DETAIL CUR_ESN_DETAIL%ROWTYPE;

	CURSOR CUR_PROMO_DISC_HIST
	IS
	SELECT MIN(PE.X_ENROLLED_DATE) ENROLLMENT_START_DATE ,
	COUNT(DISC_HIST.PGM_DISCOUNT2X_PROMO) APPLIED_PROMO_COUNT
	FROM X_PROGRAM_ENROLLED PE
	,X_PROGRAM_DISCOUNT_HIST DISC_HIST
	WHERE 1 		= 1
	AND PE.X_ESN				= IP_ESN
	AND DISC_HIST.pgm_discount2pgm_enrolled 		= PE.OBJID
	AND EXISTS (	SELECT 1
			FROM X_PROGRAM_PURCH_DTL DTL
			,X_PROGRAM_PURCH_HDR HDR
			WHERE 1 = 1
			AND HDR.OBJID 	= DTL.PGM_PURCH_DTL2PROG_HDR
			AND DISC_HIST.PGM_DISCOUNT2PROG_HDR 	= HDR.OBJID
			)
	AND DISC_HIST.PGM_DISCOUNT2X_PROMO 	= IP_PROMO_OBJID
	;

	REC_PROMO_DISC_HIST CUR_PROMO_DISC_HIST%ROWTYPE;

	v_action VARCHAR2(4000);
	L_PROMO_DISCOUNT_CNT NUMBER := 0;
BEGIN
 OPEN CUR_ESN_DETAIL;
 FETCH CUR_ESN_DETAIL INTO REC_ESN_DETAIL;
 IF CUR_ESN_DETAIL%NOTFOUND THEN

 CLOSE CUR_ESN_DETAIL;
 RETURN 0;
 END IF;
 CLOSE CUR_ESN_DETAIL;

 OPEN CUR_PROMO_DISC_HIST;
 FETCH CUR_PROMO_DISC_HIST INTO REC_PROMO_DISC_HIST;
 IF CUR_PROMO_DISC_HIST%NOTFOUND THEN
 --DBMS_OUTPUT.PUT_LINE('CUR_PROMO_DISC_HIST%NOTFOUND');
	 NULL;
 END IF;
 CLOSE CUR_PROMO_DISC_HIST;
 --DBMS_OUTPUT.PUT_LINE('IF NOT FOUND DISC HISTORY ');
 L_PROMO_DISCOUNT_CNT := NVL(REC_PROMO_DISC_HIST.APPLIED_PROMO_COUNT,0);
 --DBMS_OUTPUT.PUT_LINE('L_PROMO_DISCOUNT_CNT'||L_PROMO_DISCOUNT_CNT);


 RETURN L_PROMO_DISCOUNT_CNT;
EXCEPTION
WHEN OTHERS THEN

	v_action	:= 'Main Excpetion FN_GET_PROMO_USAGE_COUNT for ESN '||IP_ESN||' Promo objid '||IP_PROMO_OBJID;

	toss_util_pkg.insert_error_tab_proc(v_action
					 ,IP_ESN
					 ,'PKG_FLIP_ENROLLED_ESN_PROMO.FN_GET_PROMO_USAGE_COUNT');

	RETURN 0;
END FN_GET_PROMO_USAGE_COUNT;

FUNCTION GET_ENR_HOLIDAY_PROMO_COUNT
(ip_esn           	IN VARCHAR2,
ip_promo_objid 		IN NUMBER
)
RETURN NUMBER
IS
RETURN_FLAG NUMBER := 1;
LV_PROMO_APPLIED_COUNT		NUMBER	:=	0;
LV_HOLIDAY_PROMO_COUNT		NUMBER	:=	0;
lv_err_string			VARCHAR2(4000);
LV_HOLIDAY_PROMO_BALANCE	NUMBER	:=	0;
BEGIN
	BEGIN

		SELECT COUNT(DISC_HIST.PGM_DISCOUNT2X_PROMO) APPLIED_PROMO_COUNT
		INTO	LV_PROMO_APPLIED_COUNT
		FROM 	X_PROGRAM_ENROLLED PE
			,X_PROGRAM_DISCOUNT_HIST DISC_HIST
		WHERE 1 		= 1
		AND PE.X_ESN				= ip_esn
		AND DISC_HIST.pgm_discount2pgm_enrolled 		= PE.OBJID
		AND EXISTS (	SELECT 1
				FROM X_PROGRAM_PURCH_DTL DTL
				,X_PROGRAM_PURCH_HDR HDR
				WHERE 1 = 1
				AND HDR.OBJID 	= DTL.PGM_PURCH_DTL2PROG_HDR
				AND DISC_HIST.PGM_DISCOUNT2PROG_HDR 	= HDR.OBJID
				AND HDR.X_ICS_RCODE	IN ('1','100')	-- PAYMENT SUCCESS
				)
		AND DISC_HIST.PGM_DISCOUNT2X_PROMO 	= ip_promo_objid
		;
	EXCEPTION WHEN OTHERS
	THEN
		LV_PROMO_APPLIED_COUNT	:=	0;
	END;



	BEGIN
		SELECT NVL(MAX(X_HOLIDAY_PROMO_COUNT),0)
		INTO LV_HOLIDAY_PROMO_COUNT
		FROM sa.TABLE_X_HOLIDAY_PROMOTION
		WHERE x_holiday_promo_objid	=	ip_promo_objid
		;

	EXCEPTION WHEN OTHERS
	THEN
	/*
	op_err_string := 'X_HOLIDAY_PROMO_COUNT IS ZERO OR NO RECORD IN TABLE_X_HOLIDAY_PROMOTION FOR PROMO OBJID '||ip_promo_objid ||' ESN '||ip_esn;

	ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION', p_error_date => SYSDATE, p_key => ip_esn, p_program_name =>
	'PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION', p_error_text => op_err_string);

	*/

		RETURN 0;

	END;


	IF LV_PROMO_APPLIED_COUNT	>= LV_HOLIDAY_PROMO_COUNT
	THEN

		BEGIN



			SELECT NVL(x_holiday_promo_balance,0)
			INTO LV_HOLIDAY_PROMO_BALANCE
			FROM x_enroll_promo_grp2esn
			WHERE program_enrolled_objid IN (	SELECT objid
								FROM x_program_enrolled
								WHERE x_esn = IP_ESN
							)
			AND 	PROMO_OBJID	=	ip_promo_objid
			;


		EXCEPTION WHEN OTHERS
		THEN
			LV_HOLIDAY_PROMO_BALANCE	:=	0;
		END;

		IF NVL(LV_HOLIDAY_PROMO_BALANCE,0) > 0
		THEN
			RETURN NVL(LV_HOLIDAY_PROMO_BALANCE,0);
		ELSE
			RETURN 0;
		END IF;

	ELSE
		RETURN (NVL(LV_HOLIDAY_PROMO_COUNT,0)	-	NVL(LV_PROMO_APPLIED_COUNT,0));

	END IF;
EXCEPTION WHEN OTHERS
THEN

	lv_err_string := 'Main Exception PROMO OBJID '||ip_promo_objid ||' ESN '||ip_esn||' '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

	ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.GET_ENR_HOLIDAY_PROMO_COUNT', p_error_date => SYSDATE, p_key => ip_esn, p_program_name =>
	'PKG_FLIP_ENROLLED_ESN_PROMO.GET_ENR_HOLIDAY_PROMO_COUNT', p_error_text => lv_err_string);

	RETURN 0;

END;


FUNCTION VALIDATE_HOLIDAY_PROMOTION
(ip_esn           	IN VARCHAR2,
ip_promo_objid 		IN NUMBER
)
RETURN NUMBER
IS
RETURN_FLAG NUMBER := 1;
LV_PROMO_APPLIED_COUNT		NUMBER	:=	0;
LV_HOLIDAY_PROMO_COUNT		NUMBER	:=	0;
LV_HOLIDAY_PROMO_BALANCE	NUMBER	:=	0;
lv_err_string			VARCHAR2(4000);
BEGIN
	BEGIN

		SELECT COUNT(DISC_HIST.PGM_DISCOUNT2X_PROMO) APPLIED_PROMO_COUNT
		INTO	LV_PROMO_APPLIED_COUNT
		FROM 	X_PROGRAM_ENROLLED PE
			,X_PROGRAM_DISCOUNT_HIST DISC_HIST
		WHERE 1 		= 1
		AND PE.X_ESN				= ip_esn
		AND DISC_HIST.pgm_discount2pgm_enrolled 		= PE.OBJID
		AND EXISTS (	SELECT 1
				FROM X_PROGRAM_PURCH_DTL DTL
				,X_PROGRAM_PURCH_HDR HDR
				WHERE 1 = 1
				AND HDR.OBJID 	= DTL.PGM_PURCH_DTL2PROG_HDR
				AND DISC_HIST.PGM_DISCOUNT2PROG_HDR 	= HDR.OBJID
				AND HDR.X_ICS_RCODE	IN ('1','100')	-- PAYMENT SUCCESS
				)
		AND DISC_HIST.PGM_DISCOUNT2X_PROMO 	= ip_promo_objid
		;
	EXCEPTION WHEN OTHERS
	THEN
		LV_PROMO_APPLIED_COUNT	:=	0;
	END;



	BEGIN
		SELECT NVL(MAX(X_HOLIDAY_PROMO_COUNT),0)
		INTO LV_HOLIDAY_PROMO_COUNT
		FROM sa.TABLE_X_HOLIDAY_PROMOTION
		WHERE x_holiday_promo_objid	=	ip_promo_objid
		;

	EXCEPTION WHEN OTHERS
	THEN
	/*
	op_err_string := 'X_HOLIDAY_PROMO_COUNT IS ZERO OR NO RECORD IN TABLE_X_HOLIDAY_PROMOTION FOR PROMO OBJID '||ip_promo_objid ||' ESN '||ip_esn;

	ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION', p_error_date => SYSDATE, p_key => ip_esn, p_program_name =>
	'PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION', p_error_text => op_err_string);

	*/

		RETURN 0;

	END;


	IF LV_PROMO_APPLIED_COUNT	>= LV_HOLIDAY_PROMO_COUNT
	THEN

		BEGIN



			SELECT NVL(x_holiday_promo_balance,0)
			INTO LV_HOLIDAY_PROMO_BALANCE
			FROM x_enroll_promo_grp2esn
			WHERE program_enrolled_objid IN (	SELECT objid
								FROM x_program_enrolled
								WHERE x_esn = IP_ESN
							)
			AND 	PROMO_OBJID	=	ip_promo_objid
			;


		EXCEPTION WHEN OTHERS
		THEN
			LV_HOLIDAY_PROMO_BALANCE	:=	0;
		END;

		IF NVL(LV_HOLIDAY_PROMO_BALANCE,0) > 0
		THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;

	ELSE
		RETURN 1;

	END IF;
EXCEPTION WHEN OTHERS
THEN

	lv_err_string := 'Main Exception PROMO OBJID '||ip_promo_objid ||' ESN '||ip_esn||' '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

	ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION', p_error_date => SYSDATE, p_key => ip_esn, p_program_name =>
	'PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION', p_error_text => lv_err_string);

	RETURN 0;

END;


PROCEDURE UPDATE_HOLIDAY_PROMO_BALANCE
(ip_esn			VARCHAR2
,ip_promo_objid		NUMBER
,op_error_code		OUT VARCHAR2
,op_error_msg		OUT VARCHAR2
)
IS
lv_err_string			VARCHAR2(4000);
is_holiday_promo		NUMBER;
BEGIN
	op_error_code	:=	'0';
	op_error_msg	:=	'SUCCESS';


	SELECT COUNT(1)
	INTO	is_holiday_promo
	FROM 	sa.TABLE_X_HOLIDAY_PROMOTION
	WHERE 	x_holiday_promo_objid	=	ip_promo_objid
	;

	IF  is_holiday_promo	<>	0
	THEN

		UPDATE x_enroll_promo_grp2esn
		SET x_holiday_promo_balance    = nvl(x_holiday_promo_balance,1) - 1
		WHERE program_enrolled_objid IN (	SELECT objid
							FROM x_program_enrolled
							WHERE x_esn = IP_ESN
							)
		AND 	PROMO_OBJID	=	ip_promo_objid
		AND NVL(x_holiday_promo_balance,0) > 0
		;

	END IF;



EXCEPTION WHEN OTHERS
THEN

lv_err_string := 'Main Exception PROMO OBJID '||ip_promo_objid ||' ESN '||ip_esn||' '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
	op_error_code	:=	'99';
	op_error_msg	:=	lv_err_string;
	ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.UPDATE_HOLIDAY_PROMO_BALANCE', p_error_date => SYSDATE, p_key => ip_esn, p_program_name =>
	'PKG_FLIP_ENROLLED_ESN_PROMO.UPDATE_HOLIDAY_PROMO_BALANCE', p_error_text => lv_err_string);
END;


PROCEDURE UPD_HOLIDAY_PROMO_BALANCE_WRAP	--- Created for CBO with commit.
(ip_esn			VARCHAR2
,ip_promo_objid		NUMBER
,op_error_code		OUT VARCHAR2
,op_error_msg		OUT VARCHAR2
)
IS

BEGIN

	sa.PKG_FLIP_ENROLLED_ESN_PROMO.UPDATE_HOLIDAY_PROMO_BALANCE
	(ip_esn
	,ip_promo_objid
	,op_error_code
	,op_error_msg
	);

COMMIT;
EXCEPTION WHEN OTHERS
THEN

NULL;

END;


/***************************************************************************************************************
Program Name : SP_INSERT_X_PROGRAM_TRANS
Program Type : Procedure
Program Arguments : None
Returns : None
Program Called : None
Description : This procedure will insert record into X_PROGRAM_TRANS
***************************************************************************************************************/
	PROCEDURE SP_INSERT_X_PROGRAM_TRANS
		(
		IP_X_ENROLLMENT_STATUS			IN sa.X_PROGRAM_TRANS.X_ENROLLMENT_STATUS%TYPE
		, IP_X_ENROLL_STATUS_REASON		IN sa.X_PROGRAM_TRANS.X_ENROLL_STATUS_REASON%TYPE
		, IP_X_FLOAT_GIVEN				IN sa.X_PROGRAM_TRANS.X_FLOAT_GIVEN%TYPE
		, IP_X_COOLING_GIVEN			IN sa.X_PROGRAM_TRANS.X_COOLING_GIVEN%TYPE
		, IP_X_GRACE_PERIOD_GIVEN		IN sa.X_PROGRAM_TRANS.X_GRACE_PERIOD_GIVEN%TYPE
		, IP_X_TRANS_DATE				IN sa.X_PROGRAM_TRANS.X_TRANS_DATE%TYPE
		, IP_X_ACTION_TEXT				IN sa.X_PROGRAM_TRANS.X_ACTION_TEXT%TYPE
		, IP_X_ACTION_TYPE				IN sa.X_PROGRAM_TRANS.X_ACTION_TYPE%TYPE
		, IP_X_REASON					IN sa.X_PROGRAM_TRANS.X_REASON%TYPE
		, IP_X_SOURCESYSTEM				IN sa.X_PROGRAM_TRANS.X_SOURCESYSTEM%TYPE
		, IP_X_ESN						IN sa.X_PROGRAM_TRANS.X_ESN%TYPE
		, IP_X_EXP_DATE					IN sa.X_PROGRAM_TRANS.X_EXP_DATE%TYPE
		, IP_X_COOLING_EXP_DATE			IN sa.X_PROGRAM_TRANS.X_COOLING_EXP_DATE%TYPE
		, IP_X_UPDATE_STATUS			IN sa.X_PROGRAM_TRANS.X_UPDATE_STATUS%TYPE
		, IP_X_UPDATE_USER				IN sa.X_PROGRAM_TRANS.X_UPDATE_USER%TYPE
		, IP_PGM_TRAN2PGM_ENTROLLED		IN sa.X_PROGRAM_TRANS.PGM_TRAN2PGM_ENTROLLED%TYPE
		, IP_PGM_TRANS2WEB_USER			IN sa.X_PROGRAM_TRANS.PGM_TRANS2WEB_USER%TYPE
		, IP_PGM_TRANS2SITE_PART		IN sa.X_PROGRAM_TRANS.PGM_TRANS2SITE_PART%TYPE
		, OP_OBJID						OUT sa.X_PROGRAM_TRANS.OBJID%TYPE
		)
		AS
		LV_OBJID sa.X_PROGRAM_TRANS.OBJID%TYPE;
		v_action VARCHAR2(4000);
	BEGIN
		SELECT sa.SEQ_X_PROGRAM_TRANS.NEXTVAL INTO LV_OBJID FROM DUAL;
		INSERT INTO sa.X_PROGRAM_TRANS
			(
			OBJID
			, X_ENROLLMENT_STATUS
			, X_ENROLL_STATUS_REASON
			, X_FLOAT_GIVEN
			, X_COOLING_GIVEN
			, X_GRACE_PERIOD_GIVEN
			, X_TRANS_DATE
			, X_ACTION_TEXT
			, X_ACTION_TYPE
			, X_REASON
			, X_SOURCESYSTEM
			, X_ESN
			, X_EXP_DATE
			, X_COOLING_EXP_DATE
			, X_UPDATE_STATUS
			, X_UPDATE_USER
			, PGM_TRAN2PGM_ENTROLLED
			, PGM_TRANS2WEB_USER
			, PGM_TRANS2SITE_PART
			)
		VALUES(
			LV_OBJID
			, IP_X_ENROLLMENT_STATUS
			, IP_X_ENROLL_STATUS_REASON
			, IP_X_FLOAT_GIVEN
			, IP_X_COOLING_GIVEN
			, IP_X_GRACE_PERIOD_GIVEN
			, IP_X_TRANS_DATE
			, IP_X_ACTION_TEXT
			, IP_X_ACTION_TYPE
			, IP_X_REASON
			, IP_X_SOURCESYSTEM
			, IP_X_ESN
			, IP_X_EXP_DATE
			, IP_X_COOLING_EXP_DATE
			, IP_X_UPDATE_STATUS
			, IP_X_UPDATE_USER
			, IP_PGM_TRAN2PGM_ENTROLLED
			, IP_PGM_TRANS2WEB_USER
			, IP_PGM_TRANS2SITE_PART);
	EXCEPTION
	WHEN OTHERS THEN

	v_action	:= 'Exception while inserting into X_PROGRAM_TRANS '||IP_X_ESN||' - '||IP_X_ENROLL_STATUS_REASON||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||DBMS_UTILITY.FORMAT_ERROR_STACK;


	ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.SP_INSERT_X_PROGRAM_TRANS', p_error_date => SYSDATE, p_key => IP_X_ESN, p_program_name =>
	'PKG_FLIP_ENROLLED_ESN_PROMO.SP_INSERT_X_PROGRAM_TRANS', p_error_text => v_action);


	dbms_output.put_line(v_action);
	--RAISE;
	END SP_INSERT_X_PROGRAM_TRANS;
/***************************************************************************************************************
Program Name       :   SP_FLIP_NT_AR_2015_PROMO
Program Type       :   Procedure
Program Arguments  :   None
Returns            :   None
Program Called     :   None
Description        :   This procedure will flip back Net10 promotions
                        As per business requirement, an ESN will be given 3 months of special discount
                        and after this period, we should give a customer existing discount.
                        In this particular case, as part of holiday promo, we are giving $7.50 and after
                        3 months it should flip back to $5.
***************************************************************************************************************/
  PROCEDURE SP_FLIP_NT_AR_2015_PROMO(IN_COUNT NUMBER DEFAULT 30000)
  AS


    LV_ERROR_CODE     		VARCHAR2(1000);
    LV_ERROR_MSG      		VARCHAR2(1000);
	LV_PROG_TRANS_OBJID    	sa.X_PROGRAM_TRANS.OBJID%TYPE;
	v_action         VARCHAR2(4000);
  BEGIN


    FOR X              IN
      (
        SELECT *
	FROM
	(
	SELECT  PE.OBJID AS PE_OBJID
                ,PE.*
                ,PP.X_PROGRAM_NAME
		,HP.x_holiday_promo_count
		,HP.x_regular_promo_objid
        FROM    sa.X_PROGRAM_ENROLLED PE ,
                sa.X_PROGRAM_PARAMETERS PP,
		sa.TABLE_X_HOLIDAY_PROMOTION HP
        WHERE   1                         	=	1
        AND     PE.PGM_ENROLL2PGM_PARAMETER 	= 	PP.OBJID
        AND     PP.X_PROGRAM_NAME          	= 	HP.x_program_name
        AND     PE.X_ENROLLMENT_STATUS     	IN 	('ENROLLED', 'ENROLLMENTSCHEDULED')
        AND     PE.PGM_ENROLL2X_PROMOTION   	= 	HP.x_holiday_promo_objid
	AND 	HP.X_ORG_ID			=	'NET10'
	ORDER BY NVL((SELECT DISTINCT 1
                  FROM x_program_purch_hdr a, x_program_purch_dtl b
                  WHERE a.objid = b.pgm_purch_dtl2prog_hdr
                    AND b.pgm_purch_dtl2pgm_enrolled = PE.objid
                    AND x_rqst_date > SYSDATE - 3
                    ),2)
	)
	WHERE	1	=	1
	AND	ROWNUM      <= 	NVL(IN_COUNT,30000)
	--AND 	NVL(FN_GET_PROMO_USAGE_COUNT(PE.X_ESN,P.X_PROMO_CODE),0) >= 3
      )
    LOOP

    BEGIN


      LV_ERROR_CODE := NULL;
      LV_ERROR_MSG := NULL;


	IF NVL(PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION(X.X_ESN,X.PGM_ENROLL2X_PROMOTION),0) <> 1
	THEN

	dbms_output.put_line('New promo objid '||x.x_regular_promo_objid);

	v_action     := 'Calling to SA.ENROLL_PROMO_PKG.SP_REGISTER_ESN_PROMO ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' Enr Prog objid '||X.PE_OBJID||' ERROR '||LV_ERROR_CODE||' - '||LV_ERROR_MSG;

        sa.ENROLL_PROMO_PKG.SP_REGISTER_ESN_PROMO(
          P_ESN => X.X_ESN,
          P_PROMO_OBJID => x.x_regular_promo_objid,
          P_PROGRAM_ENROLLED_OBJID => X.PE_OBJID,
          P_ERROR_CODE => LV_ERROR_CODE,
          P_ERROR_MSG => LV_ERROR_MSG
          );

	IF LV_ERROR_CODE <> 0
	THEN

		v_action     := 'While calling to SA.ENROLL_PROMO_PKG.SP_REGISTER_ESN_PROMO ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' Enr Prog objid '||X.PE_OBJID||' ERROR '||LV_ERROR_CODE||' - '||LV_ERROR_MSG;


		ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_NT_AR_2015_PROMO', p_error_date => SYSDATE, p_key => X.X_ESN, p_program_name =>
		'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_NT_AR_2015_PROMO', p_error_text => v_action);

		CONTINUE;	-- SKIP ITERATION
	END IF;

	IF LV_ERROR_CODE = 0  THEN

		v_action     := 'UPDATE X_ENROLL_PROMO_GRP2ESN ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' PE OBJID '||X.PE_OBJID;

		UPDATE X_ENROLL_PROMO_GRP2ESN
		SET X_END_DATE = TRUNC(SYSDATE)
		WHERE X_ESN                  	=	X.X_ESN
		AND PROGRAM_ENROLLED_OBJID   	=	X.PE_OBJID
		AND PROMO_OBJID              	<>	x.x_regular_promo_objid
		AND NVL(X_END_DATE,SYSDATE  + 10) > SYSDATE
		;

		v_action     := 'Calling to SP_INSERT_X_PROGRAM_TRANS ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' PE OBJID '||X.PE_OBJID;

		SP_INSERT_X_PROGRAM_TRANS(
			X.X_ENROLLMENT_STATUS			--IP_X_ENROLLMENT_STATUS
			, 'Flipping data in PGM_ENROLL2X_PROMOTION from '||X.PGM_ENROLL2X_PROMOTION||' to '||x.x_regular_promo_objid	--IP_X_ENROLL_STATUS_REASON
			, NULL							--IP_X_FLOAT_GIVEN
			, NULL							--IP_X_COOLING_GIVEN
			, NULL							--IP_X_GRACE_PERIOD_GIVEN
			, SYSDATE						--IP_X_TRANS_DATE
			, 'Changing promotion id'		--IP_X_ACTION_TEXT
			, 'PROMO_UPDATE'				--IP_X_ACTION_TYPE
			, 'Ending promo after 3 billing cycle. Flipping to original promo.'	--IP_X_REASON
			, 'SYSTEM'						--IP_X_SOURCESYSTEM
			, x.x_esn						--IP_X_ESN
			, NULL							--IP_X_EXP_DATE
			, NULL							--IP_X_COOLING_EXP_DATE
			, NULL							--IP_X_UPDATE_STATUS
			, 'SA.PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_NT_AR_2015_PROMO'			--IP_X_UPDATE_USER
			, X.PE_OBJID							--IP_PGM_TRAN2PGM_ENTROLLED
			, NULL									--IP_PGM_TRANS2WEB_USER
			, X.PGM_ENROLL2SITE_PART				--IP_PGM_TRANS2SITE_PART
			, LV_PROG_TRANS_OBJID
			);




	END IF;


      COMMIT;

        END IF;
      EXCEPTION WHEN OTHERS
      THEN
	ROLLBACK;
	v_action	:= 'Exception '||v_action;

	ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_NT_AR_2015_PROMO', p_error_date => SYSDATE, p_key => X.X_ESN, p_program_name =>
		'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_NT_AR_2015_PROMO', p_error_text => v_action);

	CONTINUE;	-- SKIP ITERATION
      END;

    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK;
    v_action     := 'Main exception Procedure SP_FLIP_NT_AR_2015_PROMO Error '||LV_ERROR_CODE||' - '||LV_ERROR_MSG||' After '||v_action;

	      ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_NT_AR_2015_PROMO', p_error_date => SYSDATE, p_key => 'MAIN', p_program_name =>
		'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_NT_AR_2015_PROMO', p_error_text => v_action);

    --RAISE;
  END SP_FLIP_NT_AR_2015_PROMO;
/***************************************************************************************************************
Program Name       :   SP_FLIP_ST_AR_2015_PROMO
Program Type       :   Procedure
Program Arguments  :   None
Returns            :   None
Program Called     :   None
Description        :   This procedure will flip back Straight talk promotions
                        As per business requirement, an ESN will be given 3 months of special discount
                        and after this period, we should give a customer existing discount.
                        In this particular case, as part of holiday promo, we are giving $5 and after
                        3 months it should flip back to $2.5.
***************************************************************************************************************/
  PROCEDURE SP_FLIP_ST_AR_2015_PROMO(IN_COUNT NUMBER DEFAULT 30000)
  AS

    LV_ERROR_CODE     VARCHAR2(1000);
    LV_ERROR_MSG      VARCHAR2(1000);
	LV_PROG_TRANS_OBJID    	sa.X_PROGRAM_TRANS.OBJID%TYPE;
	v_action         VARCHAR2(4000);
  BEGIN

    FOR X              IN
      (SELECT * FROM
        (
	SELECT  PE.OBJID AS PE_OBJID
                ,PE.*
                ,PP.X_PROGRAM_NAME
		,HP.x_holiday_promo_count
		,HP.x_regular_promo_objid
        FROM    sa.X_PROGRAM_ENROLLED PE ,
                sa.X_PROGRAM_PARAMETERS PP,
		sa.TABLE_X_HOLIDAY_PROMOTION HP
        WHERE   1                         	=	1
        AND     PE.PGM_ENROLL2PGM_PARAMETER 	= 	PP.OBJID
        AND     PP.X_PROGRAM_NAME          	= 	HP.x_program_name
        AND     PE.X_ENROLLMENT_STATUS     	IN 	('ENROLLED', 'ENROLLMENTSCHEDULED')
        AND     PE.PGM_ENROLL2X_PROMOTION   	= 	HP.x_holiday_promo_objid
	AND 	HP.X_ORG_ID			=	'STRAIGHT_TALK'
	ORDER BY NVL((SELECT DISTINCT 1
                  FROM x_program_purch_hdr a, x_program_purch_dtl b
                  WHERE a.objid = b.pgm_purch_dtl2prog_hdr
                    AND b.pgm_purch_dtl2pgm_enrolled = PE.objid
                    AND x_rqst_date > SYSDATE - 3
                    ),2)
	)
	WHERE	1	=	1
	AND ROWNUM      <= 	NVL(IN_COUNT,30000)
	--AND 	NVL(FN_GET_PROMO_USAGE_COUNT(PE.X_ESN,P.X_PROMO_CODE),0) >= 3
      )
    LOOP

    BEGIN


      LV_ERROR_CODE := NULL;
      LV_ERROR_MSG := NULL;

     	IF NVL(PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION(X.X_ESN,X.PGM_ENROLL2X_PROMOTION),0) <> 1
	THEN






        --DBMS_OUTPUT.PUT_LINE('New promo code:'||x.x_regular_promo_objid);

	v_action     := 'Calling to SA.ENROLL_PROMO_PKG.SP_REGISTER_ESN_PROMO ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' Enr Prog objid '||X.PE_OBJID||' ERROR '||LV_ERROR_CODE||' - '||LV_ERROR_MSG;

        sa.ENROLL_PROMO_PKG.SP_REGISTER_ESN_PROMO(
          P_ESN => X.X_ESN,
          P_PROMO_OBJID => x.x_regular_promo_objid,
          P_PROGRAM_ENROLLED_OBJID => X.PE_OBJID,
          P_ERROR_CODE => LV_ERROR_CODE,
          P_ERROR_MSG => LV_ERROR_MSG
          );

	IF LV_ERROR_CODE <> 0
	THEN

		v_action     := 'While calling to SA.ENROLL_PROMO_PKG.SP_REGISTER_ESN_PROMO ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' Enr Prog objid '||X.PE_OBJID||' ERROR '||LV_ERROR_CODE||' - '||LV_ERROR_MSG;

		ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_ST_AR_2015_PROMO', p_error_date => SYSDATE, p_key => X.X_ESN, p_program_name =>
		'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_ST_AR_2015_PROMO', p_error_text => v_action);

		CONTINUE;	-- SKIP ITERATION
	END IF;


	IF LV_ERROR_CODE = 0  THEN

		v_action     := 'UPDATE X_ENROLL_PROMO_GRP2ESN ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' PE OBJID '||X.PE_OBJID;

		UPDATE X_ENROLL_PROMO_GRP2ESN
		SET X_END_DATE = TRUNC(SYSDATE)
		WHERE X_ESN                  	=	X.X_ESN
		AND PROGRAM_ENROLLED_OBJID   	=	X.PE_OBJID
		AND PROMO_OBJID              	<>	x.x_regular_promo_objid
		AND NVL(X_END_DATE,SYSDATE  + 10) > SYSDATE
		;

		v_action     := 'Calling to SP_INSERT_X_PROGRAM_TRANS ESN '||X.X_ESN||' PROMO OBJID '||x.x_regular_promo_objid||' PE OBJID '||X.PE_OBJID;

		SP_INSERT_X_PROGRAM_TRANS(
			X.X_ENROLLMENT_STATUS			--IP_X_ENROLLMENT_STATUS
			, 'Flipping data in PGM_ENROLL2X_PROMOTION from '||X.PGM_ENROLL2X_PROMOTION||' to '||x.x_regular_promo_objid	--IP_X_ENROLL_STATUS_REASON
			, NULL							--IP_X_FLOAT_GIVEN
			, NULL							--IP_X_COOLING_GIVEN
			, NULL							--IP_X_GRACE_PERIOD_GIVEN
			, SYSDATE						--IP_X_TRANS_DATE
			, 'Changing promotion id'		--IP_X_ACTION_TEXT
			, 'PROMO_UPDATE'				--IP_X_ACTION_TYPE
			, 'Ending promo after 3 billing cycle. Flipping to original promo.'	--IP_X_REASON
			, 'SYSTEM'						--IP_X_SOURCESYSTEM
			, X.X_ESN						--IP_X_ESN
			, NULL							--IP_X_EXP_DATE
			, NULL							--IP_X_COOLING_EXP_DATE
			, NULL							--IP_X_UPDATE_STATUS
			, 'SA.PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_ST_AR_2015_PROMO'			--IP_X_UPDATE_USER
			, X.PE_OBJID							--IP_PGM_TRAN2PGM_ENTROLLED
			, NULL									--IP_PGM_TRANS2WEB_USER
			, X.PGM_ENROLL2SITE_PART				--IP_PGM_TRANS2SITE_PART
			, LV_PROG_TRANS_OBJID
			);


	END IF;


	COMMIT;

	END IF;

	EXCEPTION WHEN OTHERS
	THEN
		ROLLBACK;
		v_action	:= 'Exception '||v_action;

		ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_ST_AR_2015_PROMO', p_error_date => SYSDATE, p_key => X.X_ESN, p_program_name =>
		'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_ST_AR_2015_PROMO', p_error_text => v_action);

		CONTINUE;	-- SKIP ITERATION
	END;
    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK;
	v_action     := 'Main exception Procedure SP_FLIP_ST_AR_2015_PROMO Error '||LV_ERROR_CODE||' - '||LV_ERROR_MSG||' After '||v_action;

	      ota_util_pkg.err_log(p_action => 'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_ST_AR_2015_PROMO', p_error_date => SYSDATE, p_key => 'MAIN', p_program_name =>
		'PKG_FLIP_ENROLLED_ESN_PROMO.SP_FLIP_ST_AR_2015_PROMO', p_error_text => v_action);
    --RAISE;
  END SP_FLIP_ST_AR_2015_PROMO;


--CR#45706 - Turn Off Auto Refill Discount For HPP
/***************************************************************************************************************
Program Name       :   SP_CLEAN_HPP_PROMO
Program Type       :   Procedure
Program Arguments  :   None
Returns            :   None
Program Called     :   None
Description        :   This procedure will clean promotion attached to HPP program.

***************************************************************************************************************/

PROCEDURE sp_clean_hpp_promo(i_days IN NUMBER DEFAULT 2)
IS

 CURSOR  c_hpp_enrollments
 IS
  SELECT  *
  FROM    x_program_enrolled
  WHERE   pgm_enroll2x_promotion IS NOT NULL
  AND     pgm_enroll2x_promotion <> 0
  AND     x_enrolled_date        > SYSDATE - NVL(i_days, 2)
  AND     x_enrollment_status    = 'ENROLLED'
  AND     EXISTS  (
                    SELECT  objid
                    FROM    x_program_parameters a
                    WHERE   X_PROG_CLASS              = 'WARRANTY'
                    AND     PGM_ENROLL2PGM_PARAMETER  = a.objid
                   );
 BEGIN --{

 FOR i IN c_hpp_enrollments
 LOOP--{
  DBMS_OUTPUT.PUT_LINE('ESN: '||i.x_esn||' OBJID: '||i.objid||' Program Objid: '||i.pgm_enroll2pgm_parameter||' Promo Objid: '||i.pgm_enroll2x_promotion);
  UPDATE x_program_enrolled
  SET    pgm_enroll2x_promotion = NULL
  WHERE  x_esn                  = i.x_esn
  AND    objid                  = i.objid
  AND    pgm_enroll2x_promotion = i.pgm_enroll2x_promotion;

  UPDATE x_enroll_promo_grp2esn
  SET    x_end_date             = SYSDATE - 1
  WHERE  x_esn                  = i.x_esn
  AND    program_enrolled_objid = i.objid
  AND    promo_objid      = i.pgm_enroll2x_promotion;

 END LOOP; --}

 COMMIT;

EXCEPTION
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('In main exception p_clean_hpp_promo '||sqlerrm);

 ROLLBACK;

END sp_clean_hpp_promo; --}

END PKG_FLIP_ENROLLED_ESN_PROMO;
/
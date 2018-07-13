CREATE OR REPLACE PACKAGE sa.PKG_FLIP_ENROLLED_ESN_PROMO AS
	FUNCTION FN_GET_PROMO_USAGE_COUNT(
	IP_ESN IN VARCHAR2 ,
	IP_PROMO_OBJID IN NUMBER )
	RETURN NUMBER;

FUNCTION GET_ENR_HOLIDAY_PROMO_COUNT
(ip_esn           	IN VARCHAR2,
ip_promo_objid 		IN NUMBER
)
RETURN NUMBER;

FUNCTION VALIDATE_HOLIDAY_PROMOTION
(ip_esn           	IN VARCHAR2,
ip_promo_objid 		IN NUMBER
)
RETURN NUMBER;

-- CR44499
PROCEDURE UPDATE_HOLIDAY_PROMO_BALANCE
(ip_esn			VARCHAR2
,ip_promo_objid		NUMBER
,op_error_code		OUT VARCHAR2
,op_error_msg		OUT VARCHAR2
);

PROCEDURE UPD_HOLIDAY_PROMO_BALANCE_WRAP
(ip_esn			VARCHAR2
,ip_promo_objid		NUMBER
,op_error_code		OUT VARCHAR2
,op_error_msg		OUT VARCHAR2
);
-- CR44499

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
		);

 PROCEDURE SP_FLIP_NT_AR_2015_PROMO(IN_COUNT NUMBER DEFAULT 30000);

 PROCEDURE SP_FLIP_ST_AR_2015_PROMO(IN_COUNT NUMBER DEFAULT 30000);

 PROCEDURE sp_clean_hpp_promo(i_days IN NUMBER DEFAULT 2); --CR#45706 - Turn Off Auto Refill Discount For HPP


END PKG_FLIP_ENROLLED_ESN_PROMO;
/
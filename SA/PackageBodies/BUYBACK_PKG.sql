CREATE OR REPLACE PACKAGE BODY sa.BUYBACK_PKG AS
/***************************************************************************************************************
 Program Name			 :  	FN_GET_ACTIVE_DAYS_BY_ESN
 Program Type      :  	Function
 Program Arguments :  	IP_ESN
 Returns           :   	Varchar2
 Program Called    :  	None
 Description       :  	This function will return number of days for which an ESN is active.
 Modified By	           Modification    PCR             Description
                            Date         Number
 =============          ============     ======      ============================
  Jai Arza		   		      1/26/2016			 40287		      Initial Creation
***************************************************************************************************************/
  FUNCTION FN_GET_ACTIVE_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2
  AS
    LV_ACTIVE_DAYS    VARCHAR2(10) := 0;
  BEGIN
    SELECT  NVL(ROUND(SUM((CASE WHEN SP.X_EXPIRE_DT > SYSDATE THEN SYSDATE
                      ELSE SP.X_EXPIRE_DT
                      END)-INSTALL_DATE),0),0)
    INTO    LV_ACTIVE_DAYS
    FROM    sa.TABLE_SITE_PART SP
    WHERE   SP.X_SERVICE_ID = IP_ESN
    AND     SP.PART_STATUS IN ('Inactive','Active','CarrierPending');
    RETURN  LV_ACTIVE_DAYS;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END FN_GET_ACTIVE_DAYS_BY_ESN;
/***************************************************************************************************************
 Program Name			 :  	FN_GET_REDEM_PAID_DAYS_BY_ESN
 Program Type      :  	Function
 Program Arguments :  	IP_ESN
 Returns           :   	Varchar2
 Program Called    :  	None
 Description       :  	This function will return number of days for which an ESN paid through redemption cards.
 Modified By	           Modification    PCR             Description
                            Date         Number
 =============          ============     ======      ============================
  Jai Arza		   		      1/26/2016			 40287		      Initial Creation
***************************************************************************************************************/
  FUNCTION FN_GET_REDEM_PAID_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2
  AS
    LV_R_PAID_DAYS       VARCHAR2(10) := 0;
  BEGIN
    --CR50315
    SELECT SUM(PAID_DAYS)
	  INTO  LV_R_PAID_DAYS
	  FROM
	(
		SELECT  PN.X_REDEEM_DAYS PAID_DAYS,CT.OBJID CTOBJID
		--INTO    LV_R_PAID_DAYS
		FROM    sa.TABLE_SITE_PART SP
				, sa.TABLE_X_CALL_TRANS CT
				, sa.TABLE_X_RED_CARD RC
				, sa.TABLE_MOD_LEVEL ML
				, sa.TABLE_PART_NUM PN
				, sa.TABLE_PART_CLASS PC
		WHERE   1=1
		AND     SP.X_SERVICE_ID = IP_ESN
		AND     SP.PART_STATUS IN ('Inactive','Active','CarrierPending')
		AND     CT.CALL_TRANS2SITE_PART = SP.OBJID
		AND     CT.X_RESULT = 'Completed'
		AND     CT.X_ACTION_TYPE IN ('3','6','401','1')
		AND     RC.RED_CARD2CALL_TRANS = CT.OBJID
		AND     ML.OBJID = RC.X_RED_CARD2PART_MOD
		AND     PN.OBJID = ML.PART_INFO2PART_NUM
		AND     PC.OBJID = PN.PART_NUM2PART_CLASS


		-- Added as part of CR50315 to retrieve Child redemption days
		UNION
		SELECT  MV.DAYS PAID_DAYS,CT.OBJID CTOBJID
		  FROM  sa.TABLE_SITE_PART SP
				, sa.TABLE_X_CALL_TRANS CT
				, sa.TABLE_X_CALL_TRANS_EXT CTE
				, sa.SERVICE_PLAN_FEAT_PIVOT_MV MV
		 WHERE  1=1
		   AND  SP.X_SERVICE_ID = IP_ESN
		   AND  SP.PART_STATUS IN ('Inactive','Active','CarrierPending')
		   AND  CT.CALL_TRANS2SITE_PART = SP.OBJID
		   AND  CT.X_RESULT = 'Completed'
		   AND  CT.X_ACTION_TYPE IN ('3','6','401','1')
		   AND  CT.OBJID = CTE.CALL_TRANS_EXT2CALL_TRANS
		   AND  CTE.SERVICE_PLAN_ID = MV.SERVICE_PLAN_OBJID
		   AND  MV.BIZ_LINE = 'TOTAL WIRELESS'
		   AND  CTE.master_flag = 'N'
	  );
    --
    RETURN  LV_R_PAID_DAYS;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END FN_GET_REDEM_PAID_DAYS_BY_ESN;
/***************************************************************************************************************
 Program Name			 :  	FN_GET_AR_PAID_DAYS_BY_ESN
 Program Type      :  	Function
 Program Arguments :  	IP_ESN
 Returns           :   	Varchar2
 Program Called    :  	None
 Description       :  	This function will return number of days for which an ESN paid through auto-enrollment (auto refill)
 Modified By	           Modification    PCR             Description
                            Date         Number
 =============          ============     ======      ============================
  Jai Arza		   		      1/26/2016			 40287		      Initial Creation
***************************************************************************************************************/
  FUNCTION FN_GET_AR_PAID_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2
  AS
    LV_AR_PAID_DAYS    VARCHAR2(10) := 0;
  BEGIN
    SELECT  SUM( decode(pph.x_payment_type,'LL_RECURRING',30,PN.X_REDEEM_DAYS))       -- CR39592 PMistry 04/13/2015
    INTO    LV_AR_PAID_DAYS
    FROM    sa.X_PROGRAM_PURCH_HDR PPH
            , sa.X_PROGRAM_PURCH_DTL PPD
            , sa.X_PROGRAM_ENROLLED PE
            , sa.X_PROGRAM_PARAMETERS PP
            , sa.TABLE_PART_NUM PN
    WHERE   1=1
    AND     PPD.X_ESN = IP_ESN
    AND     PPD.PGM_PURCH_DTL2PROG_HDR =PPH.OBJID
    AND     PPH.X_ICS_RFLAG||'' IN ('ACCEPT','SOK')
    AND     PE.OBJID = PPD.PGM_PURCH_DTL2PGM_ENROLLED
    AND     PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
    AND     PN.OBJID = DECODE(PP.X_IS_RECURRING,1,PP.PROG_PARAM2PRTNUM_MONFEE,PP.PROG_PARAM2PRTNUM_ENRLFEE)
    AND     PN.PART_TYPE != 'FREE';

    RETURN  LV_AR_PAID_DAYS;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END FN_GET_AR_PAID_DAYS_BY_ESN;
/***************************************************************************************************************
 Program Name			 :  	FN_GET_PAID_DAYS_BY_ESN
 Program Type      :  	Function
 Program Arguments :  	IP_ESN
 Returns           :   	Varchar2
 Program Called    :  	SA.BUYBACK_PKG.FN_GET_REDEM_PAID_DAYS_BY_ESN
                        SA.BUYBACK_PKG.FN_GET_AR_PAID_DAYS_BY_ESN
 Description       :  	This function will return total number of paid days for a ESN.
 Modified By	           Modification    PCR             Description
                            Date         Number
 =============          ============     ======      ============================
  Jai Arza		   		      1/26/2016			 40287		      Initial Creation
***************************************************************************************************************/
  FUNCTION FN_GET_PAID_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2
  AS
    LV_AR_PAID_DAYS     VARCHAR2(10) := 0;
    LV_R_PAID_DAYS      VARCHAR2(10) := 0;
    LV_PAID_DAYS        VARCHAR2(10) := 0;
  BEGIN
    SELECT  sa.BUYBACK_PKG.FN_GET_REDEM_PAID_DAYS_BY_ESN(IP_ESN)
    INTO    LV_R_PAID_DAYS
    FROM    DUAL;

    SELECT  sa.BUYBACK_PKG.FN_GET_AR_PAID_DAYS_BY_ESN(IP_ESN)
    INTO    LV_AR_PAID_DAYS
    FROM    DUAL;

    LV_PAID_DAYS := NVL(LV_R_PAID_DAYS, 0)+ NVL(LV_AR_PAID_DAYS, 0);
    RETURN  LV_PAID_DAYS;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END FN_GET_PAID_DAYS_BY_ESN;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
END BUYBACK_PKG;
/
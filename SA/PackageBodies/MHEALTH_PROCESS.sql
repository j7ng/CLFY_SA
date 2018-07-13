CREATE OR REPLACE PACKAGE BODY sa.MHEALTH_PROCESS AS
--------------------------------------------------------------------------------------------
--$RCSfile: MHEALTH_PROCESS_PKB.sql,v $
--$Revision: 1.6 $
--$Author: mmunoz $
--$Date: 2012/05/17 19:01:09 $
--$ $Log: MHEALTH_PROCESS_PKB.sql,v $
--$ Revision 1.6  2012/05/17 19:01:09  mmunoz
--$ Moving the line to close cursor
--$
--$ Revision 1.5  2012/05/17 15:47:53  mmunoz
--$ CUSTOMER FAVORED changes to COMBINATION
--$
--$ Revision 1.4  2012/05/16 15:14:48  mmunoz
--$ CR20202 Including logic with not part classes combination
--$
--$ Revision 1.3  2012/05/15 19:40:39  mmunoz
--$ CR20202 Including combination for all click plan values
--$
--$ Revision 1.2  2012/05/10 19:50:57  mmunoz
--$ CR20202 Including the click related with the last enrollmentpending
--$
--$ Revision 1.1  2012/05/03 20:27:06  mmunoz
--$ CR20202
--$
--------------------------------------------------------------------------------------------
  PROCEDURE get_cust_free_dial (
        ip_esn      IN  sa.table_part_inst.part_serial_no%type,
        op_phone    OUT sa.table_site.phone%type
    )
	IS
	    CURSOR GET_PHONE IS
        SELECT /*+ ORDERED */
               CTS.PHONE
        FROM   X_PROGRAM_ENROLLED   PE,
               X_PROGRAM_PARAMETERS PP,
               TABLE_SITE           MTS,
               TABLE_SITE           CTS,
               TABLE_CONTACT_ROLE   CTSCR,
               TABLE_CONTACT        CHILD_CT,
               TABLE_WEB_USER       WEB,
               TABLE_CONTACT        CUST_CT
        WHERE PE.X_ESN = ip_esn
        AND   PE.X_ENROLLMENT_STATUS = 'ENROLLED'
        AND   PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
        AND   PP.X_FREE_DIAL2SITE IS NOT NULL
        AND   MTS.OBJID = PP.X_FREE_DIAL2SITE
        AND   CTS.CHILD_SITE2SITE = MTS.OBJID
        AND   CTSCR.CONTACT_ROLE2SITE = CTS.OBJID
        AND   CHILD_CT.OBJID = CTSCR.CONTACT_ROLE2CONTACT
        AND   WEB.OBJID = PE.PGM_ENROLL2WEB_USER
        AND   CUST_CT.OBJID = WEB.WEB_USER2CONTACT
        AND   CUST_CT.STATE = CHILD_CT.STATE
        ORDER BY PE.OBJID DESC;

	    get_phone_rec   get_phone%rowtype;

    BEGIN
      op_phone := null;
	    OPEN get_phone;
	    FETCH get_phone INTO get_phone_rec;
	    CLOSE get_phone;
	    op_phone := get_phone_rec.phone;
    END get_cust_free_dial;

-----------------------------------------
  PROCEDURE get_cust_favored_sms (
        IP_ESN      IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE,
        op_plan_id  OUT sa.table_x_click_plan.objid%type
	) IS
	    CURSOR get_sms_values (
           IP_ESN      IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
      )IS
        SELECT
          MIN(nvl(X_CLICK_LOCAL,99999))            X_CLICK_LOCAL,
          MIN(nvl(X_CLICK_LD,99999))               X_CLICK_LD,
          MIN(nvl(X_CLICK_RL,99999))               X_CLICK_RL,
          MIN(nvl(X_CLICK_RLD,99999))              X_CLICK_RLD,
          MIN(nvl(X_CLICK_HOME_INTL,99999))        X_CLICK_HOME_INTL,
          MIN(nvl(X_CLICK_IN_SMS,99999))           X_CLICK_IN_SMS,
          MIN(nvl(X_CLICK_OUT_SMS,99999))          X_CLICK_OUT_SMS,
          MIN(nvl(X_CLICK_ROAM_INTL,99999))        X_CLICK_ROAM_INTL,
          MIN(nvl(X_HOME_INBOUND,99999))           X_HOME_INBOUND,
          MIN(nvl(X_ROAM_INBOUND,99999))           X_ROAM_INBOUND,
          MIN(nvl(X_BROWSING_RATE,99999))          X_BROWSING_RATE,
          MIN(nvl(X_MMS_INBOUND,99999))            X_MMS_INBOUND,
          MIN(nvl(X_MMS_OUTBOUND,99999))           X_MMS_OUTBOUND,
          decode(MIN(nvl(X_CLICK_ILD,99999))
                ,99999,0,MIN(nvl(X_CLICK_ILD,99999)) ) X_CLICK_ILD,
          COUNT(*)              PLAN_COUNT,
          MIN(OBJID)            OBJID
        FROM    TABLE_X_CLICK_PLAN
        WHERE   X_PLAN_ID IN
        (
        SELECT /*+ ORDERED */
               pp.x_sms_rate CLICK_X_PLAN_ID
        FROM   X_PROGRAM_ENROLLED   PE,
               X_PROGRAM_PARAMETERS PP
        WHERE PE.X_ESN = IP_ESN
        AND   PE.X_ENROLLMENT_STATUS in ('ENROLLED','PREPROCESSED')
        AND   PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
        UNION
        SELECT CLICK_X_PLAN_ID  --latest row ENROLLMENTPENDING
        FROM   (
               SELECT /*+ ORDERED */
                      pp.x_sms_rate CLICK_X_PLAN_ID, pe.x_insert_date
               FROM   X_PROGRAM_ENROLLED   PE,
                      X_PROGRAM_PARAMETERS PP
               WHERE PE.X_ESN = IP_ESN
               AND   PE.X_ENROLLMENT_STATUS in ('ENROLLMENTPENDING')
               AND   PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
               ORDER BY pe.x_insert_date DESC
               )
        WHERE ROWNUM < 2
        UNION
        SELECT /*+ ORDERED */
               click_x_pn.x_plan_id
        FROM    TABLE_PART_INST PI
        ,       TABLE_MOD_LEVEL ML
        ,       TABLE_PART_NUM PN
        ,       table_x_click_plan CLICK_X_PN
        WHERE   PI.PART_SERIAL_NO = ip_esn
        AND     PI.X_DOMAIN = 'PHONES'
        AND     ML.OBJID = PI.N_PART_INST2PART_MOD
        AND     PN.OBJID = ML.PART_INFO2PART_NUM
        AND     CLICK_X_PN.CLICK_PLAN2PART_NUM = PN.OBJID
        )
        ;

      CURSOR get_sms_values_nopc (
           IP_ESN      IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE
      )IS
        SELECT
          MIN(nvl(X_CLICK_LOCAL,99999))            X_CLICK_LOCAL,
          MIN(nvl(X_CLICK_LD,99999))               X_CLICK_LD,
          MIN(nvl(X_CLICK_RL,99999))               X_CLICK_RL,
          MIN(nvl(X_CLICK_RLD,99999))              X_CLICK_RLD,
          MIN(nvl(X_CLICK_HOME_INTL,99999))        X_CLICK_HOME_INTL,
          MIN(nvl(X_CLICK_IN_SMS,99999))           X_CLICK_IN_SMS,
          MIN(nvl(X_CLICK_OUT_SMS,99999))          X_CLICK_OUT_SMS,
          MIN(nvl(X_CLICK_ROAM_INTL,99999))        X_CLICK_ROAM_INTL,
          MIN(nvl(X_HOME_INBOUND,99999))           X_HOME_INBOUND,
          MIN(nvl(X_ROAM_INBOUND,99999))           X_ROAM_INBOUND,
          MIN(nvl(X_BROWSING_RATE,99999))          X_BROWSING_RATE,
          MIN(nvl(X_MMS_INBOUND,99999))            X_MMS_INBOUND,
          MIN(nvl(X_MMS_OUTBOUND,99999))           X_MMS_OUTBOUND,
          decode(MIN(nvl(X_CLICK_ILD,99999))
                ,99999,0,MIN(nvl(X_CLICK_ILD,99999)) ) X_CLICK_ILD,
          COUNT(*)              PLAN_COUNT,
          MIN(OBJID)            OBJID
        FROM    TABLE_X_CLICK_PLAN
        WHERE   X_PLAN_ID IN
        (
        SELECT /*+ ORDERED */
               pp.x_sms_rate CLICK_X_PLAN_ID
        FROM   X_PROGRAM_ENROLLED   PE,
               X_PROGRAM_PARAMETERS PP
        WHERE PE.X_ESN = IP_ESN
        AND   PE.X_ENROLLMENT_STATUS in ('ENROLLED','PREPROCESSED')
        AND   PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
        UNION
        SELECT CLICK_X_PLAN_ID
        FROM   (
               SELECT /*+ ORDERED */
                      pp.x_sms_rate CLICK_X_PLAN_ID, pe.x_insert_date
               FROM   X_PROGRAM_ENROLLED   PE,
                      X_PROGRAM_PARAMETERS PP
               WHERE PE.X_ESN = IP_ESN
               AND   PE.X_ENROLLMENT_STATUS in ('ENROLLMENTPENDING')
               AND   PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
               ORDER BY pe.x_insert_date DESC
               )
        WHERE ROWNUM < 2
        )
        ;

      CURSOR get_click_sms (
           click_in_sms        sa.table_x_click_plan.x_click_in_sms%type,
           click_out_sms       sa.table_x_click_plan.x_click_out_sms%type,
           click_local         sa.table_x_click_plan.x_click_local%type,
           click_ld            sa.table_x_click_plan.x_click_ld%type,
           click_rl            sa.table_x_click_plan.x_click_rl%type,
           click_rld           sa.table_x_click_plan.x_click_rld%type,
           click_home_intl     sa.table_x_click_plan.x_click_home_intl%type,
           click_roam_intl     sa.table_x_click_plan.x_click_roam_intl%type,
           home_inbound        sa.table_x_click_plan.x_home_inbound%type,
           roam_inbound        sa.table_x_click_plan.x_roam_inbound%type,
           browsing_rate       sa.table_x_click_plan.x_browsing_rate%type,
           mms_inbound         sa.table_x_click_plan.x_mms_inbound%type,
           mms_outbound        sa.table_x_click_plan.x_mms_outbound%type,
           click_ild           sa.table_x_click_plan.x_click_ild%type
               ) IS
        SELECT objid
        from   table_x_click_plan
        where  x_click_in_sms    = click_in_sms
        and    x_click_out_sms   = click_out_sms
        and    X_CLICK_LOCAL     = click_local
        and    X_CLICK_LD        = click_ld
        and    X_CLICK_RL        = click_rl
        and    X_CLICK_RLD       = click_rld
        and    X_CLICK_HOME_INTL = click_home_intl
        and    X_CLICK_ROAM_INTL = click_roam_intl
        and    X_HOME_INBOUND    = home_inbound
        and    X_ROAM_INBOUND    = roam_inbound
        and    X_BROWSING_RATE   = browsing_rate
        and    X_MMS_INBOUND     = mms_inbound
        and    X_MMS_OUTBOUND    = mms_outbound
        and    X_CLICK_ILD       = click_ild
        and    X_CLICK_TYPE      = 'COMBINATION'
        ;

      get_sms_values_rec  get_sms_values%rowtype;

	  GET_CLICK_SMS_REC   GET_CLICK_SMS%ROWTYPE;
      ERROR_TEXT          VARCHAR2(200);
    BEGIN
      op_plan_id := NULL;

	    OPEN get_sms_values(ip_esn);
	    FETCH get_sms_values INTO get_sms_values_rec;
      IF GET_SMS_VALUES%FOUND THEN
         IF get_sms_values_rec.plan_count = 1 THEN
            op_plan_id := get_sms_values_rec.objid;
         ELSE
		 	OPEN get_sms_values_nopc(ip_esn);
            FETCH get_sms_values_nopc INTO get_sms_values_rec;
			IF get_sms_values_rec.plan_count = 1 THEN
                op_plan_id := get_sms_values_rec.objid;
            ELSE
                OPEN GET_CLICK_SMS(GET_SMS_VALUES_REC.x_click_in_sms,
                               GET_SMS_VALUES_REC.x_click_out_sms,
                               GET_SMS_VALUES_REC.X_CLICK_LOCAL,
                               GET_SMS_VALUES_REC.X_CLICK_LD,
                               GET_SMS_VALUES_REC.X_CLICK_RL,
                               GET_SMS_VALUES_REC.X_CLICK_RLD,
                               GET_SMS_VALUES_REC.X_CLICK_HOME_INTL,
                               GET_SMS_VALUES_REC.X_CLICK_ROAM_INTL,
                               GET_SMS_VALUES_REC.X_HOME_INBOUND,
                               GET_SMS_VALUES_REC.X_ROAM_INBOUND,
                               GET_SMS_VALUES_REC.X_BROWSING_RATE,
                               GET_SMS_VALUES_REC.X_MMS_INBOUND,
                               GET_SMS_VALUES_REC.X_MMS_OUTBOUND,
                               GET_SMS_VALUES_REC.X_CLICK_ILD
                               );
                FETCH GET_CLICK_SMS INTO GET_CLICK_SMS_REC;
                IF get_click_sms%FOUND THEN
                    OP_PLAN_ID := GET_CLICK_SMS_REC.OBJID;
                ELSE
                    ERROR_TEXT := 'ERROR: Customer enrolled in '||GET_SMS_VALUES_REC.PLAN_COUNT||
                             ' plans but there was not found a click plan for that combination';
                END IF;
                CLOSE GET_CLICK_SMS;
		    END IF;
			CLOSE get_sms_values_nopc;
         END IF;
      END IF;
	    CLOSE GET_SMS_VALUES;
      DBMS_OUTPUT.PUT_LINE(ERROR_TEXT);
    END get_cust_favored_sms;
BEGIN
NULL;
END;
/
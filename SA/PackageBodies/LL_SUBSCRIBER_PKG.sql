CREATE OR REPLACE PACKAGE BODY sa.LL_SUBSCRIBER_PKG
IS
  /*******************************************************************************************************
  --$RCSfile: LL_SUBSCRIBER_PKB.sql,v $
  --$ $Log: LL_SUBSCRIBER_PKB.sql,v $
  --$ Revision 1.26  2017/11/14 23:52:14  sgangineni
  --$ CR54704 - Modified to fix exiting issue while validating request type
  --$
  --$ Revision 1.25  2017/11/10 16:13:19  sgangineni
  --$ CR54704 - Added new function IS_LIELINE_ENROLLED
  --$
  --$ Revision 1.24  2017/09/27 14:25:02  sgangineni
  --$ CR49915 - Fix for defect 31213
  --$
  --$ Revision 1.23  2017/09/25 22:12:08  sgangineni
  --$ CR49915 - Modified the enroll_ll_subscriber procedure to accept both LL plan id or
  --$  discount code for enrollment
  --$
  --$ Revision 1.22  2017/09/14 15:41:57  sgangineni
  --$ CR49915 - Fix for defect 30916
  --$
  --$ Revision 1.21  2017/08/14 21:25:09  sgangineni
  --$ CR49915 - Fix for defect 29702
  --$
  --$ Revision 1.20  2017/08/03 19:08:13  sgangineni
  --$ CR49915 - Fix for defects 29288, 29289, 29213
  --$
  --$ Revision 1.19  2017/08/01 20:48:48  sgangineni
  --$ CR49915 - Defect fix for 29180
  --$
  --$ Revision 1.18  2017/07/31 15:33:42  mdave
  --$ CR49915 changes to REDEMPTION, MINC procedures
  --$
  --$ Revision 1.17  2017/07/31 15:13:28  sgangineni
  --$ CR49915 - Modified the logic to calculate discount
  --$
  --$ Revision 1.16  2017/07/19 20:33:42  sgangineni
  --$ CR49915 - Added account level enrollment check in GET_LL_SUBSCRIBER_DETAILS
  --$
  --$ Revision 1.15  2017/07/18 21:15:38  sgangineni
  --$ CR49915 - Issue fix in PROCESS_LL_TRANSFER
  --$
  --$ Revision 1.14  2017/07/14 01:09:28  sgangineni
  --$ CR49915 - Added new param deenroll_reason to the deenroll_ll_subscriber
  --$
  --$ Revision 1.13  2017/07/12 20:00:34  sgangineni
  --$ CR49915 - WFM LIFELINE Changes
  --$
  --$ Revision 1.12  2017/07/11 20:59:03  sgangineni
  --$ CR49915 - WFM LIFELINE changes
  --$
  --$ Revision 1.11  2017/07/11 20:40:37  sgangineni
  --$ CR49915 - WFM LIFELINE - Modified as per code review comments
  --$
  --$ Revision 1.9  2017/07/07 22:52:51  mdave
  --$ CR49915 - Merge with sagar changes
  --$
  --$ Revision 1.7  2017/07/06 18:45:51  mdave
  --$ CR49915 ll_minc_transaction change
  --$
  --$ Revision 1.6  2017/06/30 21:22:03  sgangineni
  --$ CR49915 - Added new procedure PROCESS_LL_TRANSFER
  --$
  --$
  * Description: This package includes the below procedures and functions
  * GET_CURRENT_LL_PLAN_ID
  * GET_LL_SUBSCRIBER_DETAILS
  * ENROLL_LL_SUBSCRIBER
  * DEENROLL_LL_SUBSCRIBER
  * CALCULATE_LL_DISCOUNT
  *
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
  FUNCTION  get_current_ll_plan_id (n_subs_id         IN  NUMBER,
                                    n_service_plan_id IN  NUMBER)
  RETURN NUMBER
  IS
    c_current_ll_plan_id  NUMBER;
  BEGIN
    --Get the current enrollement ll plan id
    BEGIN
      SELECT lslp.ll_plan_id
      INTO   c_current_ll_plan_id
      FROM   mtm_ll_subs2ll_plans lslp,
             mtm_ll_plans2serv_plan lpsp
      WHERE lslp.ll_subs_objid = n_subs_id
      AND lslp.ll_plan_id      = lpsp.ll_plan_id
      AND lpsp.sp_objid        = n_service_plan_id;
    EXCEPTION
      WHEN TOO_MANY_ROWS
      THEN
        SELECT ll_plan_id
        INTO   c_current_ll_plan_id
        FROM (SELECT lslp.ll_plan_id,
                     lp.discount_amount
              FROM   mtm_ll_subs2ll_plans lslp,
                     mtm_ll_plans2serv_plan lpsp,
                     ll_plans lp
              WHERE lslp.ll_subs_objid = n_subs_id
              AND   lslp.ll_plan_id      = lpsp.ll_plan_id
              AND   lslp.ll_plan_id      = lp.plan_id
              AND   lpsp.sp_objid        = n_service_plan_id
              ORDER BY lp.discount_amount DESC)
        WHERE rownum = 1;
      WHEN OTHERS
      THEN
        c_current_ll_plan_id := NULL;
    END;
    RETURN c_current_ll_plan_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_current_ll_plan_id;

  /******************************************************************************************************
  * Procedure/Function Name : GET_LL_SUBSCRIBER_DETAILS                                                 *
  * Purpose : Procedure to check if the given MIN is eligible for LIFELINE services                     *
  *                                                                                                     *
  * Description : This procedure will retruns below values for out param o_is_eligible_for_enrollment   *
  *               'E' - If the subscriber is already enrolled for LL service                            *
  *               'Y' - If the subscriber is not enrolled for LL service, but eligible                  *
  *               'N' - If the subscriber is not enrolled for LL service, and also not eligible         *
  *               It will also returns the other ESN related attributes                                 *
  ******************************************************************************************************/
  PROCEDURE GET_LL_SUBSCRIBER_DETAILS ( i_min                        IN      VARCHAR2,
                                        i_esn                        IN      VARCHAR2,
                                        o_esn                        OUT     VARCHAR2,
                                        o_min                        OUT     VARCHAR2,
                                        o_is_eligible_for_enrollment OUT     VARCHAR2,
                                        o_service_plan_id            OUT     NUMBER,
                                        o_service_plan_description   OUT     VARCHAR2,
                                        o_ll_service_type            OUT     VARCHAR2,
                                        o_tribal_ll_service_type     OUT     VARCHAR2,
                                        o_app_part_number            OUT     VARCHAR2,
                                        o_app_part_class             OUT     VARCHAR2,
                                        o_error_num                  OUT     VARCHAR2,
                                        o_error_msg                  OUT     VARCHAR2
                                      )
  IS
    cst sa.customer_type := sa.customer_type();
    n_ll_plan_count       NUMBER;
    n_enrolled_esn_count  NUMBER;
  BEGIN
    IF i_min IS NULL AND i_esn IS NULL
    THEN
      o_error_num := '1001';
      o_error_msg := 'BOTH MIN AND ESN CANNOT BE NULL. ANYONE OF THEM IS MANDATORY';
      RETURN;
    END IF;

    IF i_min IS NULL
    THEN
      --Get the MIN if ESN is passed
      cst.esn := i_esn;
      cst.min := sa.customer_info.get_min (i_esn => cst.esn);
    ELSE
      cst.min := i_min;
    END IF;

    IF i_esn IS NULL
    THEN
      --Get the ESN if MIN is passed
      cst.esn := sa.customer_info.get_esn (i_min => i_min);
    ELSE
      cst.esn := i_esn;
    END IF;

    cst := cst.get_service_plan_attributes;

    --Get service plan attributes
    o_service_plan_id := cst.service_plan_objid;
    o_service_plan_description := cst.service_plan_name;
    o_app_part_number := cst.service_plan_part_number;
    o_app_part_class := cst.service_plan_part_class_name;
    o_ll_service_type := cst.ll_service_type;
    o_tribal_ll_service_type := cst.ll_tribal_service_type;
    o_esn := cst.esn;
    o_min := cst.min;

    --Check if an active subscription already exists
    BEGIN
      SELECT 'E'
      INTO   o_is_eligible_for_enrollment
      FROM   ll_subscribers
      WHERE  CURRENT_MIN = cst.min
      AND    enrollment_status = 'ENROLLED'
      AND    TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);
      o_error_num := '0';
      o_error_msg := 'SUCCESS';
      RETURN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --Check if any other ESN from the account is already enrolled
        BEGIN
          SELECT count(pi_esn2.part_serial_no)
          INTO   n_enrolled_esn_count
          FROM   table_part_inst pi_esn2,
                 table_part_inst pi_esn1,
                 table_x_contact_part_inst cpi1,
                 table_x_contact_part_inst cpi2,
                 table_web_user wu,
                 ll_subscribers llsub
          WHERE  pi_esn1.part_serial_no = cst.esn
          AND    cpi1.x_contact_part_inst2part_inst = pi_esn1.objid
          AND    cpi1.x_contact_part_inst2contact = wu.web_user2contact
          AND    cpi2.x_contact_part_inst2contact = wu.web_user2contact
          AND    cpi2.x_contact_part_inst2part_inst = pi_esn2.objid
          AND    pi_esn2.part_serial_no <> cst.esn
          AND    llsub.current_esn = pi_esn2.part_serial_no
          AND    llsub.enrollment_status = 'ENROLLED'
          AND    TRUNC(NVL(llsub.projected_deenrollment, SYSDATE+1)) >= TRUNC(SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            n_enrolled_esn_count := 0;
        END;
      WHEN OTHERS THEN
        o_esn                        := NULL;
        o_min                        := NULL;
        o_is_eligible_for_enrollment := NULL;
        o_service_plan_id            := NULL;
        o_service_plan_description   := NULL;
        o_ll_service_type            := NULL;
        o_tribal_ll_service_type     := NULL;
        o_app_part_number            := NULL;
        o_app_part_class             := NULL;
        o_error_num := SQLCODE;
        o_error_msg := 'Unexpected error while validating the subscriber. Error-'|| SUBSTR(SQLERRM, 1, 2000);
        RETURN;
    END;

    IF n_enrolled_esn_count > 0
    THEN
      o_is_eligible_for_enrollment := 'E';
      o_error_num := '0';
      o_error_msg := 'SUCCESS';
      RETURN;
    ELSE
      --Check if ESN is active
      BEGIN
        SELECT x_part_inst_status
        INTO   cst.esn_part_inst_status
        FROM   table_part_inst
        WHERE  part_serial_no = cst.esn
        AND    x_domain = 'PHONES';
      EXCEPTION
        WHEN OTHERS THEN
          cst.esn_part_inst_status := '0';
      END;

      IF cst.esn_part_inst_status <> '52'
      THEN
        o_is_eligible_for_enrollment := 'N';
        o_error_num := '0';
        o_error_msg := 'SUCCESS';
        RETURN;
      ELSE
        --Check the eligibility for LL plans
        BEGIN
          SELECT count(1)
          INTO   n_ll_plan_count
          FROM   mtm_ll_plans2serv_plan
          WHERE  sp_objid = o_service_plan_id;
        EXCEPTION
          WHEN OTHERS THEN
            o_is_eligible_for_enrollment := NULL;
            o_error_num := SQLCODE;
            o_error_msg := 'Unexpected error while checking the enrollment eligibility. Error-'||SUBSTR(SQLERRM, 1, 2000);
        END;

        IF NVL(n_ll_plan_count, 0) > 0
        THEN
          o_is_eligible_for_enrollment := 'Y';
        ELSE
          o_is_eligible_for_enrollment := 'N';
        END IF;
      END IF; --cst.esn_part_inst_status <> '52'
    END IF;

    o_error_num := '0';
    o_error_msg := 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      o_esn                        := NULL;
      o_min                        := NULL;
      o_is_eligible_for_enrollment := NULL;
      o_service_plan_id            := NULL;
      o_service_plan_description   := NULL;
      o_ll_service_type            := NULL;
      o_tribal_ll_service_type     := NULL;
      o_app_part_number            := NULL;
      o_app_part_class             := NULL;
      o_error_num := SQLCODE;
      o_error_msg := 'Unexpected error while exceuting GET_LL_SUBSCRIBER_DETAILS. Error-'|| SUBSTR(SQLERRM, 1, 2000);
  END GET_LL_SUBSCRIBER_DETAILS;

  PROCEDURE ENROLL_LL_SUBSCRIBER ( ll_subscriber_rec       IN OUT  sa.ll_subscriber_type,
                                   o_ll_sub_id             OUT     NUMBER,
                                   o_esn_part_inst_objid   OUT     NUMBER,
                                   o_app_part_number       OUT     VARCHAR2,
                                   o_app_part_class        OUT     VARCHAR2,
                                   o_Error_Num             OUT     VARCHAR2,
                                   o_Error_Msg             OUT     VARCHAR2
                                 )
  IS
    CURSOR get_ll_sub_dtls_cur ( c_sub_id NUMBER )
    IS
      SELECT *
      FROM   sa.ll_subscribers
      WHERE  objid = c_sub_id;

    get_ll_sub_dtls_rec   get_ll_sub_dtls_cur%ROWTYPE;
    cst sa.customer_type := sa.customer_type();

    --local variables
    c_contact_address_1           VARCHAR2(200);
    c_contact_address_2           VARCHAR2(200);
    c_contact_city                VARCHAR2(30);
    c_contact_state               VARCHAR2(40);
    c_contact_email               VARCHAR2(100);
    n_ll_subscriber_id            NUMBER;
    c_current_ll_plan_id          VARCHAR2(200);
    c_event_code                  VARCHAR2(20);
    c_err_num                     VARCHAR2(100);
    c_err_msg                     VARCHAR2(4000);
    c_subscriber_exist            VARCHAR2(1);

    c_min                         VARCHAR2(200);
    c_esn                         VARCHAR2(200);
    c_is_eligible_for_enrollment  VARCHAR2(200);
    n_service_plan_id             NUMBER;
    c_service_plan_description    VARCHAR2(200);
    c_ll_service_type             VARCHAR2(200);
    c_tribal_ll_service_type      VARCHAR2(200);
    c_app_part_number             VARCHAR2(200);
    c_app_part_class              VARCHAR2(200);
    c_error_num                   VARCHAR2(200);
    c_error_msg                   VARCHAR2(200);
  BEGIN
    --Get event code for the input request type
    BEGIN
      SELECT x_code_number
      INTO   c_event_code
      FROM   table_x_code_table ct,
             ll_request_types lrt
      WHERE  UPPER(lrt.request_type) = UPPER(ll_subscriber_rec.request_type)
      AND    TO_CHAR(lrt.request_type2x_code_table) = ct.x_code_number;
    EXCEPTION
      WHEN OTHERS THEN
        c_event_code := NULL;
    END;

    --Input validation starts
    IF c_event_code IS NULL
    THEN
      o_error_num := '1101';
      o_error_msg := 'INVALID REQUEST TYPE';
      RETURN;
    END IF;

    IF ll_subscriber_rec.min IS NULL AND ll_subscriber_rec.esn IS NULL
    THEN
      o_error_num := '1102';
      o_error_msg := 'BOTH MIN AND ESN CANNOT BE NULL. ANYONE OF THEM IS MANDATORY';
      RETURN;
    ELSIF ll_subscriber_rec.LID IS NULL
    THEN
      o_error_num := '1103';
      o_error_msg  := 'LIFELINE ID IS MANDATORY FOR ENROLLMENT';
      RETURN;
    ELSIF ll_subscriber_rec.ll_plan_dtl_tbl IS NULL
    THEN
      o_error_num := '1104';
      o_error_msg  := 'AT LEAST ONE LIFELINE PLAN IS MUST FOR ENROLLMENT';
      RETURN;
    ELSIF ll_subscriber_rec.ll_plan_dtl_tbl.count = 0
    THEN
      o_error_num := '1105';
      o_error_msg  := 'AT LEAST ONE LIFELINE PLAN IS MUST FOR ENROLLMENT';
      RETURN;
    END IF;
    --End of input validation

    IF ll_subscriber_rec.min IS NULL
    THEN
      --Get the MIN if ESN is passed
      cst.min := sa.customer_info.get_min (i_esn => ll_subscriber_rec.esn);
    ELSE
      cst.min := ll_subscriber_rec.min;
    END IF;

    IF ll_subscriber_rec.esn IS NULL
    THEN
      --Get the ESN if MIN is passed
      cst.esn := sa.customer_info.get_esn (i_min => ll_subscriber_rec.min);
    ELSE
      cst.esn := ll_subscriber_rec.esn;
    END IF;

    --Get service plan attributes
    cst := cst.get_service_plan_attributes;

    --Get ESN part instance objid
    o_esn_part_inst_objid := cst.esn_part_inst_objid;
    o_app_part_number := cst.service_plan_part_number;
    o_app_part_class := cst.service_plan_part_class_name;

    IF o_esn_part_inst_objid IS NULL
    THEN
      o_error_num := '1106';
      o_error_msg  := 'ESN/MIN IS NOT VALID';
      RETURN;
    END IF;

    IF UPPER(ll_subscriber_rec.request_type) = 'ENROLL'
    THEN
      --Check if the enrollment already exists for the same MIN and LID
      BEGIN
        SELECT 'Y'
        INTO   c_subscriber_exist
        FROM   sa.ll_subscribers
        WHERE  lid = ll_subscriber_rec.lid
        AND    current_min = cst.min
        AND    NVL(projected_deenrollment, SYSDATE) >= SYSDATE;
      EXCEPTION
      WHEN OTHERS THEN
        c_subscriber_exist := 'N';
      END;

      IF c_subscriber_exist = 'Y'
      THEN
        o_error_num := '1107';
        o_error_msg  := 'ACTIVE ENROLLMENT EXIST FOR THE GIVEN LID AND MIN';
        RETURN;
      END IF;

      sa.LL_SUBSCRIBER_PKG.GET_LL_SUBSCRIBER_DETAILS( I_MIN                         => cst.min,
                                                      I_ESN                         => cst.esn,
                                                      O_MIN                         => c_min,
                                                      O_ESN                         => c_esn,
                                                      O_IS_ELIGIBLE_FOR_ENROLLMENT  => c_is_eligible_for_enrollment,
                                                      O_SERVICE_PLAN_ID             => n_service_plan_id,
                                                      O_SERVICE_PLAN_DESCRIPTION    => c_service_plan_description,
                                                      O_LL_SERVICE_TYPE             => c_ll_service_type,
                                                      O_TRIBAL_LL_SERVICE_TYPE      => c_tribal_ll_service_type,
                                                      O_APP_PART_NUMBER             => c_app_part_number,
                                                      O_APP_PART_CLASS              => c_app_part_class,
                                                      O_ERROR_NUM                   => c_error_num,
                                                      O_ERROR_MSG                   => c_error_msg
      );

      IF c_is_eligible_for_enrollment = 'E'
      THEN
        o_error_num := '1113';
        o_error_msg  := 'ANOTHER ESN/MIN FROM THE SAME ACCOUNT OF GIVEN ESN/MIN IS ALREADY ENROLLED';
        RETURN;
      ELSIF c_is_eligible_for_enrollment = 'N'
      THEN
        o_error_num := '1114';
        o_error_msg  := 'GIVEN ESN/MIN IS NOT ELIGIBLE FOR ENROLLMENT';
        RETURN;
      END IF;

      n_ll_subscriber_id := seq_ll_subscribers.nextval;

      --Create new subscriber record
      INSERT INTO LL_SUBSCRIBERS (OBJID,
                                  LID,
                                  OLD_LID,
                                  CURRENT_MIN,
                                  CURRENT_ESN,
                                  LL_SUBS2CONTACT,
                                  LL_SUBS2WEB_USER,
                                  LASTMODIFIED,
                                  ENROLLMENT_STATUS,
                                  DEENROLL_REASON,
                                  CURRENT_ENROLLMENT_DATE,
                                  ORIGINAL_ENROLLMENT_DATE,
                                  ORIGINAL_DEENROLLMENT_REASON,
                                  CURRENT_LL_PLAN_ID,
                                  LAST_DISCOUNT_DT,
                                  PROJECTED_DEENROLLMENT,
                                  FULL_NAME,
                                  ADDRESS_1,
                                  ADDRESS_2,
                                  CITY,
                                  STATE,
                                  ZIP,
                                  ZIP2,
                                  E_MAIL,
                                  HOMENUMBER,
                                  ALLOW_PRERECORDED,
                                  EMAIL_PREF,
                                  LAST_AV_DATE,
                                  AV_DUE_DATE,
                                  QUALIFY_DATE,
                                  QUALIFY_TYPE,
                                  EXTERNAL_ACCOUNT,
                                  STATEIDNAME,
                                  STATEIDVALUE,
                                  ADL,
                                  USACFORM,
                                  ELIGIBLEFIRSTNAME,
                                  ELIGIBLELASTNAME,
                                  ELIGIBLEMIDDLENAMEINITIAL,
                                  HMODISCLAIMER,
                                  IPADDRESS,
                                  PERSONID,
                                  PERSONISINVALID,
                                  STATEAGENCYQUALIFICATION,
                                  TRANSFERFLAG,
                                  QUALIFY_PROGRAMS,
                                  DOBISINVALID,
                                  SSNISINVALID,
                                  ADDRESSISCOMMERCIAL,
                                  ADDRESSISDUPLICATED,
                                  ADDRESSISINVALID,
                                  ADDRESSISTEMPORARY,
                                  CAMPAIGN,
                                  PROMOTION,
                                  PROMOCODE,
                                  CHANNEL_TYPE,
                                  LAST_MODIFIED_EVENT)
                          VALUES (n_ll_subscriber_id,                               --OBJID
                                  ll_subscriber_rec.lid,                                    --LID
                                  ll_subscriber_rec.old_lid,                                --OLD_LID
                                  cst.min,                                                  --CURRENT_MIN
                                  cst.esn,                                                  --CURRENT_ESN
                                  ll_subscriber_rec.contact_objid,                          --LL_SUBS2CONTACT
                                  ll_subscriber_rec.web_user_objid,                         --LL_SUBS2WEB_USER
                                  SYSDATE,                                                  --LASTMODIFIED
                                  UPPER(ll_subscriber_rec.enrollment_status),                      --ENROLLMENT_STATUS
                                  ll_subscriber_rec.deenroll_reason,                        --DEENROLL_REASON
                                  NVL(ll_subscriber_rec.CURRENT_ENROLLMENT_DATE ,SYSDATE),  --CURRENT_ENROLLMENT_DATE
                                  ll_subscriber_rec.ORIGINAL_ENROLLMENT_DATE,               --ORIGINAL_ENROLLMENT_DATE
                                  ll_subscriber_rec.ORIGINAL_DEENROLLMENT_REASON,           --ORIGINAL_DEENROLLMENT_REASON
                                  c_current_ll_plan_id,                                     --CURRENT_LL_PLAN_ID
                                  ll_subscriber_rec.LAST_DISCOUNT_DT,                       --LAST_DISCOUNT_DT
                                  NULL,                                                     --PROJECTED_DEENROLLMENT
                                  ll_subscriber_rec.FULL_NAME,                              --FULL_NAME
                                  ll_subscriber_rec.ADDRESS_1,                              --ADDRESS_1
                                  ll_subscriber_rec.ADDRESS_2,                              --ADDRESS_2
                                  ll_subscriber_rec.city,                                   --CITY
                                  ll_subscriber_rec.state,                                  --STATE
                                  ll_subscriber_rec.zip,                                    --ZIP
                                  ll_subscriber_rec.zip2,                                   --ZIP2
                                  ll_subscriber_rec.E_MAIL,                                 --E_MAIL
                                  ll_subscriber_rec.HOMENUMBER,                             --HOMENUMBER
                                  ll_subscriber_rec.ALLOW_PRERECORDED,                      --ALLOW_PRERECORDED
                                  ll_subscriber_rec.EMAIL_PREF,                             --EMAIL_PREF
                                  ll_subscriber_rec.LAST_AV_DATE,                           --LAST_AV_DATE
                                  ll_subscriber_rec.AV_DUE_DATE,                            --AV_DUE_DATE
                                  ll_subscriber_rec.QUALIFY_DATE,                           --QUALIFY_DATE
                                  ll_subscriber_rec.QUALIFY_TYPE,                           --QUALIFY_TYPE
                                  ll_subscriber_rec.EXTERNAL_ACCOUNT,                       --EXTERNAL_ACCOUNT
                                  ll_subscriber_rec.STATEIDNAME,                            --STATEIDNAME
                                  ll_subscriber_rec.STATEIDVALUE,                           --STATEIDVALUE
                                  ll_subscriber_rec.ADL,                                    --ADL
                                  ll_subscriber_rec.USACFORM,                               --USACFORM
                                  ll_subscriber_rec.ELIGIBLEFIRSTNAME,                      --ELIGIBLEFIRSTNAME
                                  ll_subscriber_rec.ELIGIBLELASTNAME,                       --ELIGIBLELASTNAME
                                  ll_subscriber_rec.ELIGIBLEMIDDLENAMEINITIAL,              --ELIGIBLEMIDDLENAMEINITIAL
                                  ll_subscriber_rec.HMODISCLAIMER,                          --HMODISCLAIMER
                                  ll_subscriber_rec.IPADDRESS,                              --IPADDRESS
                                  ll_subscriber_rec.PERSONID,                               --PERSONID
                                  ll_subscriber_rec.PERSONISINVALID,                        --PERSONISINVALID
                                  ll_subscriber_rec.STATEAGENCYQUALIFICATION,               --STATEAGENCYQUALIFICATION
                                  ll_subscriber_rec.TRANSFERFLAG,                           --TRANSFERFLAG
                                  ll_subscriber_rec.QUALIFY_PROGRAMS,                       --QUALIFY_PROGRAMS
                                  ll_subscriber_rec.DOBISINVALID,                           --DOBISINVALID
                                  ll_subscriber_rec.SSNISINVALID,                           --SSNISINVALID
                                  ll_subscriber_rec.ADDRESSISCOMMERCIAL,                    --ADDRESSISCOMMERCIAL
                                  ll_subscriber_rec.ADDRESSISDUPLICATED,                    --ADDRESSISDUPLICATED
                                  ll_subscriber_rec.ADDRESSISINVALID,                       --ADDRESSISINVALID
                                  ll_subscriber_rec.ADDRESSISTEMPORARY,                     --ADDRESSISTEMPORARY
                                  ll_subscriber_rec.CAMPAIGN,                               --CAMPAIGN
                                  ll_subscriber_rec.PROMOTION,                              --PROMOTION
                                  ll_subscriber_rec.PROMOCODE,                              --PROMOCODE
                                  ll_subscriber_rec.CHANNEL_TYPE,                           --CHANNEL_TYPE
                                  'LL_ENROLLMENT'
                                 );

      --Populate MTM_LL_SUBS2LL_PLANS
      IF ll_subscriber_rec.ll_plan_dtl_tbl IS NOT NULL
      THEN
        FOR i IN 1..ll_subscriber_rec.ll_plan_dtl_tbl.count
        LOOP
          BEGIN
            INSERT INTO MTM_LL_SUBS2LL_PLANS (LL_SUBS_OBJID,
                                              LL_PLAN_ID
                                             )
                                      VALUES (n_ll_subscriber_id,
                                              ll_subscriber_rec.ll_plan_dtl_tbl(i).plan_id
                                             );
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
            o_Error_Num := '1112';
            o_Error_Msg := 'DUPLICATE LIFELINE PLAN IDS FOUND IN THE INPUT FOR LID:'|| ll_subscriber_rec.LID || ' AND MIN:'||cst.min ;
            RETURN;
          END;
        END LOOP;
      END IF;

      --Update the current enrolled LL plan id in subscirber table
      IF ll_subscriber_rec.current_ll_plan_id IS NOT NULL
      THEN
        BEGIN
          SELECT plan_id
            INTO c_current_ll_plan_id
            FROM ll_plans
           WHERE TO_CHAR(plan_id) = ll_subscriber_rec.current_ll_plan_id
              OR discount_code = ll_subscriber_rec.current_ll_plan_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            c_current_ll_plan_id := get_current_ll_plan_id (n_ll_subscriber_id, cst.service_plan_objid);
        END;
      ELSE
        c_current_ll_plan_id := get_current_ll_plan_id (n_ll_subscriber_id, cst.service_plan_objid);
      END IF;

      UPDATE sa.ll_subscribers
      SET    current_ll_plan_id = c_current_ll_plan_id
      WHERE  objid = n_ll_subscriber_id;

      --Update contact address details
      IF ll_subscriber_rec.contact_objid IS NOT NULL AND ll_subscriber_rec.address_1 IS NOT NULL
      THEN
        UPDATE table_contact
        SET    address_1 = ll_subscriber_rec.address_1,
               address_2 = ll_subscriber_rec.address_2,
               city = ll_subscriber_rec.city,
               state = ll_subscriber_rec.state,
               zipcode = ll_subscriber_rec.zip,
               e_mail = NVL(ll_subscriber_rec.e_mail, e_mail)
        WHERE  objid = ll_subscriber_rec.contact_objid;
      END IF;
    ELSIF UPPER(ll_subscriber_rec.request_type) = 'DEENROLL'
    THEN
      --Get the subscriber id
      BEGIN
        SELECT objid
        INTO   n_ll_subscriber_id
        FROM   sa.LL_SUBSCRIBERS
        WHERE  current_min = cst.min
        AND    lid = ll_subscriber_rec.lid;
        EXCEPTION
          WHEN OTHERS THEN
          o_Error_Num := '1108';
          o_Error_Msg := 'ACTIVE SUBSCRIBER DETAILS NOT FOUND FOR LID:'|| ll_subscriber_rec.LID || ' AND MIN:'||cst.min ;
          RETURN;
      END;

      --Execute the deenrollment procedure
      DEENROLL_LL_SUBSCRIBER ( i_min          => cst.min,
                               i_esn          => cst.esn,
                               o_Error_Num    => c_err_num,
                               o_Error_Msg    => c_err_msg
                             );

      IF c_err_num <> '0'
      THEN
        o_Error_Num := c_err_num;
        o_Error_Msg := c_err_msg;
        RETURN;
      END IF;
    ELSIF UPPER(ll_subscriber_rec.request_type) = 'CONTACTEDIT'
    THEN
      --Get the subscriber id
      BEGIN
        SELECT objid
        INTO   n_ll_subscriber_id
        FROM   sa.LL_SUBSCRIBERS
        WHERE  current_min = cst.min
        AND    lid = ll_subscriber_rec.lid;
      EXCEPTION
        WHEN OTHERS THEN
        o_Error_Num := '1109';
        o_Error_Msg := 'ACTIVE SUBSCRIBER DETAILS NOT FOUND FOR LID:'|| ll_subscriber_rec.LID || ' AND MIN:'||cst.min ;
        RETURN;
      END;

      --Update the new contact info in the ll_subscribers table
      UPDATE LL_SUBSCRIBERS
      SET    LASTMODIFIED                     =   SYSDATE,
             FULL_NAME                        =   ll_subscriber_rec.FULL_NAME,
             ADDRESS_1                        =   ll_subscriber_rec.ADDRESS_1,
             ADDRESS_2                        =   ll_subscriber_rec.ADDRESS_2,
             CITY                             =   ll_subscriber_rec.city,
             STATE                            =   ll_subscriber_rec.state,
             ZIP                              =   ll_subscriber_rec.zip,
             ZIP2                             =   ll_subscriber_rec.zip2,
             E_MAIL                           =   ll_subscriber_rec.E_MAIL,
             HOMENUMBER                       =   ll_subscriber_rec.HOMENUMBER,
             ALLOW_PRERECORDED                =   ll_subscriber_rec.ALLOW_PRERECORDED,
             EMAIL_PREF                       =   ll_subscriber_rec.EMAIL_PREF,
             LAST_MODIFIED_EVENT              =   'LL_CONTACT_EDIT'
      WHERE  objid = n_ll_subscriber_id;

      --Update contact address details
      IF ll_subscriber_rec.contact_objid IS NOT NULL AND ll_subscriber_rec.address_1 IS NOT NULL
      THEN
        UPDATE table_contact
        SET    address_1 = ll_subscriber_rec.address_1,
               address_2 = ll_subscriber_rec.address_2,
               city = ll_subscriber_rec.city,
               state = ll_subscriber_rec.state,
               zipcode = ll_subscriber_rec.zip,
               e_mail = NVL(ll_subscriber_rec.e_mail, e_mail)
        WHERE  objid = ll_subscriber_rec.contact_objid;
      END IF;
    ELSIF UPPER(ll_subscriber_rec.request_type) = 'PROGRAMCHANGE'
    THEN
      --Get the subscriber id
      BEGIN
        SELECT objid
        INTO   n_ll_subscriber_id
        FROM   sa.LL_SUBSCRIBERS
        WHERE  current_min = cst.min
        AND    lid = ll_subscriber_rec.lid;
        EXCEPTION
          WHEN OTHERS THEN
          o_Error_Num := '1110';
          o_Error_Msg := 'ACTIVE SUBSCRIBER DETAILS NOT FOUND FOR LID:'|| ll_subscriber_rec.LID || ' AND MIN:'||cst.min ;
          RETURN;
      END;

      --Populate MTM_LL_SUBS2LL_PLANS
      IF ll_subscriber_rec.ll_plan_dtl_tbl IS NOT NULL
      THEN
        IF ll_subscriber_rec.ll_plan_dtl_tbl.count > 0
        THEN
          DELETE FROM MTM_LL_SUBS2LL_PLANS
          WHERE ll_subs_objid = n_ll_subscriber_id;

          FOR i IN 1..ll_subscriber_rec.ll_plan_dtl_tbl.count
          LOOP
            INSERT INTO MTM_LL_SUBS2LL_PLANS (LL_SUBS_OBJID,
                                              LL_PLAN_ID
                                             )
                                      VALUES ( n_ll_subscriber_id,
                                               ll_subscriber_rec.ll_plan_dtl_tbl(i).plan_id
                                             );
          END LOOP;
        END IF;
      END IF;

      --Update the current enrolled LL plan id in subscirber table
      c_current_ll_plan_id := NVL(ll_subscriber_rec.current_ll_plan_id, get_current_ll_plan_id (n_ll_subscriber_id, cst.service_plan_objid));

      UPDATE sa.ll_subscribers
      SET    current_ll_plan_id = c_current_ll_plan_id,
             last_modified_event = 'LL_PLAN_CHANGE'
      WHERE  objid = n_ll_subscriber_id;
    ELSIF UPPER(ll_subscriber_rec.request_type) = 'VERIFY'
    THEN
      --Get the subscriber id
      BEGIN
        SELECT objid
        INTO   n_ll_subscriber_id
        FROM   sa.LL_SUBSCRIBERS
        WHERE  current_min = cst.min
        AND    lid = ll_subscriber_rec.lid;
      EXCEPTION
        WHEN OTHERS THEN
        o_Error_Num := '1111';
        o_Error_Msg := 'ACTIVE SUBSCRIBER DETAILS NOT FOUND FOR LID:'|| ll_subscriber_rec.LID || ' AND MIN:'||cst.min ;
        RETURN;
      END;

      UPDATE LL_SUBSCRIBERS
      SET    LID                              =   ll_subscriber_rec.lid,
             QUALIFY_DATE                     =   ll_subscriber_rec.QUALIFY_DATE,
             QUALIFY_TYPE                     =   ll_subscriber_rec.QUALIFY_TYPE,
             QUALIFY_PROGRAMS                 =   ll_subscriber_rec.QUALIFY_PROGRAMS,
             CHANNEL_TYPE                     =   ll_subscriber_rec.CHANNEL_TYPE,
             LASTMODIFIED                     =   SYSDATE,
             LAST_MODIFIED_EVENT              =   'LL_VERIFY'
      WHERE  objid = n_ll_subscriber_id;
    END IF;

    IF UPPER(ll_subscriber_rec.request_type) <> 'DEENROLL'
    THEN
      --Get latest subscriber details to populate in history table
      OPEN get_ll_sub_dtls_cur  (n_ll_subscriber_id);
      FETCH get_ll_sub_dtls_cur INTO get_ll_sub_dtls_rec;
      CLOSE get_ll_sub_dtls_cur;

      --Populate subscribers hist table
      INSERT INTO sa.LL_SUBSCRIBERS_HIST (OBJID,
                                          LL_HIST2LL_SUBS,
                                          LID,
                                          ESN,
                                          MIN,
                                          USERNAME,
                                          SOURCESYSTEM,
                                          EVENT_INSERT,
                                          EVENT_UPDATE,
                                          EVENT_CODE,
                                          EVENT_NOTES,
                                          SP_OBJID,
                                          LL_PLAN_ID,
                                          SMP,
                                          CALL_TRANS_OBJID
                                         )
                                  VALUES (seq_ll_subscribers_hist.nextval,      --OBJID
                                          n_ll_subscriber_id,                   --LL_HIST2LL_SUBS
                                          get_ll_sub_dtls_rec.LID,              --LID
                                          get_ll_sub_dtls_rec.current_esn,      --ESN
                                          get_ll_sub_dtls_rec.current_min,      --MIN
                                          get_ll_sub_dtls_rec.full_name,        --USERNAME
                                          'VMBC',                               --SOURCESYSTEM
                                          SYSDATE,                              --EVENT_INSERT
                                          NULL,                                 --EVENT_UPDATE
                                          c_event_code,                         --EVENT_CODE
                                          ll_subscriber_rec.request_type,       --EVENT_NOTES
                                          cst.service_plan_objid,               --SP_OBJID
                                          c_current_ll_plan_id,                 --LL_PLAN_ID
                                          NULL,                                 --SMP
                                          NULL                                  --CALL_TRANS_OBJID
                                         );
    END IF;

    --Commit changes
    --COMMIT;
    o_ll_sub_id := n_ll_subscriber_id;
    o_Error_Num := '0';
    o_Error_msg := 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      --ROLLBACK;
      o_Error_Num := SQLCODE;
      o_Error_msg := SUBSTR(SQLERRM, 1, 2000);
  END ENROLL_LL_SUBSCRIBER;

  PROCEDURE DEENROLL_LL_SUBSCRIBER ( i_min                 IN      VARCHAR2,
                                     i_esn                 IN      VARCHAR2,
                                     i_source_system       IN      VARCHAR2 DEFAULT 'VMBC',
                                     i_deenroll_reason     IN      VARCHAR2 DEFAULT NULL,
                                     o_Error_Num           OUT     VARCHAR2,
                                     o_Error_Msg           OUT     VARCHAR2
                                   )
  IS
    CURSOR get_subscriber_dtl_cur (c_min  VARCHAR2)
    IS
      SELECT *
      FROM   sa.ll_subscribers
      WHERE  current_min = c_min
      AND    NVL(enrollment_status, 'ENROLLED') = 'ENROLLED';

    subscriber_dtl_rec    get_subscriber_dtl_cur%ROWTYPE;

    --Local variables
    cst sa.customer_type := sa.customer_type();
  BEGIN
    IF i_min IS NULL AND i_esn IS NULL
    THEN
      o_error_num := '1201';
      o_error_msg := 'BOTH MIN AND ESN CANNOT BE NULL. ANYONE OF THEM IS MUST';
      RETURN;
    END IF;

    IF i_min IS NULL
    THEN
      --Get the MIN if ESN is passed
      cst.esn := i_esn;
      cst.min := sa.customer_info.get_min (i_esn => cst.esn);

      IF cst.min IS NULL
      THEN
        o_error_num := '1202';
        o_error_msg := 'GIVEN ESN DOES NOT HAVE A VALID MIN';
        RETURN;
      END IF;
    ELSE
      cst.min := i_min;
    END IF;

    OPEN get_subscriber_dtl_cur (cst.min);
    FETCH get_subscriber_dtl_cur INTO subscriber_dtl_rec;

    IF get_subscriber_dtl_cur%NOTFOUND
    THEN
      CLOSE get_subscriber_dtl_cur;
      o_error_num := '1203';
      o_error_msg := 'NO ACTIVE ENROLLMENT FOR THE GIVEN ESN/MIN';
      RETURN;
    END IF;

    CLOSE get_subscriber_dtl_cur;

    --End date the current ENROLLMent
    BEGIN
      UPDATE sa.ll_subscribers
      SET    enrollment_status = 'DEENROLLED',
             projected_deenrollment = SYSDATE,
             deenroll_reason = i_deenroll_reason,
             lastmodified = SYSDATE,
             last_modified_event = 'LL_DEENROLLMENT'
      WHERE objid = subscriber_dtl_rec.objid;
    EXCEPTION
      WHEN OTHERS THEN
        o_error_num := '1204';
        o_error_msg := 'UNEXPECTED ERROR WHILE UPDATING THE EROLLMENT STATUS. Error-'||SUBSTR(SQLERRM, 1, 2000);
        RETURN;
    END;

    cst := cst.get_service_plan_attributes;

    --Populate subscribers hist table
    BEGIN
      INSERT INTO sa.LL_SUBSCRIBERS_HIST (OBJID,
                                          LL_HIST2LL_SUBS,
                                          LID,
                                          ESN,
                                          MIN,
                                          USERNAME,
                                          SOURCESYSTEM,
                                          EVENT_INSERT,
                                          EVENT_UPDATE,
                                          EVENT_CODE,
                                          EVENT_NOTES,
                                          SP_OBJID,
                                          LL_PLAN_ID,
                                          SMP,
                                          CALL_TRANS_OBJID
                                         )
                                  VALUES (seq_ll_subscribers_hist.nextval,      --OBJID
                                          subscriber_dtl_rec.objid,                   --LL_HIST2LL_SUBS
                                          subscriber_dtl_rec.LID,                --LID
                                          subscriber_dtl_rec.current_esn,                              --ESN
                                          subscriber_dtl_rec.current_min,                              --MIN
                                          subscriber_dtl_rec.full_name,          --USERNAME
                                          NVL(i_source_system, 'VMBC'),                               --SOURCESYSTEM
                                          SYSDATE,                              --EVENT_INSERT
                                          NULL,                                 --EVENT_UPDATE
                                          (select x_code_number
                                             from table_x_code_table
                                            where x_code_name='LL_DEENROLLMENT'),   --EVENT_CODE
                                          'LIFELINE Subscriber Deenrollment. '||i_deenroll_reason,  --EVENT_NOTES
                                          cst.service_plan_objid,                                 --SP_OBJID
                                          subscriber_dtl_rec.current_ll_plan_id,                                 --LL_PLAN_ID
                                          NULL,                                 --SMP
                                          NULL                                  --CALL_TRANS_OBJID
                                         );
    EXCEPTION
      WHEN OTHERS THEN
        o_error_num := '1205';
        o_error_msg := 'UNEXPECTED ERROR WHILE CREATING SUBSCRIBER HISTORY FOR DEENROLLMENT. Error-'||SUBSTR(SQLERRM, 1, 2000);
        RETURN;
    END;

    --Create a response to notify VMBC
    BEGIN
      INSERT INTO xsu_vmbc_response
                                  (
                                  responseto,
                                  requestid,
                                  lid,
                                  enrollrequest,
                                  errorcode,
                                  errormsg,
                                  activatedate,
                                  phoneesn,
                                  phonenumber,
                                  trackingnumber,
                                  ticketnumber,
                                  batchdate,
                                  data_source
                                  )
                           VALUES (
                                   'Deenroll',
                                   NULL,
                                   subscriber_dtl_rec.lid,
                                   'S',
                                   '0',
                                   'D00 Not enrolled',
                                   NULL,
                                   subscriber_dtl_rec.current_esn,
                                   subscriber_dtl_rec.current_min,
                                   NULL,
                                   NULL,
                                   SYSDATE,
                                   NVL(i_source_system, 'VMBC')
                                   );
    EXCEPTION
      WHEN OTHERS THEN
        o_error_num := '1206';
        o_error_msg := 'UNEXPECTED ERROR WHILE CREATING VMBC RESPONSE FOR DEENROLLMENT NOTIFICATION. Error-'||SUBSTR(SQLERRM, 1, 2000);
        RETURN;
    END;

    o_error_num := '0';
    o_error_msg := 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      o_Error_Num := SQLCODE;
      o_Error_msg := SUBSTR(SQLERRM, 1, 2000);
  END DEENROLL_LL_SUBSCRIBER;

  PROCEDURE CALCULATE_LL_DISCOUNT ( i_min                      IN    VARCHAR2,
                                    i_service_plan_id          IN    NUMBER,
                                    i_app_part_number          IN    VARCHAR2,
                                    i_app_part_class           IN    VARCHAR2,
                                    i_service_days             IN    NUMBER,
                                    o_discount_description     OUT   VARCHAR2,
                                    o_discount_amount          OUT   VARCHAR2,
                                    o_error_num                OUT   VARCHAR2,
                                    o_error_msg                OUT   VARCHAR2
                                  )
  IS
    --local variables
    d_sub_end_date                  DATE;
    c_esn                           VARCHAR2(30);
    no_of_queued_cards_allowed      NUMBER;
    n_min_serv_days_for_discount    NUMBER;
    c_discount_code                 VARCHAR2(30);
    n_discount_amount               NUMBER;
    queued_cards                    customer_queued_card_tab := customer_queued_card_tab( );
    cst sa.customer_type := sa.customer_type();
  BEGIN
    --Validate inputs
    IF   i_min IS NULL
    THEN
      o_error_Num := '1301';
      o_error_msg := 'MIN CANNOT BE NULL';
      RETURN;
    END IF;

    IF   i_service_plan_id IS NULL
    AND  i_app_part_number IS NULL
    THEN
      o_error_Num := '1302';
      o_error_msg := 'BOTH SERVICE PLAN ID AND SERVICE PLAN PART NUMBER CANNOT BE NULL. ANYONE OF THEM IS MANDATORY';
      RETURN;
    END IF;

    IF   i_service_days IS NULL
    THEN
      o_error_Num := '1303';
      o_error_msg := 'SERVICE DAYS CANNOT BE NULL';
      RETURN;
    END IF;

    /*--Check if the subscriber is active and enrolled for LL discount
    BEGIN
      SELECT projected_deenrollment
      INTO   d_sub_end_date
      FROM   SA.ll_subscribers
      WHERE  current_min = i_min;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_error_Num := '1304';
        o_error_msg := 'CANNOT FIND LIFELINE SUBSCRIPTION FOR MIN:'|| i_min;
        RETURN;
      WHEN OTHERS THEN
        o_error_num := SQLCODE;
        o_error_msg := 'UNEXPECTED ERROR WHILE CHECKING SUBSCRIBER ENROLLMENT. Error-'||SUBSTR(SQLERRM, 1, 2000);
        RETURN;
    END;

    IF TRUNC(d_sub_end_date) < TRUNC(SYSDATE)
    THEN
      o_error_num := '1305';
      o_error_msg := 'SUBSCRIBER ENROLLMENT IS NOT ACTIVE';
      RETURN;
    END IF;*/

    --Get ESN for the given MIN
    cst.esn := sa.customer_info.get_esn (i_min => i_min);

    IF i_service_plan_id IS NULL
    THEN
      --Get service plan id
      BEGIN
        SELECT service_plan_objid
        INTO   cst.service_plan_objid
        FROM   service_plan_feat_pivot_mv
        WHERE  plan_purchase_part_number = i_app_part_number;
      EXCEPTION
        WHEN OTHERS THEN
          o_error_num := '1306';
          o_error_msg := 'CANNOT FIND SERVICE PLAN ID FOR THE GIVEN APP PART NUMBER:'||i_app_part_number;
          RETURN;
      END;
    ELSE
      cst.service_plan_objid := i_service_plan_id;
    END IF;

    --Get the max no of queued cards allowed for the LL plan discount
    BEGIN
      SELECT lp.max_cards_in_q,
             lp.min_serv_days_for_discount,
             lp.discount_code,
             lp.discount_amount
      INTO   no_of_queued_cards_allowed,
             n_min_serv_days_for_discount,
             c_discount_code,
             n_discount_amount
      FROM   mtm_ll_plans2serv_plan lpsp,
             ll_plans lp,
             ll_subscribers llsub,
             mtm_ll_subs2ll_plans mlsp
      WHERE  lpsp.sp_objid = cst.service_plan_objid
      AND    lpsp.ll_plan_id = lp.plan_id
      AND    llsub.current_min = i_min
      AND    mlsp.ll_subs_objid = llsub.objid
      AND    mlsp.ll_plan_id = NVL(llsub.current_ll_plan_id, mlsp.ll_plan_id)
      AND    mlsp.ll_plan_id = lpsp.ll_plan_id
      AND    rownum = 1;
    EXCEPTION
    WHEN OTHERS THEN
      no_of_queued_cards_allowed    := NULL;
      n_min_serv_days_for_discount  := NULL;
      c_discount_code               := NULL;
      n_discount_amount             := NULL;
    END;

    IF no_of_queued_cards_allowed IS NULL
    THEN
      o_error_num := '1307';
      o_error_msg := 'MAX NO OF QUEUED CARDS TO AVAIL LL DISCOUNT IS NOT CONFIGURED FOR SERVICE PLAN ID:'
                      || cst.service_plan_objid;
      RETURN;
    END IF;

    IF n_min_serv_days_for_discount IS NULL
    THEN
      o_error_num := '1308';
      o_error_msg := 'MINIMUM SERVICE DAYS TO AVAIL LL DISCOUNT IS NOT CONFIGURED FOR SERVICE PLAN ID:'
                      || cst.service_plan_objid;
      RETURN;
    END IF;

    --Get ESN queued cards
    queued_cards := sa.customer_info.Get_esn_queued_cards ( i_esn => cst.esn );

    --Check if the no of queued cards are more than the no of cards allowed for enrolled LL plan
    IF queued_cards IS NOT NULL
    AND queued_cards.count >= no_of_queued_cards_allowed
    THEN
      o_error_num := '1309';
      o_error_msg := 'GIVEN MIN HAS MAX NO OF QUEUED CARDS THAT ARE ALLOWED FOR LIFELINE DISCOUNT ELIGIBILITY';
      RETURN;
    END IF;

    IF i_service_days < n_min_serv_days_for_discount
    THEN
      o_error_num := '1310';
      o_error_msg := 'GIVEN MIN HAS LESS SERVICE DAYS THAN THE REQUIRED DAYS FOR LIFELINE DISCOUNT ELIGIBILITY';
      RETURN;
    END IF;

    --Get the base service plan price
    BEGIN
      SELECT CUSTOMER_PRICE
      INTO   cst.service_plan_price
      FROM   x_service_plan
      WHERE  objid = cst.service_plan_objid;
    EXCEPTION
      WHEN OTHERS THEN
        o_error_num := '1311';
        o_error_msg := 'COULD NOT FETCH THE PRICE OF SERVICE PLAN:'||cst.service_plan_objid;
        RETURN;
    END;

    IF cst.service_plan_price < n_discount_amount
    THEN
      o_discount_amount := cst.service_plan_price;
    ELSE
      o_discount_amount := n_discount_amount;
    END IF;

    o_discount_description := c_discount_code;
    o_error_num := '0';
    o_error_msg := 'SUCCESS';
  EXCEPTION
  WHEN OTHERS THEN
    o_error_num := SQLCODE;
    o_error_msg := 'Unexpected error while executing CALCULATE_LL_DISCOUNT. Error-'||SUBSTR(SQLERRM, 1, 2000);
  END CALCULATE_LL_DISCOUNT;

  PROCEDURE LL_REDEMPTION_TRANSACTION ( i_ct_objid    IN  VARCHAR2,
                                        i_esn         IN  VARCHAR2,
                                        i_min         IN  VARCHAR2,
                                        o_error_num   OUT VARCHAR2,
                                        o_error_msg   OUT VARCHAR2
                                      )
  IS
  /*****************************************************************
  * Purpose : Procedure to track service type changes during redemption
  * 	      transactions  for lifeline subscribers.
  *           Create history recrod and VMBC outbound records
  *
  * Platform : Oracle 8.0.6 and newer versions.
  * Created by : Maulik Dave (mdave)
  * Date : 06/26/2017
  * History
  * REVISIONS VERSION DATE WHO PURPOSE
  * ------------------------------------------------------------- */
    CURSOR ll_sub_cur(ip_min VARCHAR2)
      IS
        SELECT *
        FROM   sa.ll_subscribers
        WHERE  current_min = ip_min
        AND   NVL(enrollment_status, 'ENROLLED') = 'ENROLLED'
        AND TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);

    ll_sub_rec              ll_sub_cur%ROWTYPE;
    l_current_serv_type     sa.X_Serviceplanfeaturevalue_Def.value_name%TYPE;
    l_smp                   sa.table_x_red_card.x_smp%type;
    l_sp_objid              sa.mtm_ll_plans2serv_plan.sp_objid%type;
    l_call_trans_objid      sa.table_x_call_trans.objid%type;
    l_prev_cal_trans_objid  sa.table_x_call_trans.objid%type;
    l_disc_code_tab         sa.discount_code_tab := sa.discount_code_tab();
    l_pr_disc_code_tab      sa.discount_code_tab := sa.discount_code_tab();
    l_disc_code             sa.ll_plans.discount_code%type;
    l_pr_disc_code          sa.ll_plans.discount_code%type;
    l_fea_Value             sa.X_Serviceplanfeaturevalue_Def.value_name%type;
    l_pr_fea_Value          sa.X_Serviceplanfeaturevalue_Def.value_name%type;
    cst sa.customer_type := sa.customer_type();
  BEGIN
    IF i_min IS NULL
    THEN
      o_error_num := '100';
      o_error_msg := 'LL_REDEMPTION_TRANSACTION - NULL INPUT MIN FROM IGATE_IN3';
      RETURN;
    END IF;

    IF i_esn IS NULL
    THEN
      o_error_num := '130';
      o_error_msg := 'LL_REDEMPTION_TRANSACTION - NULL INPUT ESN FROM IGATE_IN3';
      RETURN;
    END IF;

    IF i_ct_objid IS NULL
    THEN
      o_error_num := '140';
      o_error_msg := 'LL_REDEMPTION_TRANSACTION - NULL CALL_TRANS_ID FROM IGATE_IN3';
      RETURN;
    END IF;

	cst.esn := i_esn;
	cst := cst.get_service_plan_attributes;

    --most recent redemption is i_ct_objid
    -- get second most recent redemption
    BEGIN
      SELECT objid
      INTO   l_prev_cal_trans_objid
      FROM
             (
             SELECT ct.objid,DENSE_RANK() OVER (ORDER BY X_TRANSACT_DATE DESC) rank1
             FROM ig_transaction ig, table_task t, sa.table_x_call_trans ct
             WHERE esn = i_esn
             AND ct.x_action_type = '6'
             AND t.TASK_ID  = ig.ACTION_ITEM_ID
             AND ct.objid   = t.x_task2x_call_trans
             )
      WHERE  rank1 = 2;
    EXCEPTION
      WHEN no_data_found THEN
        l_prev_cal_trans_objid := NULL;
      WHEN OTHERS THEN
        o_error_num := SQLCODE;
        o_error_msg := '150 - LL_REDEMPTION_TRANSACTION - Unexpected error while fetching previous call trans ID -'|| SUBSTR(SQLERRM, 1, 1000);
        RETURN;
    END;

    -- Get discount code (list of codes) for latest redemption
    BEGIN
        SELECT DISCOUNT_CODE_LIST, rc.X_SMP
        INTO   l_disc_code_tab, l_smp
        FROM   sa.x_part_inst_ext piext,
               sa.table_x_red_card rc
        WHERE  piext.SMP = rc.X_SMP
        AND    rc.RED_CARD2CALL_TRANS = i_ct_objid;
    EXCEPTION
    WHEN OTHERS THEN
         o_error_num := '170';
         o_error_msg := '170 - LL_REDEMPTION_TRANSACTION - no discount code present for the call trans ID - '||i_ct_objid;
         RETURN;
    END;
    -- if DISCOUNT_CODE_LIST is null, return.
	IF l_disc_code_tab IS NULL THEN
		o_error_num := '180';
        o_error_msg := '180 - LL_REDEMPTION_TRANSACTION - no discount codes present for the call trans ID - '||i_ct_objid;
      RETURN;
	ENd IF;

	-- Get LL discount code's service type from the list fetched in previous block
    BEGIN
      FOR i in 1..l_disc_code_tab.count
      LOOP
        BEGIN
          SELECT DISTINCT lp.discount_code,  spfmv.fea_value, spfmv.sp_objid
          INTO l_disc_code, l_fea_Value, l_sp_objid
          FROM
          sa.ADFCRM_SERV_PLAN_FEAT_MATVIEW spfmv,
          sa.mtm_ll_plans2serv_plan ll2sp,
          sa.ll_plans lp
          WHERE ll2sp.sp_objid = spfmv.sp_objid
          AND spfmv.fea_name in ('LL_SERV_TYPE','LL_TRIBAL_SERV_TYPE')
          AND  lp.plan_id = ll2sp.ll_plan_id
		  AND  spfmv.sp_objid = cst.service_plan_objid
          AND lp.discount_code =  l_disc_code_tab(i).discount_code;
        EXCEPTION
          WHEN no_data_found THEN
            NULL; -- to continue the loop
        END;

        IF l_disc_code IS NOT NULL THEN
			EXIT; -- no need to loop once LL discount code is available ( assumption : active subscriber is associated with only one LL service type, hence only one discount code)
		END IF;
		END LOOP;
    EXCEPTION
      WHEN too_many_rows THEN
        o_error_num := '195';
        o_error_msg := 'LL_REDEMPTION_TRANSACTION - more than one LL discount code present for the call trans ID - '||i_ct_objid;
      RETURN;
      WHEN OTHERS THEN
        o_error_num := SQLCODE;
        o_error_msg := '200 - LL_REDEMPTION_TRANSACTION - upexpected error occured -'|| SUBSTR(SQLERRM, 1, 2000);
      RETURN;
    END;

	IF l_disc_code IS NULL OR  l_fea_Value IS NULL THEN
		RETURN; -- return if no feature value to compare
	END IF;

    -- If prior redemption exists, get the discount code to compare to the most recent redemption
    IF l_prev_cal_trans_objid IS NOT NULL THEN
      BEGIN
        SELECT DISCOUNT_CODE_LIST
        INTO   l_pr_disc_code_tab
        FROM   sa.x_part_inst_ext piext,
               sa.table_x_red_card rc
        WHERE  piext.SMP = rc.X_SMP
        AND    rc.RED_CARD2CALL_TRANS = l_prev_cal_trans_objid;
      EXCEPTION
        WHEN OTHERS THEN
          o_error_num := '210';
          o_error_msg := 'LL_REDEMPTION_TRANSACTION - no discount code present for the previous call trans ID - '||l_prev_cal_trans_objid;
          RETURN;
      END;

		IF l_pr_disc_code_tab IS NULL THEN
			o_error_num := '215';
			o_error_msg := '215 - LL_REDEMPTION_TRANSACTION - no discount codes present for the previous call trans ID - '||l_prev_cal_trans_objid;
		  RETURN;
		ENd IF;

      -- Get LL discount code from the list fetched in previous block
      BEGIN
        FOR i in 1..l_pr_disc_code_tab.count
        LOOP
          BEGIN
            SELECT DISTINCT lp.discount_code, spfmv.FEA_VALUE
            INTO   l_pr_disc_code , l_pr_fea_Value
            FROM   sa.ADFCRM_SERV_PLAN_FEAT_MATVIEW spfmv,
                   sa.mtm_ll_plans2serv_plan ll2sp,
                   sa.ll_plans lp
            WHERE  ll2sp.sp_objid = spfmv.sp_objid
            AND    spfmv.fea_name in ('LL_SERV_TYPE','LL_TRIBAL_SERV_TYPE')
            AND    lp.plan_id = ll2sp.ll_plan_id
            AND    lp.discount_code =  l_pr_disc_code_tab(i).discount_code;
          EXCEPTION
            WHEN no_data_found THEN
              NULL; -- continue the loop
          END;

          IF l_pr_disc_code IS NOT NULL THEN
			EXIT; -- no need to loop once LL discount code is available ( assumption : active subscriber is associated with only one LL service type, hence only one discount code)
          END IF;
        END LOOP;
      EXCEPTION
        WHEN too_many_rows THEN
          o_error_num := '230';
          o_error_msg := 'LL_REDEMPTION_TRANSACTION - more than one discount code present for the previous call trans ID - '||l_prev_cal_trans_objid;
          RETURN;
        WHEN OTHERS THEN
          o_error_num := SQLCODE;
          o_error_msg := '240 - LL_REDEMPTION_TRANSACTION - upexpected error occured -'|| SUBSTR(SQLERRM, 1, 2000);
          RETURN;
      END;

		IF l_pr_disc_code IS NULL THEN
			o_error_num := '245';
			o_error_msg := '245 - LL_REDEMPTION_TRANSACTION - no LL discount code present for the previous call trans ID - '||l_prev_cal_trans_objid;
		  RETURN;
		END IF;

		-- Open cursor to fetch curren record
		 OPEN ll_sub_cur(i_min);
		  FETCH ll_sub_cur INTO ll_sub_rec;

		  IF ll_sub_cur%NOTFOUND THEN
			CLOSE ll_sub_cur;
			RETURN;
		  END IF;

	  -- compare LL service type of recent rede
		IF l_pr_fea_Value IS NOT NULL THEN

			IF UPPER(l_fea_Value) <> UPPER(l_pr_fea_Value) THEN
						BEGIN
							INSERT INTO sa.XSU_VMBC_RESPONSE (RESPONSETO,
                                          REQUESTID,
                                          LID,
                                          ENROLLREQUEST,
                                          ERRORCODE,
                                          ERRORMSG,
                                          ACTIVATEDATE,
                                          PHONEESN,
                                          PHONENUMBER,
                                          TRACKINGNUMBER,
                                          TICKETNUMBER,
                                          BATCHDATE,
                                          DATA_SOURCE
                                         )
                                  VALUES ('PROGRAMCHANGE',                   -- responseto
                                          null,                                --requestid
                                          ll_sub_rec.LID,                      -- LID
                                          'S',                                  -- enroll_Request
                                          '0',                                  -- error_code
                                          'NULL',                             --error_msg
                                          ll_sub_rec.CURRENT_ENROLLMENT_DATE,  -- activate_date
                                          ll_sub_rec.current_esn,               -- CURRENT_ESN
                                          ll_sub_rec.current_min,               -- CURRENT_MIN
                                          null,                                 -- tracking number
                                          null,                                 -- ticket_number
                                          to_date(sysdate,'DD-MON-RR'),         -- sysdate as batch date
                                          null
                                         );
						EXCEPTION
							WHEN OTHERS THEN
							  IF ll_sub_cur%ISOPEN THEN
									CLOSE ll_sub_cur;
								END IF;
							  o_error_num := SQLCODE;
							  o_error_msg := '250 - Unexpected error while inserting XSU VMBC RESPONSE record. Error-'|| SUBSTR(SQLERRM, 1, 2000);
						END;


			END IF;

			--- for every redemption, update ll_subscribers table and Populate subscribers hist table
						BEGIN
						INSERT INTO sa.LL_SUBSCRIBERS_HIST (OBJID,
															LL_HIST2LL_SUBS,
															LID,
															ESN,
															MIN,
															USERNAME,
															SOURCESYSTEM,
															EVENT_INSERT,
															EVENT_UPDATE,
															EVENT_CODE,
															EVENT_NOTES,
															SP_OBJID,
															LL_PLAN_ID,
															SMP,
															CALL_TRANS_OBJID
														   )
													VALUES (seq_ll_subscribers_hist.nextval,     --OBJID
															ll_sub_rec.objid,                   --LL_HIST2LL_SUBS
															ll_sub_rec.LID,                    --LID
															ll_sub_rec.current_esn,            --ESN
															ll_sub_rec.current_min,            --MIN
															ll_sub_rec.full_name,              --USERNAME
															'TAS',                             --SOURCESYSTEM
															SYSDATE,                           --EVENT_INSERT
															NULL,                              --EVENT_UPDATE
															(select x_code_number
															   from sa.table_x_code_table
															  where x_code_name='LL_REDEMPTION'), --EVENT_CODE
															'LIFELINE Subscriber Redemption',     --EVENT_NOTES
															cst.service_plan_objid,               --SP_OBJID
															ll_sub_rec.current_ll_plan_id,         --LL_PLAN_ID
															l_smp,                                 --SMP
															l_prev_cal_trans_objid                --CALL_TRANS_OBJID
														   );
						EXCEPTION
						WHEN OTHERS THEN
								IF ll_sub_cur%ISOPEN THEN
									CLOSE ll_sub_cur;
								END IF;
							  o_error_num := SQLCODE;
							  o_error_msg := '255 - Unexpected error while inserting LL history record. Error-'|| SUBSTR(SQLERRM, 1, 2000);
						END;

				IF ll_sub_cur%ISOPEN THEN
					CLOSE ll_sub_cur;
				END IF;
			  -- No change in LL Service plan type, do nothing and return to calling IGATE_IN3
			  RETURN;

		END IF;
	  -- end comparison for previous redemption

	-- For the first redemption, get the plan from plan table
	ELSIF l_prev_cal_trans_objid IS NULL THEN

		  -- GET current service type from LL tables
		  BEGIN
			SELECT DISTINCT spfmv.fea_value INTO l_current_serv_type
			FROM   sa.ADFCRM_SERV_PLAN_FEAT_MATVIEW spfmv,
				   sa.mtm_ll_plans2serv_plan ll2sp,
				   sa.ll_plans lp
			WHERE  ll2sp.sp_objid = spfmv.sp_objid
			AND    spfmv.fea_name in ('LL_SERV_TYPE','LL_TRIBAL_SERV_TYPE')
			AND    lp.plan_id = ll2sp.ll_plan_id
			AND    lp.plan_id = ll_sub_rec.CURRENT_LL_PLAN_ID;
		  EXCEPTION
			WHEN OTHERS THEN
				IF ll_sub_cur%ISOPEN THEN
					CLOSE ll_sub_cur;
				END IF;
			  -- if No current LL service type, return
			  o_error_num := '245';
			  o_error_msg := '245 - LL_REDEMPTION_TRANSACTION - Could not get current LL service type';
			  RETURN;
		  END;

		  IF l_current_serv_type IS NULL THEN
			RETURN; -- can not compare change in service type, so return without any update
		  END IF;
		  --
			IF UPPER(l_fea_Value) <> UPPER(l_current_serv_type) THEN
				BEGIN
					INSERT INTO sa.XSU_VMBC_RESPONSE (RESPONSETO,
												  REQUESTID,
												  LID,
												  ENROLLREQUEST,
												  ERRORCODE,
												  ERRORMSG,
												  ACTIVATEDATE,
												  PHONEESN,
												  PHONENUMBER,
												  TRACKINGNUMBER,
												  TICKETNUMBER,
												  BATCHDATE,
												  DATA_SOURCE
												 )
										  VALUES ('PROGRAMCHANGE',                   -- responseto
												  null,                                --requestid
												  ll_sub_rec.LID,                      -- LID
												  'S',                                  -- enroll_Request
												  '0',                                  -- error_code
												  'NULL',                             --error_msg
												  ll_sub_rec.CURRENT_ENROLLMENT_DATE,  -- activate_date
												  ll_sub_rec.current_esn,               -- CURRENT_ESN
												  ll_sub_rec.current_min,               -- CURRENT_MIN
												  null,                                 -- tracking number
												  null,                                 -- ticket_number
												  to_date(sysdate,'DD-MON-RR'),         -- sysdate as batch date
												  null
												 );
			  EXCEPTION
				WHEN OTHERS THEN
				  IF ll_sub_cur%ISOPEN THEN
						CLOSE ll_sub_cur;
					END IF;
				  o_error_num := SQLCODE;
				  o_error_msg := '260 - Unexpected error while inserting XSU VMBC RESPONSE record. Error-'|| SUBSTR(SQLERRM, 1, 2000);
			  END;


			END IF;


			  -- for each redemtion, Populate subscribers hist table
			  BEGIN
				INSERT INTO sa.LL_SUBSCRIBERS_HIST (OBJID,
													LL_HIST2LL_SUBS,
													LID,
													ESN,
													MIN,
													USERNAME,
													SOURCESYSTEM,
													EVENT_INSERT,
													EVENT_UPDATE,
													EVENT_CODE,
													EVENT_NOTES,
													SP_OBJID,
													LL_PLAN_ID,
													SMP,
													CALL_TRANS_OBJID
												   )
											VALUES (seq_ll_subscribers_hist.nextval,     --OBJID
													ll_sub_rec.objid,                   --LL_HIST2LL_SUBS
													ll_sub_rec.LID,                    --LID
													ll_sub_rec.current_esn,            --ESN
													ll_sub_rec.current_min,            --MIN
													ll_sub_rec.full_name,              --USERNAME
													'TAS',                             --SOURCESYSTEM
													SYSDATE,                           --EVENT_INSERT
													NULL,                              --EVENT_UPDATE
													(select x_code_number
													   from sa.table_x_code_table
													  where x_code_name='LL_REDEMPTION'), --EVENT_CODE
													'LIFELINE Subscriber Redemption',     --EVENT_NOTES
													cst.service_plan_objid,               --SP_OBJID
													ll_sub_rec.current_ll_plan_id,         --LL_PLAN_ID
													l_smp,                                 --SMP
													l_prev_cal_trans_objid                --CALL_TRANS_OBJID
												   );
			  EXCEPTION
			  WHEN OTHERS THEN
					IF ll_sub_cur%ISOPEN THEN
						CLOSE ll_sub_cur;
					END IF;
				  o_error_num := SQLCODE;
				  o_error_msg := '265 - Unexpected error while inserting LL history record. Error-'|| SUBSTR(SQLERRM, 1, 2000);
			  END;


				IF ll_sub_cur%ISOPEN THEN
						CLOSE ll_sub_cur;
					END IF;
			  -- No change in LL Service plan type, do nothing and return to calling IGATE_IN3
			  RETURN;

	END IF;
    -- commit chages
    COMMIT;
       --close open cursors
		IF ll_sub_cur%ISOPEN THEN
			CLOSE ll_sub_cur;
		END IF;
    o_error_num := NULL;
    o_error_msg := NULL;

    -- return to calling  proc - IGATE_IN3
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
		IF ll_sub_cur%ISOPEN THEN
			CLOSE ll_sub_cur;
		END IF;
      ROLLBACK;
      o_error_num := SQLCODE;
      o_error_msg := '270- Unexpected error while exceuting PROC LL_REDEMPTION_TRANSACTION. Error-'|| SUBSTR(SQLERRM, 1, 2000);
      RETURN;
  END LL_REDEMPTION_TRANSACTION;

  PROCEDURE LL_MINC_TRANSACTION ( i_ig_transaction_id    IN  NUMBER,
                                  o_error_num 	    	OUT VARCHAR2,
                                  o_error_msg 		    OUT VARCHAR2
                                )
  IS
   /*****************************************************************
   * Purpose : Proc to track Min changes for lifeline subscribers
   * 			 create history recrod and VMBC outbound records
   *
   * Platform : Oracle 8.0.6 and newer versions.
   * Created by : Maulik Dave (mdave)
   * Date : 06/26/2017
   * History
   * REVISIONS VERSION DATE WHO PURPOSE
   * ------------------------------------------------------------- */
    CURSOR ll_sub_cur (ip_old_min VARCHAR2)
    IS
      SELECT *
      FROM   sa.ll_subscribers
      WHERE  current_min = ip_old_min
      AND    NVL(enrollment_status, 'ENROLLED') = 'ENROLLED'
      AND    TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);

    ll_sub_rec   ll_sub_cur%ROWTYPE;
    l_smp        sa.table_x_red_card.x_smp%TYPE;
    cst          sa.customer_type := sa.customer_type();
	ig           sa.ig_transaction_type := sa.ig_transaction_type();
    ct           sa.call_trans_type     := sa.call_trans_type();
	BEGIN
   /*  IF i_old_min IS NULL
    THEN
      o_error_num := '100';
      o_error_msg := 'LL_MINC_TRANSACTION - NULL INPUT OLD MIN FROM IGATE_IN3';
      RETURN;
    END IF;

    IF i_msid IS NULL
    THEN
      o_error_num := '110';
      o_error_msg := 'LL_MINC_TRANSACTION - NULL INPUT MIN FROM IGATE_IN3';
      RETURN;
    END IF; */
	IF i_ig_transaction_id IS NULL
    THEN
      o_error_num := '120';
      o_error_msg := 'LL_MINC_TRANSACTION - NULL INPUT i_ig_transaction_id FROM IGATE_IN3';
      RETURN;
    END IF;

	-- get IG transaction details
    ig := ig_transaction_type ( i_transaction_id   => i_ig_transaction_id );
	-- get the call trans details
    ct := call_trans_type ( i_call_trans_objid => ig.call_trans_objid );

	cst.esn := ig.esn;
	cst := cst.get_service_plan_attributes;

  OPEN ll_sub_cur (ig.old_min);
    FETCH ll_sub_cur INTO ll_sub_rec;

    IF ll_sub_cur%NOTFOUND
    THEN
	  CLOSE ll_sub_cur;
      o_error_num := '130';
      o_error_msg := 'LL_MINC_TRANSACTION - NO ACTIVE ENROLMENT FOR THE GIVEN OLD MIN';
      RETURN;
    END IF;

    --Update changed min to subscribers table.

	BEGIN
		UPDATE sa.ll_subscribers
		SET    current_min = ig.msid,
			   lastmodified = SYSDATE,
         last_modified_event = 'LL_MIN_CHANGE'
		WHERE  objid = ll_sub_rec.objid;
    EXCEPTION
		WHEN OTHERS THEN
			IF ll_sub_cur%ISOPEN THEN
				CLOSE ll_sub_cur;
			END IF;
			ROLLBACK;
		o_error_num := '135';
		o_error_msg := 'LL_MINC_TRANSACTION - COULD NOT UPDATE NEW MIN, RETURNING TO IGATE_IN3';
      RETURN;
	END;


    -- get SMP value for history table insert
    BEGIN
       SELECT rc.X_SMP
       INTO   l_smp
       FROM   sa.x_part_inst_ext piext,
              sa.table_x_red_card rc
       WHERE  piext.SMP = rc.X_SMP
       AND    rc.RED_CARD2CALL_TRANS = ig.call_trans_objid;
    EXCEPTION
      WHEN OTHERS THEN
        l_smp := NULL;
    END;

    --Populate subscribers history table with prior MIN details
    BEGIN
      INSERT INTO sa.LL_SUBSCRIBERS_HIST (OBJID,
                                          LL_HIST2LL_SUBS,
                                          LID,
                                          ESN,
                                          MIN,
                                          USERNAME,
                                          SOURCESYSTEM,
                                          EVENT_INSERT,
                                          EVENT_UPDATE,
                                          EVENT_CODE,
                                          EVENT_NOTES,
                                          SP_OBJID,
                                          LL_PLAN_ID,
                                          SMP,
                                          CALL_TRANS_OBJID
                                         )
                                  VALUES (seq_ll_subscribers_hist.nextval,    --OBJID
                                          ll_sub_rec.objid,                   --LL_HIST2LL_SUBS
                                          ll_sub_rec.LID,                     --LID
                                          ll_sub_rec.current_esn,             --ESN
                                          ll_sub_rec.current_min,             --MIN
                                          ll_sub_rec.full_name,               --USERNAME
                                          NULL,                               --SOURCESYSTEM
                                          SYSDATE,                            --EVENT_INSERT
                                          NULL,                               --EVENT_UPDATE
                                          (SELECT x_code_number
                                            FROM sa.table_x_code_table
                                            WHERE x_code_name='LL_MIN_CHANGE'),   --EVENT_CODE
                                          (ct.action_text||'-'||ct.reason),       --EVENT_NOTES
                                          cst.service_plan_objid,                 --SP_OBJID
                                          ll_sub_rec.current_ll_plan_id,          --LL_PLAN_ID
                                          l_smp,                                   --SMP
                                          ig.call_trans_objid                     --CALL_TRANS_OBJID
                                         );
    EXCEPTION
      WHEN OTHERS THEN
		ROLLBACK;
        o_error_num := SQLCODE;
        o_error_msg := '140-LL_MINC_TRANSACTION - Unexpected error while inserting LL history record. Error-'|| SUBSTR(SQLERRM, 1, 2000);
    END;

    -- xsu_vmbc_response record
    BEGIN
      INSERT INTO sa.XSU_VMBC_RESPONSE (RESPONSETO,
                                        REQUESTID,
                                        LID,
                                        ENROLLREQUEST,
                                        ERRORCODE,
                                        ERRORMSG,
                                        ACTIVATEDATE,
                                        PHONEESN,
                                        PHONENUMBER,
                                        TRACKINGNUMBER,
                                        TICKETNUMBER,
                                        BATCHDATE,
                                        DATA_SOURCE
                                       )
                                VALUES ('LL_MIN_CHANGE',              -- responseto
                                        null,                          --requestid
                                        ll_sub_rec.LID,                -- LID
                                        'S',                           -- enroll_Request
                                        '0',                           -- error_code
                                        'LL_MIN_CHANGE',                --error_msg
                                        ll_sub_rec.CURRENT_ENROLLMENT_DATE, -- activate_date
                                        ll_sub_rec.current_esn,         -- CURRENT_ESN
                                        ig.msid,                         -- CURRENT_MIN
                                        null,                           -- tracking number
                                        null,                           -- ticket_number
                                        to_date(sysdate,'DD-MON-RR'),   -- sysdate as batch date
                                        ct.sourcesystem
                                       );
    EXCEPTION
      WHEN OTHERS THEN
		ROLLBACK;
        o_error_num := SQLCODE;
        o_error_msg := '150-LL_MINC_TRANSACTION - Unexpected error while inserting XSU VMBC RESPONSE record. Error-'|| SUBSTR(SQLERRM, 1, 2000);
		RETURN;
    END;
    COMMIT;

    --Close open cursor
    CLOSE ll_sub_cur;

    o_error_num := NULL;
    o_error_msg := NULL;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
		IF ll_sub_cur%ISOPEN THEN
			CLOSE ll_sub_cur;
		ENd IF;
      ROLLBACK;
      o_error_num := SQLCODE;
      o_error_msg := '160 - Unexpected error while exceuting PROC LL_MIN_TRANSACTION. Error-'|| SUBSTR(SQLERRM, 1, 2000);
    RETURN;
  END	LL_MINC_TRANSACTION;

  PROCEDURE LL_ESN_CHANGE_TRANSACTION ( i_ig_transaction_id  IN  NUMBER,
                                        o_error_num 	    OUT VARCHAR2,
                                        o_error_msg 		 OUT VARCHAR2
                                      )
  IS
   /*****************************************************************
   * Purpose : Proc to track ESN changes for lifeline subscribers
   * 			 create history recrod
   *
   * Platform : Oracle 8.0.6 and newer versions.
   * Created by : Maulik Dave (mdave)
   * Date : 06/26/2017
   * History
   * REVISIONS VERSION DATE WHO PURPOSE
   * ------------------------------------------------------------- */
    CURSOR ll_sub_cur (ip_msid VARCHAR2)
        IS
          SELECT *
          FROM   sa.ll_subscribers
          WHERE  current_min = ip_msid
          AND    NVL(enrollment_status, 'ENROLLED') = 'ENROLLED'
          AND TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);

    ll_sub_rec   ll_sub_cur%ROWTYPE;
    l_smp        sa.table_x_red_card.x_smp%TYPE;
    l_new_esn    sa.table_part_inst.part_serial_no%TYPE;
    cst          sa.customer_type := sa.customer_type();
	ig           sa.ig_transaction_type := sa.ig_transaction_type();
	ct           sa.call_trans_type     := sa.call_trans_type();
    BEGIN
    IF i_ig_transaction_id IS NULL
    THEN
      o_error_num := '110';
      o_error_msg := 'LL_ESN_CHANGE_TRANSACTION - NULL INPUT IG TRANSACTION ID FROM IGATE_IN3';
      RETURN;
    END IF;

	-- get IG transaction details
	ig := ig_transaction_type ( i_transaction_id   => i_ig_transaction_id );
	-- get the call trans details
    ct := call_trans_type( i_call_trans_objid => ig.call_trans_objid );

	cst.esn := ig.esn;
	cst := cst.get_service_plan_attributes;

    OPEN ll_sub_cur (ig.msid);
    FETCH ll_sub_cur INTO ll_sub_rec;

    IF ll_sub_cur%NOTFOUND
    THEN
	  CLOSE ll_sub_cur;
      o_error_num := '130';
      o_error_msg := 'LL_ESN_CHANGE_TRANSACTION - NO ACTIVE ENROLMENT FOR THE GIVEN MIN';
      RETURN;
    END IF;

    -- fetch new ESN for the given MIN
    BEGIN
       SELECT piesn.part_serial_no
       INTO   l_new_esn
       FROM   table_part_inst piesn, table_part_inst pimin
       WHERE  pimin.part_Serial_no = ig.msid
       AND    piesn.objid = pimin.PART_TO_ESN2PART_INST
       AND    pimin.x_domain = 'LINES'
       AND    piesn.x_domain = 'PHONES';
    EXCEPTION
      WHEN OTHERS THEN
        o_error_num := '140';
        o_error_msg := 'LL_ESN_CHANGE_TRANSACTION - NO ESN RETURNED FOR THE GIVEN MIN';
        RETURN;
    END;

    IF l_new_esn IS NOT NULL
    THEN
      --Update changed min to subscribers table.
      -- This action would automatically fire a trigger on ll_subscribers table to send chnaged min details to BRM
      BEGIN
		  UPDATE sa.ll_subscribers
		  SET    current_esn = l_new_esn,
             lastmodified = SYSDATE,
             last_modified_event = 'LL_ESN_CHANGE'
		  WHERE  objid = ll_sub_rec.objid;
      EXCEPTION
		WHEN OTHERS THEN
			IF ll_sub_cur%ISOPEN THEN
				CLOSE ll_sub_cur;
			END IF;
			ROLLBACK;
		o_error_num := '145';
        o_error_msg := 'LL_ESN_CHANGE_TRANSACTION - COULD NOT UPDATE ESN FOR GIVEN MIN, RETURNING TO IGATE_IN3';
        RETURN;
	  END;

          --Populate subscribers hist table with prior ESN record.
      BEGIN
        INSERT INTO sa.LL_SUBSCRIBERS_HIST (OBJID,
                                            LL_HIST2LL_SUBS,
                                            LID,
                                            ESN,
                                            MIN,
                                            USERNAME,
                                            SOURCESYSTEM,
                                            EVENT_INSERT,
                                            EVENT_UPDATE,
                                            EVENT_CODE,
                                            EVENT_NOTES,
                                            SP_OBJID,
                                            LL_PLAN_ID,
                                            SMP,
                                            CALL_TRANS_OBJID
                                           )
                                    VALUES (seq_ll_subscribers_hist.nextval,   		 --OBJID
                                            ll_sub_rec.objid,                        --LL_HIST2LL_SUBS
                                            ll_sub_rec.LID,                    		 --LID
                                            ll_sub_rec.current_esn,           		 --ESN
                                            ll_sub_rec.current_min,           		 --MIN
                                            ll_sub_rec.full_name,             		 --USERNAME
                                            ct.sourcesystem,                 		 --SOURCESYSTEM
                                            SYSDATE,                          		 --EVENT_INSERT
                                            SYSDATE, 								 --EVENT_UPDATE
                                            (SELECT x_code_number
                                              FROM sa.table_x_code_table
                                              WHERE x_code_name='LL_ESN_CHANGE'),  	 --EVENT_CODE
                                            (ct.action_text||'-'||ct.reason),   	 --EVENT_NOTES
                                            cst.service_plan_objid,                	 --SP_OBJID
                                            ll_sub_rec.current_ll_plan_id,        	 --LL_PLAN_ID
                                            NULL,                                  	 --SMP
                                            ig.call_trans_objid                    	 --CALL_TRANS_OBJID
                                           );
      EXCEPTION
        WHEN OTHERS THEN
		  ROLLBACK;
          o_error_num := SQLCODE;
          o_error_msg := '140 -LL_ESN_CHANGE_TRANSACTION - Unexpected error while inserting LL history record. Error-'|| SUBSTR(SQLERRM, 1, 2000);
      END;
    END IF;
    --COMMIT changes
	COMMIT;
    --Close open cursor
    CLOSE ll_sub_cur;
    o_error_num := NULL;
    o_error_msg := NULL;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
		IF ll_sub_cur%ISOPEN THEN
			CLOSE ll_sub_cur;
		END IF;
      ROLLBACK;
      o_error_num := SQLCODE;
      o_error_msg := '160 - Unexpected error while exceuting PROC LL_ESN_CHANGE_TRANSACTION. Error-'|| SUBSTR(SQLERRM, 1, 2000);
      RETURN;
  END LL_ESN_CHANGE_TRANSACTION;

  PROCEDURE PROCESS_LL_TRANSFER ( i_old_min       IN    VARCHAR2,
                                  i_old_esn       IN    VARCHAR2,
                                  i_lid           IN    VARCHAR2,
                                  i_source_system IN    VARCHAR2,
                                  i_agent_name    IN    VARCHAR2,
                                  i_new_min       IN    VARCHAR2,
                                  i_new_esn       IN    VARCHAR2,
                                  o_error_num     OUT   VARCHAR2,
                                  o_error_msg     OUT   VARCHAR2
                                  )
  IS
    CURSOR get_ll_sub_dtls_cur
    IS
      SELECT *
      FROM   sa.ll_subscribers
      WHERE  current_min = i_old_min
      AND    current_esn = i_old_esn
      AND    lid = NVL(i_lid, lid)
      AND    NVL(projected_deenrollment, SYSDATE) >= SYSDATE;

    queued_cards                customer_queued_card_tab := customer_queued_card_tab( );
    get_ll_sub_dtls_rec         get_ll_sub_dtls_cur%ROWTYPE;
    c_new_esn_min_comb_exists   VARCHAR2(1);
  BEGIN
    --Validate inputs
    IF   i_old_min IS NULL
      OR i_old_esn IS NULL
      OR i_new_min IS NULL
      OR i_new_esn IS NULL
    THEN
      o_error_num := '1401';
      o_error_msg  := 'INPUTS OLD MIN, OLD ESN, NEW MIN AND NEW ESN ARE MANDATORY';
      RETURN;
    END IF;

    --Check if active LL subscription exists for the given min and esn
    OPEN get_ll_sub_dtls_cur;
    FETCH get_ll_sub_dtls_cur INTO get_ll_sub_dtls_rec;

    IF get_ll_sub_dtls_cur%NOTFOUND
    THEN
      CLOSE get_ll_sub_dtls_cur;
      o_error_num := '1402';
      o_error_msg  := 'ACTIVE ENROLLMENT DOES NOT EXIST FOR THE GIVEN MIN:'|| i_old_min || ' AND ESN:' || i_old_esn ||' COMBINATION.';
      RETURN;
    END IF;

    CLOSE get_ll_sub_dtls_cur;

    queued_cards := sa.customer_info.Get_esn_queued_cards ( i_esn => i_old_esn );

    IF queued_cards.count > 0
    THEN
        o_error_num := '1403';
        o_error_msg  := 'OLD MIN:'||i_old_min||' HAS CARDS IN RESERVE. HENCE LIFELINE TRANSFER IS NOT ALLOWED';
        RETURN;
    END IF;

    --Check if the new ESN and MIN are associated
    BEGIN
      SELECT 'Y'
      INTO   c_new_esn_min_comb_exists
      FROM   table_part_inst pi_esn,
             table_part_inst pi_min
      WHERE  pi_esn.part_serial_no = i_new_esn
      AND    pi_esn.x_domain = 'PHONES'
      AND    pi_esn.x_part_inst_status = (SELECT x_code_number
                                          FROM   table_x_code_table
                                          WHERE  x_code_type='PS'
                                          AND    x_code_name  ='ACTIVE')
      AND    pi_min.part_to_esn2part_inst = pi_esn.objid
      AND    pi_min.part_serial_no = i_new_min
      AND    pi_min.x_domain = 'LINES'
      AND    pi_min.x_part_inst_status = (SELECT x_code_number
                                          FROM   table_x_code_table
                                          WHERE  x_code_type='LS'
                                          AND    x_code_name  ='ACTIVE');
    EXCEPTION
      WHEN OTHERS THEN
        o_error_num := '1404';
        o_error_msg  := 'ACTIVE COMBINATION FOR NEW ESN:'||i_new_esn|| ' AND NEW MIN:' ||i_new_min|| ' DOES NOT EXIST';
        RETURN;
    END;

    UPDATE sa.ll_subscribers
    SET    current_min = i_new_min,
           current_esn = i_new_esn,
           lastmodified = SYSDATE,
           last_modified_event = 'LL_TRANSFER'
    WHERE  objid = get_ll_sub_dtls_rec.objid;

    --Create subscriber history
    INSERT INTO sa.LL_SUBSCRIBERS_HIST (OBJID,
                                        LL_HIST2LL_SUBS,
                                        LID,
                                        ESN,
                                        MIN,
                                        USERNAME,
                                        SOURCESYSTEM,
                                        EVENT_INSERT,
                                        EVENT_UPDATE,
                                        EVENT_CODE,
                                        EVENT_NOTES,
                                        SP_OBJID,
                                        LL_PLAN_ID,
                                        SMP,
                                        CALL_TRANS_OBJID
                                       )
                                VALUES (seq_ll_subscribers_hist.nextval,      --OBJID
                                        get_ll_sub_dtls_rec.objid,            --LL_HIST2LL_SUBS
                                        get_ll_sub_dtls_rec.LID,              --LID
                                        get_ll_sub_dtls_rec.current_esn,      --ESN
                                        get_ll_sub_dtls_rec.current_min,      --MIN
                                        get_ll_sub_dtls_rec.full_name,        --USERNAME
                                        NVL(i_source_system, 'TAS'),          --SOURCESYSTEM
                                        SYSDATE,                              --EVENT_INSERT
                                        NULL,                                 --EVENT_UPDATE
                                        (SELECT x_code_number
                                        FROM   table_x_code_table
                                        WHERE  x_code_name='LL_TRANSFER'),    --EVENT_CODE
                                        'Lifeline transfer from old MIN:'|| i_old_min || ' to the new MIN:'||i_new_min,       --EVENT_NOTES
                                        NULL,               --SP_OBJID
                                        get_ll_sub_dtls_rec.current_ll_plan_id,                 --LL_PLAN_ID
                                        NULL,                                 --SMP
                                        NULL                                  --CALL_TRANS_OBJID
                                       );

    o_error_num := '0';
    o_error_msg  := 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      o_error_num := SQLCODE;
      o_error_msg  := 'UNEXPECTED ERROR WHILE EXECUTING PROCEDURE LL_SUBSCRIB_PKG.PROCESS_LL_TRANSFER. '|| SUBSTR(SQLERRM, 1, 500);
  END PROCESS_LL_TRANSFER;

  PROCEDURE PROCESS_DEENROLLMENTS ( i_max_row_limit      IN    NUMBER DEFAULT 5000 ,
                                    i_commit_every_rows  IN    NUMBER DEFAULT 1000 ,
                                    o_response           OUT   VARCHAR2
                                  )
  IS
    CURSOR pending_ll_deenrollments_cur
    IS
      SELECT *
      FROM   sa.ll_subscribers
      WHERE  TRUNC(NVL(projected_deenrollment, SYSDATE+1)) <= TRUNC(SYSDATE)
      AND    enrollment_status <> 'DEENROLLED'
      AND    rownum <= i_max_row_limit;
    pending_ll_deenrollments_rec  pending_ll_deenrollments_cur%ROWTYPE;

    c_esn_status  VARCHAR2(10);
    c_min_status  VARCHAR2(10);
    n_count_rows  NUMBER := 0;
    c_err_num     VARCHAR2(100);
    c_err_msg     VARCHAR2(4000);
  BEGIN
    FOR pending_ll_deenrollments_rec IN pending_ll_deenrollments_cur
    LOOP
      --Get the esn status
      BEGIN
        SELECT x_part_inst_status
        INTO   c_esn_status
        FROM   table_part_inst
        WHERE  part_serial_no = pending_ll_deenrollments_rec.current_esn
        AND    x_domain = 'PHONES';
      EXCEPTION
        WHEN OTHERS THEN
          c_esn_status := '52';
      END;

      --Get the min status
      BEGIN
        SELECT x_part_inst_status
        INTO   c_min_status
        FROM   table_part_inst
        WHERE  part_serial_no = pending_ll_deenrollments_rec.current_min
        AND    x_domain = 'LINES';
      EXCEPTION
        WHEN OTHERS THEN
          c_min_status := '13';
      END;

      IF   c_esn_status <> '52'
        OR c_min_status <> '13'
      THEN
        --Execute the deenrollment procedure
        DEENROLL_LL_SUBSCRIBER ( i_min            => pending_ll_deenrollments_rec.current_min,
                                 i_esn            => pending_ll_deenrollments_rec.current_esn,
                                 i_source_system  => 'LL_DEENROLL_BATCH',
                                 o_Error_Num      => c_err_num,
                                 o_Error_Msg      => c_err_msg
                               );
        IF c_err_num <> '0'
        THEN
          o_response := 'ERROR WHILE PROCESSING DEENROLLMENT FOR MIN:'|| pending_ll_deenrollments_rec.current_min || '. ' || c_err_msg;
          RETURN;
        END IF;
      ELSE
        UPDATE sa.ll_subscribers
        SET    projected_deenrollment = NULL,
               lastmodified = SYSDATE,
               last_modified_event = 'LL_DEENROLLMENT'
        WHERE  objid = pending_ll_deenrollments_rec.objid;
      END IF;

      -- increase row count
      n_count_rows := n_count_rows + 1;

      IF (MOD (n_count_rows, i_commit_every_rows) = 0)
      THEN
        -- Save changes
        COMMIT;
      END IF;
    END LOOP;

    o_response := 'SUCCESS';
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'ERROR IN LL_SUBSCRIBER_PKG.PROCESS_DEENROLLMENTS: ' || SQLERRM;
  END PROCESS_DEENROLLMENTS;

  PROCEDURE PROCESS_ENROLLMENTS ( i_lid                IN    VARCHAR2,
                                  i_job_data_id        IN    VARCHAR2,
                                  o_error_num          OUT   VARCHAR2,
                                  o_error_msg          OUT   VARCHAR2
                                )
  IS
    CURSOR get_vmbc_records_cur
    IS
      SELECT *
      FROM   sa.xsu_vmbc_request
      WHERE  lid = i_lid
      AND    enrollrequest = 'Z'
      AND    job_data_id = i_job_data_id;
    get_vmbc_records_rec  get_vmbc_records_cur%ROWTYPE;

    ll_plan_id_tbl              sa.ll_plan_dtl_tab := sa.ll_plan_dtl_tab();
    ll_subscriber_rec           sa.ll_subscriber_type;
    o_ll_sub_id                 NUMBER;
    o_esn_part_inst_id          VARCHAR2(200);
    o_part_number               VARCHAR2(30);
    o_part_class                VARCHAR2(50);
    o_err_num                   NUMBER       ;
    o_err_msg                   VARCHAR2(200);
    c_bus_org_id                VARCHAR2(100);
    n_current_ll_plan_id        NUMBER;
  BEGIN
    --Validate inputs
    IF   i_lid IS NULL
      OR i_job_data_id IS NULL
    THEN
      o_error_num := '1501';
      o_error_msg  := 'BOTH LID AND JOB_DATA_ID ARE REQUIRED';
      RETURN;
    END IF;

    OPEN get_vmbc_records_cur;
    FETCH get_vmbc_records_cur INTO get_vmbc_records_rec;

    IF get_vmbc_records_cur%NOTFOUND
    THEN
      CLOSE get_vmbc_records_cur;
      o_error_num := '1502';
      o_error_msg  := 'COULD NOT FIND DATA FOR THE GIVEN JOB_DATA_ID AND MIN';
      RETURN;
    END IF;

    CLOSE get_vmbc_records_cur;

    IF get_vmbc_records_rec.plan IS NOT NULL
    THEN
      SELECT plan_id
        INTO n_current_ll_plan_id
        FROM ll_plans
       WHERE TO_CHAR(plan_id) = get_vmbc_records_rec.plan
          OR discount_code = get_vmbc_records_rec.plan;
    ELSE
      n_current_ll_plan_id := NULL;
    END IF;

    ll_plan_id_tbl.extend(1);

    ll_plan_id_tbl(1) := sa.ll_plan_dtl_type (n_current_ll_plan_id);

    ll_subscriber_rec := sa.ll_subscriber_type(get_vmbc_records_rec.lid     --LID
                                              ,c_bus_org_id     --BUS_ORG
                                              ,get_vmbc_records_rec.old_lid     --OLD_LID
                                              ,NULL      --MIN
                                              ,get_vmbc_records_rec.esn      --ESN
                                              ,UPPER(get_vmbc_records_rec.requesttype)   --REQUEST_TYPE
                                              ,get_vmbc_records_rec.contact      --CONTACT_OBJID
                                              ,NULL      --WEB_USER_OBJID
                                              ,'ENROLLED'      --ENROLLMENT_STATUS
                                              ,NULL      --DEENROLL_REASON
                                              ,SYSDATE      --CURRENT_ENROLLMENT_DATE
                                              ,SYSDATE      --ORIGINAL_ENROLLMENT_DATE
                                              ,NULL      --ORIGINAL_DEENROLLMENT_REASON
                                              ,get_vmbc_records_rec.plan      --CURRENT_LL_PLAN_ID
                                              ,NULL      --LAST_DISCOUNT_DT
                                              ,NULL      --PROJECTED_DEENROLLMENT
                                              ,ll_plan_id_tbl      --ll_plan_dtl_tbl
                                              ,get_vmbc_records_rec.name      --FULL_NAME
                                              ,get_vmbc_records_rec.address      --ADDRESS_1
                                              ,get_vmbc_records_rec.address2      --ADDRESS_2
                                              ,get_vmbc_records_rec.city      --CITY
                                              ,get_vmbc_records_rec.state      --STATE
                                              ,get_vmbc_records_rec.zip      --ZIP
                                              ,get_vmbc_records_rec.zip2      --ZIP2
                                              ,get_vmbc_records_rec.email      --E_MAIL
                                              ,get_vmbc_records_rec.homenumber                       --HOMENUMBER
                                              ,get_vmbc_records_rec.allowprerecorded                       --ALLOW_PRERECORDED
                                              ,get_vmbc_records_rec.emailpref                       --EMAIL_PREF
                                              ,NULL                       --LAST_AV_DATE
                                              ,NULL                       --AV_DUE_DATE
                                              ,get_vmbc_records_rec.qualifydate                  --QUALIFY_DATE
                                              ,get_vmbc_records_rec.qualifytype                       --QUALIFY_TYPE
                                              ,get_vmbc_records_rec.external_account                       --EXTERNAL_ACCOUNT
                                              ,get_vmbc_records_rec.stateidname                 --STATEIDNAME
                                              ,get_vmbc_records_rec.stateidvalue                       --STATEIDVALUE
                                              ,get_vmbc_records_rec.adl                       --ADL
                                              ,get_vmbc_records_rec.usacform                       --USACFORM
                                              ,get_vmbc_records_rec.eligiblefirstname                                --ELIGIBLEFIRSTNAME
                                              ,get_vmbc_records_rec.eligiblelastname                                 --ELIGIBLELASTNAME
                                              ,get_vmbc_records_rec.eligiblemiddlenameinitial                        --ELIGIBLEMIDDLENAMEINITIAL
                                              ,get_vmbc_records_rec.hmodisclaimer                                    --HMODISCLAIMER
                                              ,get_vmbc_records_rec.ipaddress                                        --IPADDRESS
                                              ,get_vmbc_records_rec.personid                                         --PERSONID
                                              ,get_vmbc_records_rec.personisinvalid                                  --PERSONISINVALID
                                              ,get_vmbc_records_rec.stateagencyqualification                         --STATEAGENCYQUALIFICATION
                                              ,get_vmbc_records_rec.transferflag                                     --TRANSFERFLAG
                                              ,get_vmbc_records_rec.qualifyprograms                       --QUALIFY_PROGRAMS
                                              ,get_vmbc_records_rec.dobisinvalid                       --DOBISINVALID
                                              ,get_vmbc_records_rec.ssnisinvalid                       --SSNISINVALID
                                              ,get_vmbc_records_rec.addressiscommercial                        --ADDRESSISCOMMERCIAL
                                              ,get_vmbc_records_rec.addressisduplicated                        --ADDRESSISDUPLICATED
                                              ,get_vmbc_records_rec.addressisinvalid                           --ADDRESSISINVALID
                                              ,get_vmbc_records_rec.addressistemporary                         --ADDRESSISTEMPORARY
                                              ,get_vmbc_records_rec.x_campaign                       --CAMPAIGN
                                              ,get_vmbc_records_rec.x_promotion                       --PROMOTION
                                              ,get_vmbc_records_rec.x_promocode                       --PROMOCODE
                                              ,get_vmbc_records_rec.channeltype                       --CHANNEL_TYPE
                                              );

    sa.ll_subscriber_pkg.enroll_ll_subscriber(ll_subscriber_rec       => ll_subscriber_rec
                                             ,o_ll_sub_id             => o_ll_sub_id
                                             ,o_esn_part_inst_objid   => o_esn_part_inst_id
                                             ,o_app_part_number       => o_part_number
                                             ,o_app_part_class        => o_part_class
                                             ,o_Error_Num             => o_err_num
                                             ,o_Error_Msg             => o_err_msg
                                             );
    IF o_err_num = '0'
    THEN
      COMMIT;
      o_error_num := '0';
      o_error_msg := 'SUCCESS';
    ELSE
      ROLLBACK;
      o_error_num := o_err_num;
      o_error_msg := o_err_msg;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      o_error_num := SQLCODE;
      o_error_msg := 'ERROR IN LL_SUBSCRIBER_PKG.PROCESS_ENROLLMENTS: ' || SQLERRM;
  END PROCESS_ENROLLMENTS;

  FUNCTION IS_LIFELINE_ENROLLED ( i_esn  IN   VARCHAR2,
                                  i_min  IN   VARCHAR2
                                )
  RETURN VARCHAR2
  IS
    c_is_enrollment_exist   VARCHAR2(1) := 'N';
  BEGIN
    IF i_esn IS NULL AND i_min IS NULL
    THEN
      RETURN 'BOTH ESN AND MIN ARE NOT PASSED';
    END IF;

    BEGIN
      SELECT 'Y'
      INTO   c_is_enrollment_exist
      FROM   ll_subscribers
      WHERE  (current_min = i_min OR current_esn = i_esn)
      AND    enrollment_status = 'ENROLLED'
      AND    TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
        c_is_enrollment_exist := 'N';
    END;

    RETURN c_is_enrollment_exist;
  END IS_LIFELINE_ENROLLED;
END LL_SUBSCRIBER_PKG;
/
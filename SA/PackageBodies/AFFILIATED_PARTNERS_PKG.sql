CREATE OR REPLACE PACKAGE BODY sa."AFFILIATED_PARTNERS_PKG" AS
/*************************************************************************************************************************************
  * $Revision: 1.28 $
  * $Author: sgangineni $
  * $Date: 2017/12/20 01:00:10 $
  * $Log: affiliated_partners_pkb.sql,v $
  * Revision 1.28  2017/12/20 01:00:10  sgangineni
  * CR48260 - added exception handling in get_emp_discount_name
  *
  * Revision 1.27  2017/12/19 19:47:11  sraman
  * Added new parameter i_web_user_objid
  *
  * Revision 1.26  2017/12/14 22:05:17  sraman
  * CR48260 added p_get_emp_discount_name
  *
  * Revision 1.25  2017/11/16 20:25:15  sraman
  * SM MLD CHANGES
  *
  * Revision 1.24  2017/06/06 17:29:48  smeganathan
  * Merged code with 6/6 production release
  *
  * Revision 1.23  2017/05/17 22:14:47  mshah
  * CR48169 - Existing Customer on Auto-Refill for Affiliated Partner Discount
  *
  * Revision 1.22  2017/05/10 16:24:34  mshah
  * CR48169 - Existing Customer on Auto-Refill for Affiliated Partner Discount
  *
  * Revision 1.21  2017/05/04 18:09:47  tbaney
  * Merged 48169 and 48480.
  *
  * Revision 1.20  2017/05/03 15:21:18  mshah
  * CR48169 - Existing Customer on Auto-Refill for Affiliated Partner Discount
  *
  * Revision 1.19  2017/05/02 15:59:33  mshah
  * CR48169 - Existing Customer on Auto-Refill for Affiliated Partner Discount
  *
  * Revision 1.13  2016/12/28 16:07:52  mshah
  * CR47013 - Add new fields First name and Last name
  *
  * Revision 1.12  2016/11/17 16:37:24  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.11  2016/11/16 17:46:54  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.10  2016/11/15 20:45:28  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.9  2016/11/14 16:57:50  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.8  2016/11/11 20:01:10  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.7  2016/11/08 18:25:27  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.6  2016/11/08 16:48:03  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.5  2016/11/08 16:16:50  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.4  2016/11/07 23:48:39  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.3  2016/11/07 23:17:52  mshah
  * CR44011 - Affiliated Partner Discount
  *
  * Revision 1.2  2016/11/07 17:48:34  mshah
  * CR44011 - Affiliated Partner Discount
  *
  *************************************************************************************************************************************/

--Below procedure will validate domain of email address or partner code and generate token.
PROCEDURE validate_partner
                          (
                           i_email         IN  VARCHAR2, --customers email
                           i_partner_code  IN  VARCHAR2, --partner code
                           i_emp_id        IN  VARCHAR2,
                           i_brand         IN  VARCHAR2 DEFAULT NULL,
                           i_firstName     IN  VARCHAR2, --Cust. First name --47013
                           i_lastName      IN  VARCHAR2, --Cust. Last name --47013
                           o_token         OUT VARCHAR2, --unique token
                           o_status        OUT VARCHAR2, --VALID, INVALID
                           o_ref_id        OUT NUMBER,   --Aff. Partner OBJID
                           o_errcode       OUT VARCHAR2,
                           o_errmsg        OUT VARCHAR2
                          )
IS
v_partner_name VARCHAR2(100);
v_inactive_chk NUMBER(5) := 0;
BEGIN --{
 o_errcode := '0';

IF i_partner_code IS NOT NULL --{
THEN
 DBMS_OUTPUT.PUT_LINE('Parner Code Entered..');

 --Check if Email ID or Partner Code entered is valid
 BEGIN --{
  SELECT 'VALID', OBJID, PARTNER_NAME
  INTO   o_status, o_ref_id, v_partner_name
  FROM   sa.table_affiliated_partners
  WHERE  UPPER(partner_code)   = UPPER(i_partner_code)
  AND    NVL(UPPER(status), 'INACTIVE') = 'ACTIVE'
  AND    UPPER(brand) = UPPER(i_brand)
  AND    ROWNUM <= 1;

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
----------------
 --Check if Inactive
  DBMS_OUTPUT.PUT_LINE('Check if Inactive ');

 BEGIN --{
  SELECT COUNT(1)
  INTO   v_inactive_chk
  FROM   sa.table_affiliated_partners
  WHERE  UPPER(partner_code)   = UPPER(i_partner_code)
  AND    NVL(UPPER(status), 'INACTIVE') = 'INACTIVE'
  AND    UPPER(brand) = UPPER(i_brand)
  AND    ROWNUM <= 1;

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE('Check if Inactive No data found');
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errmsg        := 'Partner not found';
  ROLLBACK;
  RETURN;
 WHEN OTHERS THEN
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '101';
  o_errmsg        := 'Error due to '||sqlerrm;
  ROLLBACK;
  RETURN;
 END; --}

 IF v_inactive_chk > 0 --{
 THEN
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '115';
  o_errmsg        := 'Partner is inactive.';
  ROLLBACK;
  RETURN;
 ELSE
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '114';
  o_errmsg        := 'Partner not found.';
  ROLLBACK;
  RETURN;
 END IF; --}
----------------
 WHEN OTHERS THEN
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '101';
  o_errmsg        := 'Error due to '||sqlerrm;
  ROLLBACK;
  RETURN;
 END;  --}

ELSE -----
 DBMS_OUTPUT.PUT_LINE('Email ID Entered..');
 --Check if Email ID or Partner Code entered is valid
 BEGIN --{
  SELECT 'VALID', OBJID, PARTNER_NAME
  INTO   o_status, o_ref_id, v_partner_name
  FROM   sa.table_affiliated_partners
  WHERE  INSTR(UPPER(i_email), '@'||UPPER(partner_domain)) <> 0
  AND    partner_domain IS NOT NULL
  AND    NVL(UPPER(status), 'INACTIVE') = 'ACTIVE'
  AND    UPPER(brand) = UPPER(i_brand)
  AND    ROWNUM <= 1;

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
----------------
 --Check if Inactive
  DBMS_OUTPUT.PUT_LINE('Check if Inactive ');

 BEGIN --{
  SELECT COUNT(1)
  INTO   v_inactive_chk
  FROM   sa.table_affiliated_partners
  WHERE  INSTR(UPPER(i_email), '@'||UPPER(partner_domain)) <> 0
  AND    partner_domain IS NOT NULL
  AND    NVL(UPPER(status), 'INACTIVE') = 'INACTIVE'
  AND    UPPER(brand) = UPPER(i_brand)
  AND    ROWNUM <= 1;

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
   DBMS_OUTPUT.PUT_LINE('Check if Inactive No data found');

  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errmsg        := 'Partner not found';
  ROLLBACK;
  RETURN;
 WHEN OTHERS THEN
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '101';
  o_errmsg        := 'Error due to '||sqlerrm;
  ROLLBACK;
  RETURN;
 END; --}

 IF v_inactive_chk > 0 --{
 THEN
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '115';
  o_errmsg        := 'Partner is inactive.';
  ROLLBACK;
  RETURN;
 ELSE
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '114';
  o_errmsg        := 'Partner not found.';
  ROLLBACK;
  RETURN;
 END IF; --}
----------------
 WHEN OTHERS THEN
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  o_errcode       := '101';
  o_errmsg        := 'Error due to '||sqlerrm;
  ROLLBACK;
  RETURN;
 END;  --}

END IF; -- }



 DBMS_OUTPUT.PUT_LINE('o_status ='||o_status);
 DBMS_OUTPUT.PUT_LINE('o_ref_id ='||o_ref_id);
 DBMS_OUTPUT.PUT_LINE('v_partner_name ='||v_partner_name);

 IF o_status <> 'VALID' --{
 THEN
  o_status        := 'INVALID';
  o_ref_id        := NULL;
  ROLLBACK;
  RETURN;

 ELSE

  --If o_status is Valid and email id not entered, just return the status.
  IF i_email IS NULL
  THEN
     o_errcode := '0';
     o_errmsg  := 'Valid Partner Code.';
     ROLLBACK;
     RETURN;
  END IF;

IF (check_email_present(i_email,NULL, 'ACTIVE','AFFILIATED')) --{ -- CR48480 added AFFILIATED
THEN
  o_errcode       := '113';
  o_errmsg        := 'Email address already registered';
  ROLLBACK;
  RETURN;
ELSE

 BEGIN --{
  SELECT ROUND(dbms_random.VALUE(10000,99999))||TO_CHAR(SYSTIMESTAMP,'MMDDHH24MISS')||ROUND(dbms_random.VALUE(10000,99999))
  INTO   o_token
  FROM   DUAL;
 EXCEPTION
  WHEN OTHERS THEN
    o_errcode       := '102';
    o_errmsg        := 'Error while generating token due to '||sqlerrm;
    ROLLBACK;
    RETURN;
 END; --}
 DBMS_OUTPUT.PUT_LINE('o_token ='||o_token);

   BEGIN --{
   ins_validate_emp (
                     i_email,
                     i_partner_code,
                     o_token,
                     v_partner_name,
                     i_emp_id,
                     i_brand,
                     i_firstName, --47013
                     i_lastName,  --47013
                     o_errcode,
                     o_errmsg
                     );


   EXCEPTION
   WHEN OTHERS THEN
    o_errcode       := '103';
    o_errmsg        := 'Error in ins_validate_emp due to '||sqlerrm;
    RETURN;
   END; --}
 END IF; --}
END IF; --}
 o_errcode := '0';
 o_errmsg  := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
 o_status        := NULL;
 o_ref_id        := NULL;
 o_errcode       := '104';
 o_errmsg        := 'Error in validate_partner due to '||sqlerrm;
END validate_partner; --}

--Once the email address or partner code is validated, below procedure will insert record in table_x_validate_emp
PROCEDURE ins_validate_emp
                          (
                           i_email        IN  VARCHAR2,
                           i_partner_code IN  VARCHAR2,
                           i_token        IN  VARCHAR2,
                           i_partner_name IN  VARCHAR2,
                           i_emp_id       IN  VARCHAR2,
                           i_brand        IN  VARCHAR2,
                           i_firstName    IN  VARCHAR2, --47013
                           i_lastName     IN  VARCHAR2, --47013
                           o_errcode      OUT VARCHAR2,
                           o_errmsg       OUT VARCHAR2
                           )
IS
v_count_txve NUMBER(5) := 0;
BEGIN --{
 o_errcode       := '0';
 DBMS_OUTPUT.PUT_LINE('Inside ins_validate_emp');

 BEGIN --{
  SELECT COUNT(1)
  INTO   v_count_txve
  FROM   TABLE_X_VALIDATE_EMP
  WHERE  UPPER(email)          = UPPER(i_email);
 EXCEPTION
  WHEN OTHERS THEN
  v_count_txve := 0;
 END; --}

 IF (v_count_txve > 0)--{
 THEN
  BEGIN --{
   UPDATE table_x_validate_emp
   SET    token_id              = i_token,
          brand                 = UPPER(i_brand),
          partner_code          = i_partner_code,
          partner_name          = i_partner_name,
          employee_id           = i_emp_id,
          first_name            = i_firstName, --47013
          last_name             = i_lastName,  --47013
          created_on            = SYSDATE
   WHERE  UPPER(email)          = UPPER(i_email);

  EXCEPTION
   WHEN OTHERS THEN
    o_errcode       := '105';
    o_errmsg        := 'Error in update table_x_validate_emp due to '||sqlerrm;
    ROLLBACK;
    RETURN;
  END; --}
 ELSE
  BEGIN --{
   INSERT INTO table_x_validate_emp
                                   (
                                    email,
                                    partner_code,
                                    token_id,
                                    partner_name,
                                    employee_id,
                                    brand,
                                    first_name, --47013
                                    last_name,  --47013
                                    created_on
                                   )
                             VALUES
                                   (
                                    i_email,
                                    i_partner_code,
                                    i_token,
                                    i_partner_name,
                                    i_emp_id,
                                    UPPER(i_brand),
                                    i_firstName, --47013
                                    i_lastName,   --47013
                                    SYSDATE
                                   );

  EXCEPTION
   WHEN OTHERS THEN
    o_errcode       := '105';
    o_errmsg        := 'Error in update TABLE_X_VALIDATE_EMP due to '||sqlerrm;
    ROLLBACK;
    RETURN;
  END; --}
 END IF; --}

 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 o_errcode       := '105';
 o_errmsg        := 'Error in ins_validate_emp due to '||sqlerrm;
 ROLLBACK;
 RETURN;
END ins_validate_emp;  --}


--Below procedure will register the email address to TABLE_X_EMPLOYEE_DISCOUNT and clear the entry from TABLE_X_VALIDATE_EMP
PROCEDURE validate_insert_employee_email
                                       (
                                        i_token        IN  VARCHAR2,
                                        o_email        OUT VARCHAR2,
                                        o_errcode      OUT VARCHAR2,
                                        o_errmsg       OUT VARCHAR2
                                        )
IS
 v_partner_name VARCHAR2(100) := NULL;
 v_employee_id  VARCHAR2(100) := NULL;
 v_brand        VARCHAR2(100) := NULL;
 v_partner_code VARCHAR2(100) := NULL;
 v_firstName    VARCHAR2(100) := NULL; --47013
 v_lastName     VARCHAR2(100) := NULL; --47013
 cst      sa.customer_type    :=  sa.customer_type ();
BEGIN --{
 o_errcode := '0';
 IF i_token IS NULL
 THEN
    o_errcode := '106';
    o_errmsg  := 'Please pass valid token id.';
    ROLLBACK;
    RETURN;
 END IF;

 BEGIN --{
  SELECT partner_name, employee_id, email, UPPER(brand), partner_code, first_name, last_name
  INTO   v_partner_name, v_employee_id, o_email, v_brand, v_partner_code, v_firstName, v_lastName
  FROM   TABLE_X_VALIDATE_EMP
  WHERE  token_id = i_token;
 EXCEPTION
 WHEN OTHERS THEN
  o_errcode       := '107';
  o_errmsg        := 'Token not matched.';
  ROLLBACK;
  RETURN;
 END; --}

  DBMS_OUTPUT.PUT_LINE('v_partner_name ='||v_partner_name);
  DBMS_OUTPUT.PUT_LINE('v_employee_id ='||v_employee_id);

IF v_partner_name IS NOT NULL --{
THEN

  IF(check_email_present(o_email,v_partner_name, NULL,'AFFILIATED')) --{ -- CR48480 added AFFILIATED
  THEN
   BEGIN --{
     DBMS_OUTPUT.PUT_LINE('In update');

     UPDATE  TABLE_X_EMPLOYEE_DISCOUNT
     SET     EMP_STATUS_CD  = 'ACTIVE',
             START_DATE     = TRUNC(SYSDATE),
             END_DATE       = '31-DEC-2055',
             EMPLOYEE_ID    = v_employee_id,
             BRAND          = v_brand,
             PARTNER_CODE   = upper(v_partner_code), --46700
             FIRST_NAME     = v_firstName, --47013
             LAST_NAME      = v_lastName   --47013
     WHERE   UPPER(LOGIN_NAME)   = UPPER(o_email)
     AND     partner_type        = 'AFFILIATED'  -- CR48480
     AND     UPPER(PARTNER_NAME) = UPPER(v_partner_name);

   EXCEPTION
    WHEN OTHERS THEN
     o_errcode       := '108';
     o_errmsg        := 'Error in update table_x_employee_discount due to '||sqlerrm;
     ROLLBACK;
     RETURN;
    END; --}
  ELSE
    BEGIN --{
     DBMS_OUTPUT.PUT_LINE('In Insert');

    INSERT INTO TABLE_X_EMPLOYEE_DISCOUNT
                                        (
                                         LOGIN_NAME,
                                         EMP_STATUS_CD,
                                         START_DATE,
                                         END_DATE,
                                         PARTNER_NAME,
                                         EMPLOYEE_ID,
                                         BRAND,
                                         PARTNER_CODE,
                                         FIRST_NAME, --47013
                                         LAST_NAME,   --47013
                                         partner_type -- CR48480
                                         )
                                   VALUES
                                         (
                                          lower(o_email), --46700
                                          'ACTIVE',
                                          TRUNC(SYSDATE),
                                          '31-DEC-2055',
                                          v_partner_name,
                                          v_employee_id,
                                          v_brand,
                                          upper(v_partner_code), --46700
                                          v_firstName, --47013
                                          v_lastName,   --47013
                                          'AFFILIATED'  -- CR48480
                                         );
    EXCEPTION
    WHEN OTHERS THEN
     o_errcode       := '109';
     o_errmsg        := 'Error in insert table_x_employee_discount due to '||sqlerrm;
     ROLLBACK;
     RETURN;
    END; --}
END IF; --}

 BEGIN --{
   DBMS_OUTPUT.PUT_LINE('In Delete');

  DELETE FROM   TABLE_X_VALIDATE_EMP
  WHERE  token_id = i_token;
 EXCEPTION
 WHEN OTHERS THEN
  o_errcode       := '110';
  o_errmsg        := 'Error while deleting TABLE_X_VALIDATE_EMP due to '||sqlerrm;
  ROLLBACK;
  RETURN;
 END; --}

ELSE
 o_errcode       := '111';
 o_errmsg        := 'Token not matched.';
 ROLLBACK;
 RETURN;
END IF; --}

--CR48260_MultiLine Discount on SM - call sp_notify_affpart_discount_BRM
cst                 :=  cst.retrieve_login ( i_login_name   =>    lower(o_email),
                                             i_bus_org_id   =>    v_brand);

enqueue_transactions_pkg.sp_notify_affpart_discount_BRM   (i_web_user_objid    => cst.web_user_objid     ,
                                                           i_login_name        => cst.web_login_name     ,
                                                           i_bus_org_id        => cst.bus_org_id         ,
                                                           i_web_user2contact  => cst.web_contact_objid  ,
                                                           o_response          => o_errmsg)	;
COMMIT;

EXCEPTION
WHEN OTHERS THEN
 o_errcode       := '112';
 o_errmsg        := 'Error in validate_insert_employee_email due to '||sqlerrm;
 ROLLBACK;
 RETURN;
END validate_insert_employee_email; --}

FUNCTION check_email_present
                            (
                            i_email        IN VARCHAR2,
                            i_partner_name IN VARCHAR2,
                            i_status       IN VARCHAR2,
                            i_partner_type IN VARCHAR2   -- CR48480
                            ) RETURN BOOLEAN
IS
v_count   NUMBER(10) := 0;
BEGIN

 SELECT count(1)
 INTO   v_count
 FROM   TABLE_X_EMPLOYEE_DISCOUNT
 WHERE  UPPER(LOGIN_NAME)    = UPPER(i_email)
 AND    UPPER(PARTNER_NAME)  = UPPER(NVL(i_partner_name,PARTNER_NAME))
 AND    UPPER(EMP_STATUS_CD) = UPPER(NVL(i_status,EMP_STATUS_CD));

 DBMS_OUTPUT.PUT_LINE('v_count ='||v_count);

 IF v_count > 0
 THEN
  RETURN TRUE;
 ELSE
  RETURN FALSE;
 END IF;

 EXCEPTION
WHEN OTHERS THEN
 RETURN FALSE;
END check_email_present;

--CR48169 - Existing Customer on Auto-Refill for Affiliated Partner Discount

PROCEDURE add_affpart_promo_to_cust(i_email   IN  table_x_employee_discount.login_name%TYPE,
                                    i_days    IN  NUMBER,
                                    o_errcode OUT NUMBER,
                                    o_errmsg  OUT VARCHAR2
                                    )
IS
 v_promo_objid           NUMBER;
 v_promo_code            VARCHAR2(200);
 v_script_id             VARCHAR2(200);

 CURSOR  cust_wo_promo(p_email VARCHAR2) IS
 SELECT  *
 FROM    sa.table_x_employee_discount a
 WHERE   EXISTS (
                 SELECT 1
                 FROM   table_web_user b
                 WHERE  b.s_login_name = UPPER(a.login_name)
                 )
 AND     (
           (a.start_date >= SYSDATE - i_days
            AND
            p_email IS NULL)
            OR
            UPPER(a.login_name) = p_email
          );

 CURSOR    cust_esn(p_email VARCHAR2) IS
 SELECT    tpi.part_serial_no, x_part_inst_status
 FROM      table_contact tc,
           table_x_contact_part_inst txcpi,
           table_part_inst tpi,
           table_web_user twu
 WHERE     txcpi.x_contact_part_inst2part_inst = tpi.objid
 AND       txcpi.x_contact_part_inst2contact   = tc.objid
 AND       twu.web_user2contact                = tc.objid
 AND       twu.s_login_name                    = p_email
 AND       tpi.x_part_inst_status              = '52';

 CURSOR  cust_enrollment(
                         p_esn x_program_enrolled.x_esn%TYPE,
                         p_partner_name table_x_employee_discount.partner_name%TYPE
                        )
 IS
 SELECT  *
 FROM    x_program_enrolled a,
         mtm_affpart_prog_promo b
 WHERE   x_esn                   = p_esn
 AND     x_enrollment_status     = 'ENROLLED'
 AND     EXISTS (
                 SELECT 1
                 FROM   x_program_parameters xpp
                 WHERE  xpp.x_is_recurring          =     1
                 AND    xpp.objid = pgm_enroll2pgm_parameter
                )
 AND     a.pgm_enroll2pgm_parameter = b.mtm2prog
 AND     b.partner_name                       = p_partner_name
 AND     NVL(a.pgm_enroll2x_promotion, '1')   != b.mtm2promo;
BEGIN -- {
 FOR i IN cust_wo_promo(UPPER(i_email))
 LOOP --{
  --DBMS_OUTPUT.PUT_LINE('Email: '||i.login_name);
  --DBMS_OUTPUT.PUT_LINE('--------------------');

  FOR j IN cust_esn(UPPER(i.login_name))
  LOOP --{
    --DBMS_OUTPUT.PUT_LINE('ESN: '||j.part_serial_no||' STATUS: '||j.X_PART_INST_STATUS);
    FOR k IN cust_enrollment(j.part_serial_no, i.partner_name)
    LOOP --{
     BEGIN --{
     enroll_promo_pkg.sp_get_eligible_promo_esn3
                                               (
                                                j.part_serial_no,
                                                k.pgm_enroll2pgm_parameter,
                                                v_promo_objid,
                                                v_promo_code,
                                                v_script_id,
                                                o_errcode,
                                                o_errmsg,
                                                'Y'
                                               );

     EXCEPTION
     WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in sp_get_eligible_promo_esn3 due to '||sqlerrm);
     END; --}

     IF     o_errcode = 0
        AND v_promo_objid IS NOT NULL
        AND NVL(v_promo_objid, '1') <> NVL(k.pgm_enroll2x_promotion, '1')
        AND v_promo_objid = k.mtm2promo
     THEN --{
      BEGIN --{
      --DBMS_OUTPUT.PUT_LINE('Inside sp_register_esn_promo2');
      enroll_promo_pkg.sp_register_esn_promo2
                                            (
                                             j.part_serial_no,
                                             v_promo_objid,
                                             o_errcode,
                                             o_errmsg
                                            );
      DBMS_OUTPUT.PUT_LINE('ESN: '||j.part_serial_no||' STATUS: '||j.x_part_inst_status||' Program: '||k.pgm_enroll2pgm_parameter||' v_promo_objid:'||v_promo_objid||' v_promo_code:'||v_promo_code);
      EXCEPTION
      WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('Error in sp_register_esn_promo2 due to '||sqlerrm);
      END; --}
     END IF; --}
    END LOOP; --}
  END LOOP; --}
 END LOOP; --}

EXCEPTION
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('In main exception of add_affpart_promo_to_cust- '||sqlerrm);
 o_errcode := 20;
 o_errmsg  := 'In main exception of add_affpart_promo_to_cust- '||sqlerrm;
 ROLLBACK;
END add_affpart_promo_to_cust; --}

--
-- CR48480 changes starts..
-- Procedure to validate the partner for Enrollment of affiliated partner Members
--
PROCEDURE p_validate_partner  ( i_partner_name    IN    VARCHAR2,
                                i_brand           IN    VARCHAR2,
                                i_partner_type    IN    VARCHAR2  DEFAULT 'MEMBER_ENROLL',
                                o_valid_partner   OUT   VARCHAR2,
                                o_err_code        OUT   VARCHAR2,
                                o_err_msg         OUT   VARCHAR2)
IS
BEGIN
--
  BEGIN
    SELECT  DECODE(COUNT(*),0,'N','Y')
    INTO    o_valid_partner
    FROM    table_affiliated_partners
    WHERE   partner_name    =   i_partner_name
    AND     brand           =   i_brand
    AND     partner_type    =   i_partner_type
    AND     status          =   'ACTIVE';
  EXCEPTION
    WHEN OTHERS THEN
      o_valid_partner :=  'N';
  END;
  --
  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '100060';
    o_err_msg   :=  'ERROR IN AFFILIATED_PARTNERS_PKG.P_VALIDATE_MEMBER_ENROLL_PARTNER: ' || SUBSTR(SQLERRM,1,2000);
END p_validate_partner;
--
-- Commenting out new procedures, this is future use..
/*
-- Procedure to enroll customer into member signup program
--
PROCEDURE p_enroll_customer ( i_webuser_objid         IN    NUMBER,
                              i_login_name            IN    VARCHAR2,
                              i_brand                 IN    VARCHAR2,
                              i_partner_name          IN    VARCHAR2,
                              o_err_code              OUT   VARCHAR2,
                              o_err_msg               OUT   VARCHAR2)
IS
--
  l_enrollment_status   VARCHAR2(50);
  l_valid_partner       VARCHAR2(1)   :=  'N';
  l_valid_webuser       VARCHAR2(1)   :=  'N';
  l_valid_brand         VARCHAR2(1)   :=  'N';
BEGIN
--
  -- Input validation
  IF i_webuser_objid IS NULL OR i_partner_name IS NULL  OR i_brand IS NULL
  THEN
    o_err_code  :=  '101';
    o_err_msg   :=  'WEB USER OBJID / PARTNER NAME  / BRAND cannot be NULL';
    RETURN;
  END IF;
  --
  -- Validate Brand
  BEGIN
    SELECT  DECODE(COUNT(*),'Y','N')
    INTO    l_valid_brand
    FROM    table_bus_org   bo
    WHERE   bo.org_id = i_brand;
  EXCEPTION
    WHEN OTHERS THEN
      o_err_code  :=  '102';
      o_err_msg   :=  'Invalid BRAND';
      RETURN;
  END;
  --
  IF l_valid_brand  = 'N'
  THEN
    o_err_code  :=  '102';
    o_err_msg   :=  'Invalid BRAND';
    RETURN;
  END IF;
  -- Validate login name and web user objid
  BEGIN
    SELECT  DECODE(COUNT(*),'Y','N')
    INTO    l_valid_webuser
    FROM    table_web_user  wu,
            table_bus_org   bo
    WHERE   wu.objid  = i_webuser_objid
    AND     (wu.login_name        = NVL(i_login_name,wu.login_name) OR
             wu.s_login_name      = NVL(UPPER(i_login_name),wu.s_login_name))
    AND     wu.web_user2bus_org   = bo.org_id;
  EXCEPTION
    WHEN OTHERS THEN
      o_err_code  :=  '103';
      o_err_msg   :=  'Invalid WEB USER OBJID / LOGIN NAME for the brand';
      RETURN;
  END;
  --
  IF l_valid_webuser  = 'N'
  THEN
    o_err_code  :=  '103';
    o_err_msg   :=  'Invalid WEB USER OBJID / LOGIN NAME for the brand';
    RETURN;
  END IF;
  -- Validate partner
  p_validate_partner  ( i_partner_name    =>    i_partner_name,
                        i_brand           =>    i_brand,
                        i_partner_type    =>    'MEMBER_ENROLL',
                        o_valid_partner   =>    l_valid_partner,
                        o_err_code        =>    o_err_code,
                        o_err_msg         =>    o_err_code);
  --
  IF l_valid_partner  = 'N'
  THEN
    o_err_code  :=  '104';
    o_err_msg   :=  'Invalid Partner Name';
    RETURN;
  END IF;
  -- Check whether user is already registered for the signup
  BEGIN
    SELECT emp_status_cd
    INTO   l_enrollment_status
    FROM   table_x_employee_discount
    WHERE  UPPER(login_name)    = UPPER(i_login_name)
    AND    partner_name         = i_partner_name
    AND    brand                = i_brand
    AND    partner_type         = 'MEMBER_ENROLL';
  EXCEPTION
    WHEN OTHERS THEN
      l_enrollment_status :=  ''  ;
  END;
  --
  IF UPPER(NVL(l_enrollment_status,'X'))  = 'ACTIVE'
  THEN
    o_err_code  :=  '104';
    o_err_msg   :=  'USER has already enrolled for this program';
    RETURN;
    --
  ELSIF UPPER(NVL(l_enrollment_status,'X'))  = 'INACTIVE'
  THEN
    --
    UPDATE  table_x_employee_discount
    SET     emp_status_cd   =   'ACTIVE',
            start_date      =   TRUNC(SYSDATE),
            end_date        =   '31-DEC-2055'
    WHERE   UPPER(login_name)    = UPPER(i_login_name)
    AND     partner_name         = i_partner_name
    AND     brand                = i_brand
    AND     partner_type         = 'MEMBER_ENROLL';
    --
    o_err_code  :=  '105';
    o_err_msg   :=  'USER enrollment has been updated';
    RETURN;
    --
  ELSIF UPPER(NVL(l_enrollment_status,'X')) = 'X'
  THEN
    INSERT INTO table_x_employee_discount
      (
       login_name,
       emp_status_cd,
       start_date,
       end_date,
       partner_name,
       employee_id,
       brand,
       partner_code,
       first_name,
       last_name,
       partner_type
       )
     VALUES
       (
        lower(i_login_name),
        'ACTIVE',
        TRUNC(SYSDATE),
        '31-DEC-2055',
        i_partner_name,
        NULL,
        i_brand,
        NULL,
        NULL,
        NULL,
        'MEMBER_ENROLL'
       );
    --
  END IF;
  --
  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '100010';
    o_err_msg   :=  'ERROR IN AFFILIATED_PARTNERS_PKG.P_ENROLL_CUSTOMER: ' || SUBSTR(SQLERRM,1,2000);
END p_enroll_customer;
--
-- Get partner attributes from table_affiliated_partners
--
PROCEDURE p_get_partner_attributes  ( i_partner_name    IN    VARCHAR2,
                                      i_brand           IN    VARCHAR2,
                                      i_partner_type    IN    VARCHAR2,
                                      o_partner_rec     OUT   SYS_REFCURSOR,
                                      o_err_code        OUT   VARCHAR2,
                                      o_err_msg         OUT   VARCHAR2)
IS
BEGIN
--
  OPEN o_partner_rec
  FOR   SELECT  ap.*
        FROM    TABLE_AFFILIATED_PARTNERS ap
        WHERE   ap.partner_name               = i_partner_name
        AND     ap.brand                      = i_brand
        AND     ap.partner_type               = i_partner_type
        AND     ROWNUM = 1;
  --
  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '100020';
    o_err_msg   :=  'ERROR IN AFFILIATED_PARTNERS_PKG.P_GET_PARTNER_ATTRIBUTES: ' || SUBSTR(SQLERRM,1,2000);
END p_get_partner_attributes;
--
-- Procedure to check whether ESN is enrolled for the program
--
PROCEDURE p_check_esn_enroll    (i_esn              IN    VARCHAR2,
                                 i_brand            IN    VARCHAR2,
                                 i_partner_name     IN    VARCHAR2  DEFAULT 'AMAZON_WEB_ORDERS',
                                 o_program_enroll   OUT   VARCHAR2,
                                 o_err_code         OUT   VARCHAR2,
                                 o_err_msg          OUT   VARCHAR2)
IS
--
  cst   sa.customer_type    :=  sa.customer_type ();
--
BEGIN
--
  IF i_esn  IS NULL OR i_brand IS NULL
  THEN
    o_err_code  :=  '201';
    o_err_msg   :=  'ESN / BRAND cannot be NULL';
    RETURN;
  END IF;
  cst.esn     :=  i_esn;
  -- get web user objid
  cst         :=  cst.get_web_user_attributes;
  --
  IF  NVL(cst.web_user_objid,'X')   = 0
  THEN
    o_err_code  :=  '202';
    o_err_msg   :=  'ESN is not linked to ACCOUNT';
    RETURN;
  END IF;
  --
  p_check_user_enroll   ( i_login_name        =>    cst.web_login_name,
                          i_web_user_objid    =>    cst.web_user_objid,
                          i_brand             =>    i_brand,
                          i_partner_name      =>    i_partner_name,
                          o_program_enroll    =>    o_program_enroll,
                          o_err_code          =>    o_err_code,
                          o_err_msg           =>    o_err_msg);
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '100030';
    o_err_msg   :=  'ERROR IN AFFILIATED_PARTNERS_PKG.P_CHECK_ESN_ENROLL: ' || SUBSTR(SQLERRM,1,2000);
END p_check_esn_enroll;
--
-- Procedure to check whether the web user is enrolled for the program
--
PROCEDURE p_check_user_enroll   ( i_login_name      IN    VARCHAR2,
                                  i_web_user_objid  IN    VARCHAR2,
                                  i_brand           IN    VARCHAR2,
                                  i_partner_name    IN    VARCHAR2  DEFAULT 'AMAZON_WEB_ORDERS',
                                  o_program_enroll  OUT   VARCHAR2,
                                  o_err_code        OUT   VARCHAR2,
                                  o_err_msg         OUT   VARCHAR2)
IS
--
  cst           sa.customer_type    :=  sa.customer_type  ();
  l_enrolled    VARCHAR2(1) :=  'N';
--
BEGIN
--
  IF  i_login_name IS NULL AND i_web_user_objid IS NULL
  THEN
    o_err_code  :=  '301';
    o_err_msg   :=  'WEB USER OBJID / LOGIN NAME cannot be NULL';
    RETURN;
  END IF;
  --
  -- get the web user objid with login name
  IF i_web_user_objid IS NULL
  THEN
    cst                 :=  cst.retrieve_login ( i_login_name   =>    i_login_name,
                                                 i_bus_org_id   =>    i_brand);
  ELSE
    cst.web_user_objid  :=  i_web_user_objid;
  END IF;
  --
  BEGIN
    SELECT  'Y'
    INTO    o_program_enroll
    FROM    table_x_employee_discount
    WHERE   WEB_USER_OBJID      =   cst.web_user_objid
    AND     PARTNER_NAME        =   i_partner_name
    AND     BRAND               =   i_brand
    AND     PARTNER_TYPE        =   'MEMBER_ENROLL'
    AND     EMP_STATUS_CD       =   'ACTIVE';
  EXCEPTION
    WHEN OTHERS THEN
      o_program_enroll  :=  'N';
  END;
  --
  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '100040';
    o_err_msg   :=  'ERROR IN AFFILIATED_PARTNERS_PKG.P_CHECK_USER_ENROLL: ' || SUBSTR(SQLERRM,1,2000);
END p_check_user_enroll;
--
-- Procedure to check whether discount is eligible for the ESN
--
PROCEDURE p_check_discount_eligibile  (i_esn                  IN    VARCHAR2,
                                       i_brand                IN    VARCHAR2,
                                       i_partner_name         IN    VARCHAR2  DEFAULT 'AMAZON_WEB_ORDERS',
                                       o_dealer_name          OUT   VARCHAR2,
                                       o_discount_eligibile   OUT   VARCHAR2,
                                       o_err_code             OUT   VARCHAR2,
                                       o_err_msg              OUT   VARCHAR2)
IS
--
  l_partner_rfc             SYS_REFCURSOR;
  l_partner_rec             table_affiliated_partners%ROWTYPE;
  l_program_enrolled        VARCHAR2(1) :=  'N';
--
BEGIN
--
  IF i_esn  IS NULL OR i_brand IS NULL
  THEN
    o_err_code  :=  '401';
    o_err_msg   :=  'ESN / BRAND cannot be NULL';
    RETURN;
  END IF;
  --
  p_get_partner_attributes  ( i_partner_name    =>  i_partner_name,
                              i_brand           =>  i_brand,
                              i_partner_type    =>  'MEMBER_ENROLL',
                              o_partner_rec     =>  l_partner_rfc,
                              o_err_code        =>  o_err_code,
                              o_err_msg         =>  o_err_msg);
  --
  FETCH l_partner_rfc INTO l_partner_rec;
  --
  p_check_esn_enroll    (i_esn              =>  i_esn,
                         i_brand            =>  i_brand,
                         i_partner_name     =>  i_partner_name,
                         o_program_enroll   =>  l_program_enrolled,
                         o_err_code         =>  o_err_code,
                         o_err_msg          =>  o_err_msg);
  --
  -- Get the dealer of the ESN
  BEGIN
    SELECT  ts.name
    INTO    o_dealer_name
    FROM    table_part_inst   pi,
            TABLE_INV_bin     tb,
            table_site        ts
    WHERE   tb.location_name        =   ts.site_id
    AND     pi.PART_INST2INV_BIN    =   tb.objid
    AND     pi.x_domain             =   'PHONES'
    AND     pi.part_serial_no       =   i_esn;
  EXCEPTION
    WHEN OTHERS THEN
      o_dealer_name :=  NULL;
  END;
  --
  IF  l_program_enrolled               = 'Y'   AND
      l_partner_rec.dealer_id_check    = 'Y'
  THEN
    --  verify whether the phone mapped to the dealer
    --  if yes, return discount eligible as Y
    IF NVL(o_dealer_name,'X') = l_partner_rec.partner_site_name
    THEN
      o_discount_eligibile    :=    'Y';
    ELSE
      o_discount_eligibile    :=    'N';
    END IF;
    --
  ELSIF (l_program_enrolled             = 'Y'   AND
        l_partner_rec.dealer_id_check   = 'N')
  THEN
    --
    o_discount_eligibile :=    'Y';
    --
  ELSIF l_program_enrolled  =   'N'
  THEN
    --
    o_discount_eligibile :=    'N';
    --
  END IF;
  --
  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '100050';
    o_err_msg   :=  'ERROR IN AFFILIATED_PARTNERS_PKG.P_CHECK_DISCOUNT_ELIGIBILE: ' || SUBSTR(SQLERRM,1,2000);
END p_check_discount_eligibile;
--
*/
-- CR48480 changes ends.
--

PROCEDURE p_get_emp_discount_name  ( i_email           IN    VARCHAR2,
                                     i_brand           IN    VARCHAR2,
                                     i_webuser_objid   IN    NUMBER  ,
                                     o_discount_name   OUT   VARCHAR2,
                                     o_err_code        OUT   VARCHAR2,
                                     o_err_msg         OUT   VARCHAR2) AS
c_login             table_web_user.login_name%TYPE;
c_brand             table_bus_org.org_id%TYPE;
BEGIN

  IF i_webuser_objid IS NOT NULL THEN
    BEGIN
      SELECT  login_name, bo.org_id
      INTO    c_login , c_brand
      FROM    table_web_user  wu,
             table_bus_org   bo
      WHERE   wu.objid  = i_webuser_objid
      AND     wu.web_user2bus_org   = bo.objid;
    EXCEPTION
      WHEN OTHERS THEN
        c_login := NULL;
        c_brand := NULL;
    END;
  END IF;

  IF c_login IS NOT NULL OR i_email IS NOT NULL
  THEN
    SELECT aff.brm_discount_name
    INTO o_discount_name
    FROM sa.table_x_employee_discount emp,
         sa.table_affiliated_partners aff
    WHERE 1               =1
    AND emp.partner_name  = aff.partner_name
    AND emp.brand         = aff.brand
    AND emp.login_name    = LOWER(NVL(i_email,c_login))
    AND emp.brand         = NVL(i_brand,c_brand)
    AND emp.partner_type  = 'AFFILIATED'
    AND ROWNUM            = 1;
  END IF;

  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
    o_err_code  :=  '100051';
    o_err_msg   :=  'UNABLE TO FETCH DISCOUNT: ' || SUBSTR(SQLERRM,1,500);
END p_get_emp_discount_name;


END affiliated_partners_pkg;
/
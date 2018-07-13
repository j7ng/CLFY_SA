CREATE OR REPLACE PACKAGE BODY sa.SAFELINK_REFER4CASH_PKG
IS

    /*===============================================================================================*/
    /*                                                                                               */
    /* Purpose: Package to create and update customer information who enrolled                       */
    /*          in safelink customer referral program.                                               */
    /* REVISIONS  DATE       WHO            PURPOSE                                                  */
    /* --------------------------------------------------------------------------------------------- */
    /*            7/25/2013 MVadlapally  Initial                                                     */
    /*===============================================================================================*/


-- THIS PROCEDURE WILL VALIDATE THE GIVEN EMAIL ID FOR SAFELINK FRIENDS
PROCEDURE validate_email(
    in_login        IN     table_web_user.s_login_name%TYPE,
    out_ref_objid      OUT x_user_referrers.objid%TYPE,
    out_err_num        OUT NUMBER,
    out_err_msg        OUT VARCHAR2)
IS

   CURSOR c_user_ref
   IS
   SELECT re.*
     FROM x_user_referrers re,table_web_user w
    WHERE re.x_user_ref2webuser = w.objid
      AND w.s_login_name = UPPER(in_login);
   r_user_ref   c_user_ref%ROWTYPE;

    CURSOR c_web_user IS
    SELECT web_user2bus_org
      FROM table_web_user
     WHERE s_login_name =  upper(in_login);
    r_web_user c_web_user%ROWTYPE;

   CURSOR c_bus_org
   IS
   SELECT objid
     FROM table_bus_org
    WHERE s_name = 'TRACFONE';

   v_proc_name  VARCHAR2(80):= 'SAFELINK_REFER4CASH_PKG.VALIDATE_EMAIL';
   l_bus_org    PLS_INTEGER := 0;
BEGIN
   out_err_num := 0;

   OPEN c_web_user;
   FETCH c_web_user INTO r_web_user;
   CLOSE c_web_user;

   OPEN c_bus_org;
   FETCH c_bus_org INTO l_bus_org;
   CLOSE c_bus_org;

   OPEN c_user_ref;
   FETCH c_user_ref INTO r_user_ref;
      IF c_user_ref%NOTFOUND AND nvl(r_web_user.web_user2bus_org,0) = l_bus_org
        THEN
        out_err_num := 900;
        out_err_msg := sa.get_code_fun('SAFELINK_REFER4CASH_PKG', '900','ENGLISH'); ---EMAIL ALREADY IN TF DB, PLEASE PROVIDE A NEW ONE
      END IF;
      IF c_user_ref%FOUND AND nvl(r_user_ref.x_validated,0) = 1
        THEN
        out_err_num := 901;
        out_err_msg := sa.get_code_fun('SAFELINK_REFER4CASH_PKG', '901','ENGLISH'); ---ALREADY A REFERRER - REJECT
      ELSIF c_user_ref%FOUND AND nvl(r_user_ref.x_validated,0) = 0
        THEN
        out_err_num := 902;
        out_err_msg := sa.get_code_fun('SAFELINK_REFER4CASH_PKG', '902','ENGLISH'); ---ALREADY A REFERRER - NOT VALIDATED
        out_ref_objid := r_user_ref.objid;
      END IF;
   CLOSE c_user_ref;
   IF out_err_num = 0
   THEN
      out_err_msg := 'SUCCESS: INSERT RECORD';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   out_err_num := SQLCODE;
   out_err_msg := SUBSTR(SQLERRM, 1, 200);

END validate_email;
----------------------------------------------------------------------------------------------------
-- THIS SERVICE WILL PERFORM SET OF VALIDATIONS BEFORE CREATING THE SAFELINK FRIENDS ACCOUNT.
PROCEDURE sp_safelink_validation (
    in_login_name        IN     table_web_user.login_name%TYPE,
    in_password          IN     table_web_user.password%TYPE,
    in_first_name        IN     table_contact.first_name%TYPE,
    in_last_name         IN     table_contact.last_name%TYPE,
    in_dob               IN     table_contact.x_dateofbirth%TYPE,
    out_user_ref_objid      OUT x_user_referrers.objid%TYPE,
    out_err_num             OUT NUMBER,
    out_err_msg             OUT VARCHAR2)
IS
   CURSOR c_contact
   IS
   SELECT tc.*
     FROM table_contact tc, x_user_referrers re
    WHERE tc.objid = re.x_user_ref2contact
      AND tc.s_first_name = in_first_name
      AND tc.s_last_name = in_last_name
      AND tc.x_dateofbirth = in_dob;
   r_contact   c_contact%ROWTYPE;
   v_proc_name  VARCHAR2(80):= 'SAFELINK_REFER4CASH_PKG.SP_SAFELINK_VALIDATION';

BEGIN
        -- 1.Referer should be 18 or above
        -- 2.Referer should NOT be employee of TF(@tracfone.com), Kobie(@Kobie.com), VMBC(@vmbc.com) [VALIDATE EMAIL BEFORE THIS STEP]
        -- 3.Referer should NOT be existing referrer (Based on match against Email Address, First and Last Name, and DOB).
        -- if the refferer is not an existing refferer then add a rec in web user
      out_err_num := 0;
    IF (months_between(TO_CHAR(sysdate,'DD-MON-YYYY'),TO_CHAR(in_DOB,'DD-MON-YYYY'))/12) < 18 THEN
      out_err_num := 903;
      out_err_msg := sa.get_code_fun('SAFELINK_REFER4CASH_PKG', '903','ENGLISH'); --REFFERER SHOULD BE 18 OR ABOVE
    ELSIF  regexp_replace(upper(in_login_name), '[^@]*@') IN ('TRACFONE.COM','KOBIE.COM','VMBC.COM') THEN
      out_err_num := 904;
      out_err_msg := sa.get_code_fun('SAFELINK_REFER4CASH_PKG', '904','ENGLISH'); ---REFERER SHOULD NOT BE EMPLOYEE OF TF, KOBIE, VMBC
    ELSE
      -- Calling email validation to validate email
      sa.safelink_refer4cash_pkg.validate_email(in_login_name,
                       -- r_web_user.web_user2bus_org,
                        out_user_ref_objid,
                        out_err_num,
                        out_err_msg);
        IF out_err_num = 0
        THEN
        -- compare  f.name, l.name and dob
            OPEN c_contact;
            FETCH c_contact INTO r_contact;
                IF c_contact%FOUND
                THEN
                  out_err_num := 905;
                  out_err_msg := sa.get_code_fun('SAFELINK_REFER4CASH_PKG', '905','ENGLISH'); ---CONTACT ALREADY IN SAFELINK FRIENDS
                END IF;
            CLOSE c_contact;
        END IF ;

    END IF ;

    IF out_err_num = 0
    THEN
       out_err_msg := 'Success';
    END IF;

EXCEPTION
    WHEN OTHERS
    THEN
    out_err_num := SQLCODE;
    out_err_msg := SUBSTR(SQLERRM, 1, 200);
END sp_safelink_validation;
--------------------------------------------------------
-- THIS PROCEDURE WILL CREATE A NEW REFERRER ACCOUNT.
PROCEDURE sp_create_referrer_acnt (
    in_login_name        IN     table_web_user.login_name%TYPE,
    in_password          IN     table_web_user.password%TYPE,
    in_first_name        IN     table_contact.first_name%TYPE,
    in_last_name         IN     table_contact.last_name%TYPE,
    in_phone_num         IN     table_contact.x_mobilenumber%TYPE,
    in_dob               IN     table_contact.x_dateofbirth%TYPE,
    in_secret_questn     IN     table_web_user.x_secret_questn%TYPE,
    in_secret_ans        IN     table_web_user.x_secret_ans%TYPE,
    in_brand_name        IN     table_bus_org.s_org_id%TYPE,
    in_client_status     IN     x_user_referrers.x_client_status%TYPE,
    in_bil_address1      IN     table_contact.address_1%TYPE,
    in_bil_address2      IN     table_contact.address_2%TYPE,
    in_bil_city          IN     table_contact.city%TYPE,
    in_bil_state         IN     table_contact.state%TYPE,
    in_bil_country       IN     table_contact.country%TYPE,
    in_bil_zip           IN     table_contact.zipcode%TYPE,
    in_shp_address1      IN     table_contact.address_1%TYPE,
    in_shp_address2      IN     table_contact.address_2%TYPE,
    in_shp_city          IN     table_contact.city%TYPE,
    in_shp_state         IN     table_contact.state%TYPE,
    in_shp_country       IN     table_contact.country%TYPE,
    in_shp_zip           IN     table_contact.zipcode%TYPE,
    out_user_ref_objid      OUT x_user_referrers.objid%TYPE,
    out_web_user_objid      OUT table_web_user.objid%TYPE,
    out_err_num             OUT NUMBER,
    out_err_msg             OUT VARCHAR2)
IS
    CURSOR c_org_id IS
    SELECT org.objid
      FROM table_bus_org org
     WHERE org.s_org_id =  upper(in_brand_name);
    r_org_id    c_org_id%ROWTYPE;

    l_user_ref_objid    PLS_INTEGER := NULL;
    l_webuser_objid     PLS_INTEGER := NULL;
    l_contact_objid     PLS_INTEGER := NULL;
    v_proc_name         VARCHAR2(80):= 'SAFELINK_REFER4CASH_PKG.SP_CREATE_REFERRER_ACNT';
    l_err_code          PLS_INTEGER := 0;
    l_err_msg           varchar2(200);

BEGIN

    OPEN c_org_id;
    FETCH c_org_id INTO r_org_id;
    CLOSE c_org_id;
    BEGIN
      contact_pkg.createcontact_prc
        (in_esn              => NULL,
         in_first_name       => in_first_name,
         in_last_name        => in_last_name,
         in_middle_name      => NULL,
         in_phone            => in_phone_num,
         in_shp_add1         => in_shp_address1,
         in_shp_add2         => in_shp_address2,
         in_shp_fax          => NULL,
         in_shp_city         => in_shp_city,
         in_shp_st           => in_shp_state,
         in_shp_zip          => in_shp_zip,
         in_bil_add1         => in_bil_address1,
         in_bil_add2         => in_bil_address2,
         in_bil_fax          => NULL,
         in_bil_city         => in_bil_city,
         in_bil_st           => in_bil_state,
         in_bil_zip          => in_bil_zip,
         in_email            => in_login_name,
         in_email_status     => NULL,
         in_roadside_status  => NULL,
         in_no_name_flag     => NULL,
         in_no_phone_flag    => NULL,
         in_no_address_flag  => NULL,
         in_sourcesystem     => NULL,
         in_brand_name       => upper(in_brand_name),
         in_do_not_email     => NULL,
         in_do_not_phone     => NULL,
         in_do_not_mail      => NULL,
         in_do_not_sms       => NULL,
         in_ssn              => NULL,
         in_dob              => in_dob,
         in_do_not_mobile_ads => NULL,
         out_contact_objid    => l_contact_objid,
         out_err_code         => l_err_code,
         out_err_msg          => l_err_msg);
    EXCEPTION
        WHEN OTHERS
        THEN
        out_err_num := SQLCODE;
        out_err_msg := SUBSTR(SQLERRM, 1, 200);
    END;

    IF l_err_code = 0 THEN
        l_user_ref_objid := sequ_user_referrers.NEXTVAL;
        l_webuser_objid  := sa.seq('web_user');
        INSERT INTO table_web_user (objid, login_name, s_login_name, password, user_key,
                                    status, passwd_chg, dev, ship_via, x_secret_questn,
                                    s_x_secret_questn, x_secret_ans, s_x_secret_ans, web_user2contact, web_user2bus_org
                                   )
                            VALUES (l_webuser_objid, in_login_name, upper(in_login_name), in_password, NULL,
                                    NULL, NULL, NULL, NULL, in_secret_questn,
                                    upper(in_secret_questn), in_secret_ans, upper(in_secret_ans),l_contact_objid, r_org_id.objid
                                   );
        INSERT INTO x_user_referrers (objid, x_program_id,
                                      x_validated, x_create_date, x_user_ref2contact, x_user_ref2webuser,x_client_status)
                              VALUES (l_user_ref_objid,(SELECT rp.x_program_id
                                                          FROM x_referral_programs rp
                                                         WHERE rp.x_referral_program2bus_org = r_org_id.objid),
                                      0, SYSDATE, l_contact_objid, l_webuser_objid, UPPER(in_client_status)
                                     );
        COMMIT;
        out_user_ref_objid := l_user_ref_objid;
        out_web_user_objid := l_webuser_objid;
        out_err_num := 0;
        out_err_msg := 'Success';
    ELSE
    out_err_num := l_err_code;
    out_err_msg := SUBSTR(l_err_msg, 1, 200);
    END IF;

EXCEPTION
    WHEN OTHERS
    THEN
    out_err_num := SQLCODE;
    out_err_msg := SUBSTR(SQLERRM, 1, 200);
END sp_create_referrer_acnt;
--------------------------------------------------------
-- THIS PROCEDURE WILL UPDATE THE REFERRER TABLE FOR THE EXISTING REFERRER ACCOUNTS.
PROCEDURE sp_update_referrer_acnt (
    in_user_ref_objid       IN     x_user_referrers.objid%TYPE,
    in_ref_id               IN     x_user_referrers.x_referrer_id%TYPE,
    in_ref_promo_code       IN     x_user_referrers.x_ref_promo_code%TYPE,
    in_cashcard_da          IN     x_user_referrers.x_cashcard_da%TYPE,
    in_cashcard_proxy       IN     x_user_referrers.x_cashcard_proxy%TYPE,
    in_cashcard_person_id   IN     x_user_referrers.x_cashcard_person_id%TYPE,
    in_client_acnt_id       IN     x_user_referrers.x_client_acnt_id%TYPE,
    in_client_acnt_num      IN     x_user_referrers.x_client_acnt_num%TYPE,
    in_client_status        IN     x_user_referrers.x_client_status%TYPE,
    in_valid                IN     x_user_referrers.x_validated%TYPE,
    in_payment_type         IN     x_user_referrers.x_payout_option%TYPE,
    out_err_num                OUT NUMBER,
    out_err_msg                OUT VARCHAR2)
IS
    l_user_exist   PLS_INTEGER := 0;
    v_proc_name    VARCHAR2(80):= 'SAFELINK_REFER4CASH_PKG.SP_UPDATE_REFERRER_ACNT';

    CURSOR c_user_referrer
    IS
        SELECT 1
          FROM x_user_referrers
         WHERE objid = in_user_ref_objid;
BEGIN
    out_err_num := 0;

    OPEN c_user_referrer;
    FETCH c_user_referrer INTO l_user_exist;
    IF c_user_referrer%FOUND
    THEN
        BEGIN
            UPDATE x_user_referrers
               SET x_referrer_id        = NVL(in_ref_id,x_referrer_id),
                   x_ref_promo_code     = NVL(LOWER(in_ref_promo_code),x_ref_promo_code),
                   x_cashcard_da        = NVL(in_cashcard_da,x_cashcard_da),
                   x_cashcard_proxy     = NVL(in_cashcard_proxy,x_cashcard_proxy),
                   x_cashcard_person_id = NVL(in_cashcard_person_id,x_cashcard_person_id),
                   x_client_acnt_id     = NVL(in_client_acnt_id,x_client_acnt_id),
                   x_client_acnt_num    = NVL(in_client_acnt_num,x_client_acnt_num),
                   x_validated          = NVL(in_valid,x_validated),
                   x_payout_option      = NVL(UPPER(in_payment_type),x_payout_option),
                   x_client_status             = NVL(UPPER(in_client_status),x_client_status),
                   x_update_date        = SYSDATE
             WHERE objid = in_user_ref_objid;

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
              out_err_num := SQLCODE;
              out_err_msg := SUBSTR(SQLERRM, 1, 200);
              ota_util_pkg.err_log('objid: '||in_user_ref_objid||' Ref_id: '||in_ref_id||' acnt_da: '||in_cashcard_da,
                                     SYSDATE , 'UPDATE Block failed', v_proc_name, 'SQL ERROR CODE : '|| TO_CHAR (SQLCODE)|| ' ERROR MESSAGE : '|| SUBSTR(SQLERRM, 1, 200));
            RETURN;
        END;
        out_err_num := 0;
        out_err_msg := 'Success';
    ELSE
        out_err_num := 906;
        out_err_msg := sa.get_code_fun('SAFELINK_REFER4CASH_PKG', '906','ENGLISH'); ---INSERT/UPDATE FAILED
        ota_util_pkg.err_log('objid: '||in_user_ref_objid||' Ref_id: '||in_ref_id||' acnt_da: '||in_cashcard_da,
                             SYSDATE , 'UPDATE failed objid NOT found', v_proc_name, 'UPDATE x_user_referrers,OBJID NOT FOUND');

    END IF;

    CLOSE c_user_referrer;
EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.put_line ('chk error_table');
        out_err_num := SQLCODE;
        out_err_msg := SUBSTR(SQLERRM, 1, 200);
        ota_util_pkg.err_log('objid: '||in_user_ref_objid||' Ref_id: '||in_ref_id||' acnt_da: '||in_cashcard_da,
                             SYSDATE , 'Main Exception', v_proc_name, 'SQL ERROR CODE : '|| TO_CHAR (SQLCODE)|| ' ERROR MESSAGE : '|| SUBSTR(SQLERRM, 1, 200));
END sp_update_referrer_acnt;

--------------------------------------------------------
--THIS PROCEDURE WILL UPDATE THE CONTACT AND WEB USER INFORMATION FOR THE EXISTING REFERRER ACCOUNTS.
PROCEDURE sp_upd_referrer_personal_info (
    in_web_objid         IN     table_web_user.objid%TYPE,
    in_current_email     IN     table_web_user.s_login_name%TYPE,
    in_brand_name        IN     table_bus_org.s_org_id%TYPE,
    in_new_email         IN     table_contact.e_mail%TYPE,
    in_new_pass          IN     table_web_user.password%TYPE,
    in_fname             IN     table_contact.first_name%TYPE,
    in_lname             IN     table_contact.last_name%TYPE,
    in_phone_num         IN     table_contact.x_mobilenumber%TYPE,
    in_dob               IN     table_contact.x_dateofbirth%TYPE,
    in_x_secret_questn   IN     table_web_user.x_secret_questn%TYPE,
    in_x_secret_ans      IN     table_web_user.x_secret_ans%TYPE,
    in_bil_address1      IN     table_contact.address_1%TYPE,
    in_bil_address2      IN     table_contact.address_2%TYPE,
    in_bil_city          IN     table_contact.city%TYPE,
    in_bil_state         IN     table_contact.state%TYPE,
    in_bil_country       IN     table_contact.country%TYPE,
    in_bil_zip           IN     table_contact.zipcode%TYPE,
    in_shp_address1      IN     table_contact.address_1%TYPE,
    in_shp_address2      IN     table_contact.address_2%TYPE,
    in_shp_city          IN     table_contact.city%TYPE,
    in_shp_state         IN     table_contact.state%TYPE,
    in_shp_country       IN     table_contact.country%TYPE,
    in_shp_zip           IN     table_contact.zipcode%TYPE,
    out_err_num             OUT NUMBER,
    out_err_msg             OUT VARCHAR2)
IS

   CURSOR c_user_ref
   IS
   SELECT w.web_user2bus_org,
          w.s_login_name loginid,
          re.x_user_ref2contact
     FROM x_user_referrers re,table_web_user w
    WHERE re.x_user_ref2webuser = w.objid
      AND w.objid = in_web_objid;
    r_user_ref    c_user_ref%ROWTYPE;

   CURSOR c_tbl_add(p_cnt_objid IN NUMBER)
   IS
   SELECT ts.cust_primaddr2address,
          ts.cust_billaddr2address,
          ts.cust_shipaddr2address
     FROM table_site ts, table_contact_role cr
    WHERE cr.contact_role2site = ts.objid
      AND cr.contact_role2contact = p_cnt_objid;
    r_tbl_add    c_tbl_add%ROWTYPE;

    l_bil_add_objid      NUMBER          := NULL;
    l_out_user_ref_objid NUMBER          := NULL;
    l_out_err_num        NUMBER          := NULL;
    l_out_err_msg        VARCHAR2(200)   := NULL;
    v_proc_name          VARCHAR2(80)    := 'SAFELINK_REFER4CASH_PKG.SP_UPD_REFERRER_PERSONAL_INFO';

BEGIN
        OPEN c_user_ref;
        FETCH c_user_ref INTO r_user_ref;
            IF c_user_ref%FOUND
            THEN
                UPDATE table_web_user
                   SET password        = NVL(in_new_pass,password)
                 WHERE objid = in_web_objid;

                IF in_x_secret_questn IS NOT NULL AND in_x_secret_ans IS NOT NULL
                THEN
                    UPDATE table_web_user
                       SET x_secret_questn      = in_x_secret_questn,
                           x_secret_ans         = in_x_secret_ans,
                           x_last_update_date   = SYSDATE
                     WHERE objid = in_web_objid;
                END IF;

                UPDATE table_contact
                   SET phone    = NVL(in_phone_num,phone)
                 WHERE objid    = r_user_ref.x_user_ref2contact;

                IF in_shp_address1 IS NOT NULL
                THEN
                    UPDATE table_contact
                       SET address_1       = in_shp_address1,
                           address_2       = in_shp_address2,
                           city            = in_shp_city,
                           state           = in_shp_state,
                           country         = in_shp_country,
                           zipcode         = in_shp_zip
                     WHERE objid = r_user_ref.x_user_ref2contact;
                END IF;

                IF in_bil_address1 IS NOT NULL
                THEN
                    OPEN  c_tbl_add(r_user_ref.x_user_ref2contact);
                    FETCH c_tbl_add INTO r_tbl_add;
                    CLOSE c_tbl_add;
                     UPDATE table_address
                       SET address         = in_bil_address1,
                           s_address       = upper(in_bil_address1),
                           address_2       = in_bil_address2,
                           city            = in_bil_city,
                           s_city          = upper(in_bil_city),
                           state           = in_bil_state,
                           s_state         = upper(in_bil_state),
                           address2country = (SELECT objid FROM table_country WHERE s_name = upper(in_bil_country)),
                           zipcode         = in_bil_zip,
                           update_stamp    = SYSDATE
                     WHERE objid = r_tbl_add.cust_billaddr2address;
                END IF;

                COMMIT;
                out_err_num := 0;
                out_err_msg := 'Success';
            ELSE
                out_err_num := 800;
                out_err_msg := sa.get_code_fun('WALMART_MONTHLY_PLANS_PKG', '800','ENGLISH'); ---CURSOR NOT FOUND
            END IF ;
        CLOSE c_user_ref;
EXCEPTION
    WHEN OTHERS
    THEN
       out_err_num := SQLCODE;
       out_err_msg := SUBSTR(SQLERRM, 1, 200);
       DBMS_OUTPUT.put_line(SUBSTR(SQLERRM, 1, 200));
       ota_util_pkg.err_log('Web objid: '||in_web_objid||' Current email: '||in_current_email||' New email: '||in_new_email,
                            SYSDATE , 'Main Exception', v_proc_name, 'SQL ERROR CODE : '|| TO_CHAR (SQLCODE)|| ' ERROR MESSAGE : '|| SUBSTR(SQLERRM, 1, 200));
END sp_upd_referrer_personal_info;
--------------------------------------------------------
--THIS PROCEDURE WILL RETRIEVE THE SAFELINK FRIENDS ACCOUNT INFORMATION DEPENDING UPON THE GIVEN INPUT.
PROCEDURE sp_get_referrer_acnt_info (
    in_ref_id           IN       x_user_referrers.x_referrer_id%TYPE,
    in_client_acnt_id   IN       x_user_referrers.x_client_acnt_id%TYPE,
    in_client_acnt_num  IN       x_user_referrers.x_client_acnt_num%TYPE,
    in_cashcard_prsn_id IN       x_user_referrers.x_cashcard_person_id%TYPE,
    in_ref_promocode    IN       x_user_referrers.x_ref_promo_code%TYPE,
    in_loginid          IN       table_web_user.s_login_name%TYPE,
    in_pswd             IN       table_web_user.password%TYPE,
    in_brand            IN       table_bus_org.s_name%TYPE,
    out_ref_objid            OUT x_user_referrers.objid%TYPE,
    out_ref_id               OUT x_user_referrers.x_referrer_id%TYPE,
    out_program_id           OUT x_user_referrers.x_program_id%TYPE,
    out_ref_promo_code       OUT x_user_referrers.x_ref_promo_code%TYPE,
    out_cashcard_da          OUT x_user_referrers.x_cashcard_da%TYPE,
    out_cashcard_proxy       OUT x_user_referrers.x_cashcard_proxy%TYPE,
    out_cashcard_person_id   OUT x_user_referrers.x_cashcard_person_id%TYPE,
    out_client_acnt_id       OUT x_user_referrers.x_client_acnt_id%TYPE,
    out_client_acnt_num      OUT x_user_referrers.x_client_acnt_num%TYPE,
    out_client_status        OUT x_user_referrers.x_client_status%TYPE,
    out_valid                OUT x_user_referrers.x_validated%TYPE,
    out_payment_type         OUT x_user_referrers.x_payout_option%TYPE,
    out_fname                OUT table_contact.first_name%TYPE,
    out_lname                OUT table_contact.last_name%TYPE,
    out_email                OUT table_contact.e_mail%TYPE,
    out_phone_num            OUT table_contact.x_mobilenumber%TYPE,
    out_dob                  OUT table_contact.x_dateofbirth%TYPE,
    out_web_objid            OUT table_web_user.objid%TYPE,
    out_x_secret_questn      OUT table_web_user.x_secret_questn%TYPE,
    out_x_secret_ans         OUT table_web_user.x_secret_ans%TYPE,
    out_bil_address1         OUT table_contact.address_1%TYPE,
    out_bil_address2         OUT table_contact.address_2%TYPE,
    out_bil_city             OUT table_contact.city%TYPE,
    out_bil_state            OUT table_contact.state%TYPE,
    out_bil_country          OUT table_contact.country%TYPE,
    out_bil_zip              OUT table_contact.zipcode%TYPE,
    out_shp_address1         OUT table_contact.address_1%TYPE,
    out_shp_address2         OUT table_contact.address_2%TYPE,
    out_shp_city             OUT table_contact.city%TYPE,
    out_shp_state            OUT table_contact.state%TYPE,
    out_shp_country          OUT table_contact.country%TYPE,
    out_shp_zip              OUT table_contact.zipcode%TYPE,
    out_err_num              OUT NUMBER,
    out_err_msg              OUT VARCHAR2)

IS
    CURSOR c_user_ref
    IS
    SELECT re.objid,
           re.x_user_ref2contact,
           re.x_user_ref2webuser,
           w.s_login_name
      FROM x_user_referrers re, table_web_user w
     WHERE re.x_user_ref2webuser = w.objid
       AND NVL(w.s_login_name,1)        = NVL(UPPER(in_loginid),NVL(w.s_login_name,1))
       AND nvl(re.x_ref_promo_code,1)   = NVL(LOWER(in_ref_promocode), NVL(re.x_ref_promo_code,1))
       AND NVL(re.x_client_acnt_id,1)   = NVL(in_client_acnt_id,NVL(re.x_client_acnt_id,1))
       AND NVL(re.x_client_acnt_num,1)  = NVL(in_client_acnt_num,NVL(re.x_client_acnt_num,1))
       AND NVL(re.x_referrer_id,1)      = NVL(in_ref_id,NVL(re.x_referrer_id,1));

    r_user_ref     c_user_ref%ROWTYPE;

    v_proc_name  VARCHAR2(80):= 'SAFELINK_REFER4CASH_PKG.SP_GET_REFERRER_ACNT_INFO';

BEGIN
    out_err_num := 0;
    OPEN c_user_ref;
    FETCH c_user_ref INTO r_user_ref;
    IF c_user_ref%FOUND
    THEN
    SELECT re.x_program_id,
           re.x_referrer_id,
           re.x_ref_promo_code,
           re.x_cashcard_da,
           re.x_cashcard_proxy,
           re.x_cashcard_person_id,
           re.x_client_acnt_id,
           re.x_client_acnt_num,
           re.x_validated,
           re.x_payout_option,
           re.x_client_status
      INTO out_program_id,
           out_ref_id,
           out_ref_promo_code,
           out_cashcard_da,
           out_cashcard_proxy,
           out_cashcard_person_id,
           out_client_acnt_id,
           out_client_acnt_num,
           out_valid,
           out_payment_type,
           out_client_status
      FROM x_user_referrers re
     WHERE re.objid = r_user_ref.objid;

    SELECT w.x_secret_questn,
           w.x_secret_ans
      INTO out_x_secret_questn,
           out_x_secret_ans
      FROM table_web_user w
     WHERE w.objid = r_user_ref.x_user_ref2webuser;

    SELECT c.s_first_name,
           c.s_last_name,
           c.e_mail,
           c.phone,
           c.x_dateofbirth,
           c.address_1,
           c.address_2,
           c.city,
           c.state,
           c.country,
           c.zipcode
      INTO out_fname,
           out_lname,
           out_email,
           out_phone_num,
           out_dob,
           out_shp_address1,
           out_shp_address2,
           out_shp_city,
           out_shp_state,
           out_shp_country,
           out_shp_zip
      FROM table_contact c
     WHERE c.objid = r_user_ref.x_user_ref2contact;


    SELECT ta.s_address,
           ta.address_2,
           ta.s_city,
           ta.s_state,
           ta.zipcode,
           tc.s_name
      INTO out_bil_address1,
           out_bil_address2,
           out_bil_city,
           out_bil_state,
           out_bil_zip,
           out_bil_country
      FROM table_address ta, table_site ts, table_contact_role cr, table_country tc
     WHERE cr.contact_role2site = ts.objid
       AND ts.cust_billaddr2address = ta.objid
       AND ta.address2country = tc.objid
       AND cr.contact_role2contact = r_user_ref.x_user_ref2contact;

    out_ref_objid := r_user_ref.objid;
    out_web_objid := r_user_ref.x_user_ref2webuser;
    out_err_num := 0;
    out_err_msg := 'SUCCESS';


    ELSE
    --dbms_output.put_line('%NOTFOUND');
    out_err_num := 800;
    out_err_msg := sa.get_code_fun('WALMART_MONTHLY_PLANS_PKG', '800','ENGLISH'); ---CURSOR NOT FOUND
    END IF;
    CLOSE c_user_ref;

EXCEPTION
    WHEN OTHERS
    THEN
    out_err_num := SQLCODE;
    out_err_msg := SUBSTR(SQLERRM, 1, 200);
    ota_util_pkg.err_log('Ref PromoCode: '||in_ref_promocode||' Ref ID: '||in_ref_id,
                         SYSDATE , 'Main Exception', v_proc_name, 'SQL ERROR CODE : '|| TO_CHAR (SQLCODE)|| ' ERROR MESSAGE : '|| SUBSTR(SQLERRM, 1, 200));

END sp_get_referrer_acnt_info;
--------------------------------------------------------
-- FUNCTION TO GET STATUS OF THE REFERER ACCOUNT
FUNCTION get_client_status (in_login    table_web_user.s_login_name%TYPE,
                            in_brand    table_bus_org.s_org_id%TYPE)
    RETURN x_user_referrers.x_client_status%TYPE
IS
    l_status   x_user_referrers.x_client_status%TYPE;
BEGIN
    SELECT re.x_client_status
      INTO l_status
      FROM x_user_referrers re, table_web_user w, table_bus_org bo
     WHERE     re.x_user_ref2webuser = w.objid
           AND bo.objid = w.web_user2bus_org
           AND w.s_login_name = UPPER (in_login)
           AND bo.s_org_id = UPPER (in_brand);

    IF l_status IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN l_status;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        RETURN NULL;
END get_client_status;
END;
/
CREATE OR REPLACE PACKAGE BODY sa.esn_account IS
 /****************************************************************************
  ****************************************************************************
  * $Revision: 1.23 $
  * $Author: oimana $
  * $Date: 2018/03/28 19:53:28 $
  * $Log: ESN_ACCOUNT_PKB.sql,v $
  * Revision 1.23  2018/03/28 19:53:28  oimana
  * CR57178 - Package Body
  *
  * Revision 1.18  2018/03/26 16:54:55  oimana
  * CR57178 - Package Body
  *
  *
  *****************************************************************************
  *****************************************************************************/
--
--
 CURSOR get_webuser_info (ip_web_user_objid IN table_web_user.objid%TYPE)
 IS
 SELECT web.*,
        bo.org_id
 FROM   sa.table_web_user web,
        sa.table_bus_org bo
 WHERE  web.objid = ip_web_user_objid
 AND    bo.objid = web.web_user2bus_org;

 get_webuser_info_rec get_webuser_info%ROWTYPE;

 CURSOR get_contact (ip_contact_objid IN table_contact.objid%TYPE)
 IS
 SELECT tc.*
 FROM   sa.table_contact tc
 WHERE  tc.objid = ip_contact_objid;

 get_contact_rec get_contact%ROWTYPE;

 CURSOR get_esn_info (ip_esn IN table_part_inst.part_serial_no%TYPE)
 IS
 SELECT pi.objid,
        pi.x_part_inst2contact,
        web.objid web_user_objid,
        web.web_user2bus_org,
        pn.part_num2bus_org,
        conpi.x_is_default,
        conpi.x_esn_nick_name,
        bo.org_id,
        pi.x_part_inst_status,
        pi.part_serial_no,
        pn.x_technology,
        pn.part_number,
        pc.name class_name,
        sa.get_param_by_name_fun (pc.name, 'DEVICE_TYPE') device_type,
        c.first_name,
        c.last_name
 FROM   sa.table_part_inst pi,
        sa.table_x_contact_part_inst conpi,
        sa.table_web_user web,
        sa.table_mod_level ml,
        sa.table_part_num pn,
        sa.table_bus_org bo,
        sa.table_part_class pc,
        sa.table_contact c
 WHERE  pi.part_serial_no = ip_esn
 AND    pi.x_domain = 'PHONES'
 AND    conpi.x_contact_part_inst2part_inst(+) = pi.objid
 AND    web.web_user2contact(+) = conpi.x_contact_part_inst2contact
 AND    ml.objid = pi.n_part_inst2part_mod
 AND    pn.objid = ml.part_info2part_num
 AND    bo.objid = pn.part_num2bus_org
 AND    pc.objid = pn.part_num2part_class
 AND    c.objid(+) = pi.x_part_inst2contact;

 get_esn_info_rec get_esn_info%ROWTYPE;

 CURSOR get_enroll_info (ip_esn IN table_part_inst.part_serial_no%TYPE)
 IS
 SELECT pe.*,
        pp.x_prog_class
 FROM   sa.x_program_enrolled pe,
        sa.x_program_parameters pp,
        sa.table_part_inst pi
 WHERE  pe.x_esn = ip_esn
 AND    pe.x_enrollment_status NOT IN('DEENROLLED', 'ENROLLMENTFAILED', 'READYTOREENROLL')
 AND    pp.objid = pe.pgm_enroll2pgm_parameter
 AND    pp.x_prog_class <> 'WARRANTY'
 AND    pi.part_serial_no = pe.x_esn
 AND    pi.x_domain = 'PHONES'
 AND    pi.x_part_inst_status = '52';

 get_enroll_info_rec get_enroll_info%ROWTYPE;

--
--
PROCEDURE esn_account_contact (p_zip                IN  VARCHAR2,
                               p_phone              IN  VARCHAR2,
                               p_f_name             IN  VARCHAR2,
                               p_l_name             IN  VARCHAR2,
                               p_m_init             IN  VARCHAR2,
                               p_add_1              IN  VARCHAR2,
                               p_add_2              IN  VARCHAR2,
                               p_city               IN  VARCHAR2,
                               p_st                 IN  VARCHAR2,
                               p_country            IN  VARCHAR2,
                               p_fax                IN  VARCHAR2,
                               p_email              IN  VARCHAR2,
                               p_dob                IN  VARCHAR2,                                       --(String mm/dd/yyyy format)
                               ip_do_not_phone      IN  table_x_contact_add_info.x_do_not_phone%TYPE,   -- (NEW)
                               ip_do_not_mail       IN  table_x_contact_add_info.x_do_not_mail%TYPE,    -- (NEW)
                               ip_do_not_sms        IN  table_x_contact_add_info.x_do_not_sms%TYPE,     -- (NEW)
                               ip_prer_consent      IN  table_x_contact_add_info.x_prerecorded_consent%TYPE,
                               ip_mobile_ads        IN  table_x_contact_add_info.x_do_not_mobile_ads%TYPE,
                               ip_pin               IN  table_x_contact_add_info.x_pin%TYPE,
                               ip_squestion         IN  table_web_user.x_secret_questn%TYPE,
                               ip_sanswer           IN  table_web_user.x_secret_ans%TYPE,
                               ip_email             IN  NUMBER,           -- 1:create a dummy account, 0: email should be provided
                               ip_overwrite_esn     IN  NUMBER,           -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                               ip_do_not_email      IN  NUMBER,           -- 1: Not Allow email communivations, 0: Allow email communications
                               p_brand              IN  VARCHAR2,         -- (creating a contact only)
                               p_pw                 IN  table_web_user.password%TYPE,        -- (creating a contact only)
                               p_c_objid            IN  NUMBER,           -- (updating a contact only)
                               p_esn                IN  table_part_inst.part_serial_no%TYPE, -- (Add ESN to Account)
                               ip_user              IN  sa.table_user.s_login_name%TYPE,
                               p_shipping_address1  IN  VARCHAR2,
                               p_shipping_address2  IN  VARCHAR2,
                               p_shipping_city      IN  VARCHAR2,
                               p_shipping_state     IN  VARCHAR2,
                               p_shipping_zip       IN  VARCHAR2,
                               p_language           IN  VARCHAR2,
                               ip_esn_nick_name     IN  VARCHAR2,
                               ip_sourcesystem      IN  VARCHAR2,
                               op_web_user_objid    OUT table_web_user.objid%TYPE,
                               op_contact_objid     OUT NUMBER,
                               op_err_code          OUT VARCHAR2,
                               op_out_msg           OUT VARCHAR2) AS

 CURSOR contact (c_phone      IN table_contact.phone%TYPE,
                 c_first_name IN table_contact.s_first_name%TYPE,
                 c_last_name  IN table_contact.s_last_name%TYPE)
 IS
 SELECT c.objid
 FROM   sa.table_contact c
 WHERE  c.phone = c_phone
 AND    c.s_first_name || '' = UPPER(c_first_name)
 AND    c.s_last_name  || '' = UPPER(c_last_name);

 contact_rec contact%ROWTYPE;

 CURSOR link2address (c_objid IN table_contact.objid%TYPE)
 IS
 SELECT s.cust_primaddr2address,
        s.objid site_objid
 FROM   sa.table_contact_role cr,
        sa.table_site s
 WHERE  cr.contact_role2contact = c_objid
 AND    cr.primary_site = 1
 AND    s.objid = cr.contact_role2site;

 link2address_rec link2address%ROWTYPE;

 CURSOR zip_curs
 IS
 SELECT *
 FROM sa.table_x_zip_code
 WHERE x_zip = p_zip;

 zip_curs_rec zip_curs%ROWTYPE;

 CURSOR brand_cur
 IS
 SELECT bo.org_id
 FROM   sa.table_bus_org bo,
        sa.table_part_inst pi,
        sa.table_mod_level ml,
        sa.table_part_num pn
 WHERE  pi.part_serial_no = p_esn
 AND    pi.x_domain = 'PHONES'
 AND    pi.n_part_inst2part_mod = ml.objid
 AND    ml.part_info2part_num = pn.objid
 AND    pn.part_num2bus_org = bo.objid
 AND    bo.org_id <> 'GENERIC';

 brand_rec         brand_cur%ROWTYPE;
 v_country_objid   NUMBER;
 v_country         VARCHAR2 (40);
 v_c_objid         NUMBER;
 v_err_code        VARCHAR2 (4000);
 v_err_msg         VARCHAR2 (4000);
 v_cnt             NUMBER;
 v_web_user_objid  NUMBER;
 v_group_id        VARCHAR2 (30);
 --
 FUNCTION get_country (p_country IN VARCHAR2)
 RETURN VARCHAR2 IS
   v_country sa.table_country.name%TYPE;
 BEGIN

   BEGIN
     SELECT name
     INTO v_country
     FROM table_country
     WHERE s_name = UPPER (p_country);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       BEGIN
         SELECT name
         INTO v_country
         FROM table_country
         WHERE objid = p_country;
       EXCEPTION
         WHEN OTHERS THEN
           v_country := NULL;
       END;
     WHEN OTHERS THEN
       v_country := NULL;
   END;

   IF v_country IS NULL THEN
     v_country := 'USA';
   END IF;

   RETURN v_country;

 EXCEPTION
   WHEN OTHERS THEN
     v_country := 'USA'; --default value
 END get_country;
 --
 BEGIN

  op_err_code      := NULL;
  op_out_msg       := NULL;

 /*---------------------------------------------------------------------*/
 /* Validate input parameters */
 /*---------------------------------------------------------------------*/

 IF (ip_pin IS NOT NULL AND (LENGTH (NVL (ip_pin, '0')) < 4 OR (LENGTH (NVL(ip_pin, '0')) > 5))) THEN
   op_err_code := '01198';
   op_out_msg  := 'ERROR: Invalid Security PIN, this could be 4 or 5 digits.';
   RETURN;
 END IF;

 IF ADD_MONTHS(TO_DATE(p_dob, 'MM/DD/YYYY'), 13 * 12) > TRUNC(SYSDATE) THEN
   op_err_code := '01199';
   op_out_msg  := 'ERROR-01199 SA.ESN_ACCOUNT_CONTACT : Contact age is not allowed, please check DOB';
   RETURN;
 END IF;

 IF p_zip IS NOT NULL AND p_country = 'USA' THEN

   OPEN zip_curs;
   FETCH zip_curs INTO zip_curs_rec;

   IF zip_curs%NOTFOUND THEN
     CLOSE zip_curs;
     op_err_code := '01200';
     op_out_msg  := 'ERROR-01200 ESN_ACCOUNT_CONTACT: Invalid Zipcode';
     RETURN;
   END IF;

   CLOSE zip_curs;

 END IF;

 /*---------------------------------------------------------------------*/
 /* Check that don't exist a contact with same name and phone */
 /*---------------------------------------------------------------------*/
 IF p_c_objid IS NULL THEN

   OPEN contact (p_phone, p_f_name, p_l_name);
   FETCH contact INTO contact_rec;

   IF contact%FOUND THEN
     CLOSE contact;
     op_err_code := '01201';
     op_out_msg  := 'ERROR-01201 ESN_ACCOUNT_CONTACT: Contact Already Exists for that name and phone ';
     RETURN;
   END IF;

   CLOSE contact;

   /*---------------------------------------------------------------------*/  
   -- Check brand name
   /*---------------------------------------------------------------------*/
   SELECT COUNT(1)
   INTO   v_cnt
   FROM   sa.table_bus_org
   WHERE  org_id = p_brand;

   IF v_cnt = 0 THEN
     op_err_code := '01202';
     op_out_msg  := 'ERROR-01202 ESN_ACCOUNT_CONTACT: Brand name is invalid';
     RETURN;
   END IF;

   /*---------------------------------------------------------------------*/
   -- Check PIN Mandatory for TOTAL WIRELESS BRANDS
   /*---------------------------------------------------------------------*/
   -- REL736_Core 3/30/2016 - Defect 716 fix
   IF (ip_pin IS NULL AND p_brand = 'TOTAL_WIRELESS') THEN
     op_err_code := '01203';
     op_out_msg  := 'ERROR-01203 ESN_ACCOUNT_CONTACT: Please provide 4 Digits Security PIN';
     RETURN;
   END IF;

   /*---------------------------------------------------------------------*/
   -- CREATE CONTACT INFO IF CONTACT AND ADDRESS OBJID MISSING
   /*---------------------------------------------------------------------*/
   sa.CONTACT_PKG.createcontact_prc (p_esn                 => NULL,
                                     p_first_name          => p_f_name,
                                     p_last_name           => p_l_name,
                                     p_middle_name         => p_m_init,
                                     p_phone               => p_phone,
                                     p_add1                => p_add_1,
                                     p_add2                => p_add_2,
                                     p_fax                 => p_fax,
                                     p_city                => p_city,
                                     p_st                  => p_st,
                                     p_zip                 => p_zip,
                                     p_email               => p_email,
                                     p_email_status        => 0,
                                     p_roadside_status     => 0,
                                     p_no_name_flag        => NULL,
                                     p_no_phone_flag       => NULL,
                                     p_no_address_flag     => NULL,
                                     p_sourcesystem        => ip_sourcesystem,         -- Check what value to be passed here as source system
                                     p_brand_name          => p_brand,
                                     p_do_not_email        => NVL(ip_do_not_email, 1), -- CR51354_Log_history_for_OPT_INOUT_on_communications 10/18/17 Tim Changed to user provided values
                                     p_do_not_phone        => NVL(ip_do_not_phone, 1), -- ip_do_not_email, ip_do_not_phone, ip_do_not_mail, ip_do_not_sms, ip_do_not_sms
                                     p_do_not_mail         => NVL(ip_do_not_mail, 1),
                                     p_do_not_sms          => NVL(ip_do_not_sms, 1),
                                     p_ssn                 => NULL,
                                     p_dob                 => TO_DATE(p_dob, 'MM/DD/YYYY'),
                                     p_do_not_mobile_ads   => NVL(ip_do_not_sms, 1),
                                     p_contact_objid       => v_c_objid,
                                     p_err_code            => v_err_code,
                                     p_err_msg             => v_err_msg);

   IF v_err_code <> '0' THEN
     ROLLBACK;
     op_err_code := '01204';
     op_out_msg  := 'ERROR-01204 ESN_ACCOUNT_CONTACT: Unable to create contact ' || v_err_msg;
     RETURN;
   END IF;

 ELSE

   v_c_objid := p_c_objid;
   v_country := get_country (p_country);

   IF LENGTH(v_country) > 0 THEN
     SELECT objid
       INTO v_country_objid
       FROM sa.table_country
      WHERE s_name = UPPER(v_country);
   END IF;

   BEGIN
     UPDATE sa.table_contact c
        SET c.first_name       = NVL(TRIM(p_f_name), c.first_name),
            c.s_first_name     = UPPER(NVL(TRIM(p_f_name), c.s_first_name)),
            c.last_name        = NVL(TRIM(p_l_name), c.last_name),
            c.s_last_name      = UPPER(NVL(TRIM(p_l_name), c.s_last_name)),
            c.x_middle_initial = p_m_init,
            c.phone            = NVL(TRIM(p_phone), c.phone),
            c.fax_number       = p_fax,
            c.e_mail           = NVL(TRIM(UPPER(p_email)), c.e_mail),
            c.address_1        = NVL(TRIM(p_add_1), c.address_1),
            c.address_2        = p_add_2,
            c.city             = NVL(TRIM(p_city), c.city),
            c.state            = NVL(TRIM(p_st), c.state),
            c.zipcode          = NVL(TRIM(p_zip), c.zipcode),
            c.country          = DECODE(TRIM(p_country), NULL, c.country, v_country),
            c.x_dateofbirth    = NVL(TO_DATE(p_dob, 'MM/DD/YYYY'), c.x_dateofbirth),
            c.update_stamp     = SYSDATE
      WHERE objid = v_c_objid;
    EXCEPTION
      WHEN OTHERS THEN
        op_err_code := SQLCODE;
        op_out_msg  := 'ERROR ESN_ACCOUNT_CONTACT: Unable to update table sa.table_contact with objid: '||v_c_objid||' - ' || SQLERRM;
        RAISE;
    END;

   /*---------------------------------------------------------------------*/
   /*   Validate input parameters                                         */
   /*---------------------------------------------------------------------*/
   OPEN link2address (v_c_objid);
   FETCH link2address INTO link2address_rec;

   IF link2address%FOUND THEN

     IF NVL (link2address_rec.cust_primaddr2address, 0) < 0 THEN

       -- Create a new row in table_address and update the link
       SELECT sa.seq ('address')
       INTO link2address_rec.cust_primaddr2address
       FROM DUAL;

       --Insert record in table_address
       BEGIN
         INSERT INTO sa.table_address (objid,
                                       address,
                                       s_address,
                                       city,
                                       s_city,
                                       state,
                                       s_state,
                                       zipcode,
                                       address_2,
                                       dev,
                                       address2time_zone,
                                       address2country,
                                       address2state_prov,
                                       update_stamp)
              VALUES (link2address_rec.cust_primaddr2address,
                      p_add_1,
                      UPPER (p_add_1),
                      zip_curs_rec.x_city,
                      UPPER (zip_curs_rec.x_city),
                      zip_curs_rec.x_state,
                      UPPER (zip_curs_rec.x_state),
                      zip_curs_rec.x_zip,
                      p_add_2,
                      NULL,
                      (SELECT objid
                         FROM sa.table_time_zone
                        WHERE name = 'EST'
                          AND ROWNUM < 2),
                      v_country_objid,
                      (SELECT objid
                         FROM sa.table_state_prov
                        WHERE s_name = UPPER(p_st)
                          AND state_prov2country = v_country_objid),
                      SYSDATE);
       EXCEPTION
         WHEN OTHERS THEN
           op_err_code := SQLCODE;
           op_out_msg  := 'ERROR ESN_ACCOUNT_CONTACT: Unable to insert into table sa.table_address with objid: '||link2address_rec.cust_primaddr2address||' - ' || SQLERRM;
           RAISE;
       END;

       --update table_site
       BEGIN
         UPDATE sa.table_site
            SET cust_primaddr2address = link2address_rec.cust_primaddr2address
          WHERE objid = link2address_rec.site_objid;
       EXCEPTION
         WHEN OTHERS THEN
           op_err_code := SQLCODE;
           op_out_msg  := 'ERROR ESN_ACCOUNT_CONTACT: Unable to update table sa.table_site with objid: '||link2address_rec.site_objid||' - ' || SQLERRM;
           RAISE;
       END;

     ELSE

       IF LENGTH (TRIM (p_add_1))   > 0 OR
          LENGTH (TRIM (p_add_2))   > 0 OR
          LENGTH (TRIM (p_city))    > 0 OR
          LENGTH (TRIM (p_st))      > 0 OR
          LENGTH (TRIM (p_zip))     > 0 OR
          LENGTH (TRIM (p_country)) > 0 THEN

          BEGIN
          UPDATE sa.table_address a
             SET a.address = NVL(TRIM (p_add_1), a.address),
                 a.s_address = UPPER(NVL(TRIM (p_add_1), a.address)),
                 a.address_2 = p_add_2,
                 a.city = NVL(TRIM(p_city), a.city),
                 a.s_city = UPPER(NVL(TRIM (p_city), a.city)),
                 a.state = NVL(TRIM(p_st), a.state),
                 a.zipcode = NVL(TRIM(p_zip), a.zipcode),
                 a.address2country = DECODE(TRIM(p_country), NULL, a.address2country, v_country_objid),
                 a.address2state_prov = DECODE(TRIM (p_st), NULL, a.address2state_prov, NVL((SELECT objid
                                                                                               FROM table_state_prov
                                                                                               WHERE s_name = UPPER(p_st)
                                                                                                 AND state_prov2country = NVL(v_country_objid, a.address2country)),
                                                                                             a.address2state_prov)),
                 a.update_stamp = SYSDATE
           WHERE a.objid = link2address_rec.cust_primaddr2address;
          EXCEPTION
            WHEN OTHERS THEN
              op_err_code := SQLCODE;
              op_out_msg  := 'ERROR ESN_ACCOUNT_CONTACT: Unable to update table sa.table_address with objid: '||link2address_rec.cust_primaddr2address||' - ' || SQLERRM;
              RAISE;
          END;

       END IF;

     END IF;

   END IF;

   CLOSE link2address;

 END IF;

 /*------------------------------------------------------------------------------------*/
  -- Update contact additional information
 /*------------------------------------------------------------------------------------*/
 -- BROUGHT BACK ORIGINAL CODE

 BEGIN
   UPDATE sa.table_x_contact_add_info
      SET x_pin                 = NVL(ip_pin, x_pin),
          x_dateofbirth         = NVL(TO_DATE(p_dob, 'MM/DD/YYYY'), x_dateofbirth),
          x_do_not_email        = NVL(ip_do_not_email, x_do_not_email),
          x_do_not_phone        = NVL(ip_do_not_phone, x_do_not_phone),
          x_do_not_sms          = NVL(ip_do_not_sms, x_do_not_sms),
          x_do_not_mail         = NVL(ip_do_not_mail, x_do_not_mail),
          x_prerecorded_consent = NVL(ip_prer_consent, x_prerecorded_consent),
          x_do_not_mobile_ads   = NVL(ip_mobile_ads, x_do_not_mobile_ads),
          x_last_update_date    = SYSDATE,
          add_info2user         = (SELECT objid
                                     FROM sa.table_user
                                    WHERE s_login_name = UPPER (USER))
    WHERE add_info2contact = v_c_objid;
 EXCEPTION
   WHEN OTHERS THEN
     op_err_code := SQLCODE;
     op_out_msg  := 'ERROR ESN_ACCOUNT_CONTACT: Unable to update table sa.table_x_contact_add_info with objid: '||v_c_objid||' - ' || SQLERRM;
     RAISE;
 END;

 -- START NEW CODE - CR DO NOT CALL BATCH ----------------------------------------
 BEGIN
   MERGE INTO sa.adfcrm_cai_pend_batch
        USING (SELECT 1 FROM DUAL)
           ON (contact_objid = v_c_objid)
         WHEN NOT MATCHED THEN
              INSERT (contact_objid)
              VALUES (v_c_objid);
 EXCEPTION
   WHEN OTHERS THEN
     op_err_code := SQLCODE;
     op_out_msg  := 'ERROR ESN_ACCOUNT_CONTACT: Unable to insert into table sa.adfcrm_cai_pend_batch with contact_objid: '||v_c_objid||' - ' || SQLERRM;
     RAISE;
 END;

 /*------------------------------------------------------------------------------------*/
 -- Check if contact already has an account then update security question and answer
 -- otherwise create an account with ramdon and default passwd
 /*------------------------------------------------------------------------------------*/
 sa.ESN_ACCOUNT.web_user_proc (ip_webuser2contact   => v_c_objid,
                               ip_login             => p_email,
                               ip_squestion         => ip_squestion,
                               ip_sanswer           => ip_sanswer,
                               ip_pw                => p_pw,
                               ip_email             => ip_email,
                               op_web_user_objid    => v_web_user_objid,
                               op_err_code          => v_err_code,
                               op_err_msg           => v_err_msg);

 IF v_err_code <> '0' THEN
   ROLLBACK;
   op_err_code := v_err_code;
   op_out_msg := v_err_msg;
   RETURN;
 END IF;

 -- Add ESN to Account
 -- CR57178 - Allow process to create cust contact even if the ESN is invalid (TW).
 IF p_esn IS NOT NULL THEN
   sa.ESN_ACCOUNT.add_esn_to_acct (ip_web_user_objid   => v_web_user_objid,
                                   ip_esn_nick_name    => ip_esn_nick_name,   --'Default',
                                   ip_esn              => p_esn,
                                   ip_overwrite_esn    => ip_overwrite_esn,
                                   ip_user             => ip_user,
                                   ip_sourcesystem     => ip_sourcesystem,
                                   op_err_code         => v_err_code,
                                   op_err_msg          => v_err_msg);
 END IF;

 IF v_err_code <> '0' THEN
   ROLLBACK;
   op_err_code := v_err_code;
   op_out_msg  := v_err_msg;
   RETURN;
 END IF;

 COMMIT;

 op_contact_objid  := v_c_objid;
 op_web_user_objid := v_web_user_objid;
 op_err_code       := '0';
 op_out_msg        :='Success';

 RETURN;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    op_err_code := NVL(op_err_code,SQLCODE);
    op_out_msg  := NVL(op_out_msg,'ERROR ESN_ACCOUNT_CONTACT: Unable to perform action for this contact ' || SQLERRM);
    RETURN;
END esn_account_contact;
--
--
PROCEDURE copy_contact_info (op_old_contact_id   IN  table_contact.objid%TYPE,
                             ip_sourcesystem     IN  VARCHAR2,
                             op_new_contact_id   OUT table_contact.objid%TYPE,
                             op_err_code         OUT VARCHAR2,
                             op_err_msg          OUT VARCHAR2) IS

      CURSOR get_current_acctinfo (op_old_contact_id IN table_contact.objid%TYPE)
      IS
         SELECT c.objid contact_objid,
                DECODE (c.first_name, c.x_cust_id, NULL, c.first_name)
                first_name,
                DECODE (c.last_name, c.x_cust_id, NULL, c.last_name)
                last_name,
                c.x_middle_initial,
                c.fax_number,
                DECODE (c.phone, c.x_cust_id, NULL, c.phone) phone,
                c.e_mail,
                DECODE (a.address, c.x_cust_id, NULL, a.address) address,
                DECODE (a.address_2, c.x_cust_id, NULL, a.address_2)
                address_2,
                a.city,
                a.state,
                a.zipcode,
                cai.x_dateofbirth,
                bo.org_id,
                NVL (c.dev, 0) copy_counter,
                cai.x_do_not_email,  -- CR51354_Log_history_for_OPT_INOUT_on_communications 10/18/17 Tim Changed to use user provided values
                                     -- ip_do_not_email, ip_do_not_phone, ip_do_not_mail, ip_do_not_sms, ip_do_not_sms
                cai.x_do_not_phone,
                cai.x_do_not_mail,
                cai.x_do_not_sms,
                cai.x_do_not_mobile_ads
           FROM sa.table_contact c,
                sa.table_x_contact_add_info cai,
                sa.table_contact_role cr,
                sa.table_address a,
                sa.table_site s,
                sa.table_bus_org bo
          WHERE 1 = 1
            AND c.objid = op_old_contact_id
            AND c.objid = cr.contact_role2contact
            AND S.Objid = Cr.Contact_Role2site
            AND cr.primary_site = 1
            AND a.objid = s.cust_primaddr2address
            AND c.objid = cai.add_info2contact(+)
            AND cai.add_info2bus_org = bo.objid(+);

      get_current_acctinfo_rec   get_current_acctinfo%ROWTYPE;
      esn_count                  NUMBER;

BEGIN

      op_err_code := '0';
      op_err_msg  := 'Contact duplicated, Successfully';

      /*---------------------------------------------------------------------*/
      /*   get Contact info for the given ESN                                */
      /*---------------------------------------------------------------------*/
      OPEN get_current_acctinfo (op_old_contact_id);
      FETCH get_current_acctinfo INTO get_current_acctinfo_rec;

      IF get_current_acctinfo%NOTFOUND THEN
         op_err_code := '01205';
         op_err_msg  := 'ERROR-01205 ESN_ACCOUNT.COPY_CONTACT_INFO : Contact not found';

         CLOSE get_current_acctinfo;

         RETURN;                                        --Procedure stops here
      END IF;

      CLOSE get_current_acctinfo;

      --CR40766 if get_current_acctinfo_rec.copy_counter>0 then
      contact_pkg.createcontact_prc (p_esn                 => NULL,
                                     p_first_name          => get_current_acctinfo_rec.first_name || ' copy_' || TO_CHAR (get_current_acctinfo_rec.copy_counter + 1),
                                     p_last_name           => get_current_acctinfo_rec.last_name,
                                     p_middle_name         => get_current_acctinfo_rec.x_middle_initial,
                                     p_phone               => get_current_acctinfo_rec.phone,
                                     p_add1                => get_current_acctinfo_rec.address,
                                     p_add2                => get_current_acctinfo_rec.address_2,
                                     p_fax                 => get_current_acctinfo_rec.fax_number,
                                     p_city                => get_current_acctinfo_rec.city,
                                     p_st                  => get_current_acctinfo_rec.state,
                                     p_zip                 => get_current_acctinfo_rec.zipcode,
                                     p_email               => get_current_acctinfo_rec.e_mail,
                                     p_email_status        => 0,
                                     p_roadside_status     => 0,
                                     p_no_name_flag        => NULL,
                                     p_no_phone_flag       => NULL,
                                     p_no_address_flag     => NULL,
                                     p_sourcesystem        => ip_sourcesystem,--'TAS',
                                     p_brand_name          => get_current_acctinfo_rec.org_id,
                                     p_do_not_email        => get_current_acctinfo_rec.x_do_not_email, -- CR51354_Log_history_for_OPT_INOUT_on_communications 10/18/17
                                     p_do_not_phone        => get_current_acctinfo_rec.x_do_not_phone, -- ip_do_not_email, ip_do_not_phone, ip_do_not_mail, ip_do_not_sms, ip_do_not_sms
                                     p_do_not_mail         => get_current_acctinfo_rec.x_do_not_mail,
                                     p_do_not_sms          => get_current_acctinfo_rec.x_do_not_sms,
                                     p_ssn                 => NULL,
                                     p_dob                 => get_current_acctinfo_rec.x_dateofbirth,
                                     p_do_not_mobile_ads   => get_current_acctinfo_rec.x_do_not_mobile_ads,
                                     p_contact_objid       => op_new_contact_id,
                                     p_err_code            => op_err_code,
                                     p_err_msg             => op_err_msg);

      --CR40766 else reuse Account Contact if it is the first ESN in the account
      --CR40766 i  op_new_contact_id:=get_current_acctinfo_rec.contact_objid;
      --CR40766 iend if;

      UPDATE sa.table_contact
         SET dev = NVL (get_current_acctinfo_rec.copy_counter, 0) + 1
       WHERE objid = get_current_acctinfo_rec.contact_objid;

      COMMIT;

      -- DO NOT CALL UPDATE CR27859, AFTER THE CONTACT IS CREATED
      -- UPDATE MIRROR THE ADD INFO TABLE
      FOR i IN (SELECT *
                  FROM sa.table_x_contact_add_info
                 WHERE add_info2contact = op_old_contact_id) LOOP
         UPDATE sa.table_x_contact_add_info
            SET x_do_not_email = i.x_do_not_email,
                x_do_not_phone = i.x_do_not_phone,
                x_do_not_sms = i.x_do_not_sms,
                x_do_not_mail = i.x_do_not_mail,
                x_prerecorded_consent = i.x_prerecorded_consent,   -- CR56041
                x_do_not_mobile_ads = i.x_do_not_mobile_ads        -- CR56041
          WHERE add_info2contact = op_new_contact_id;
      END LOOP;

      COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    op_err_code := SQLCODE;
    op_err_msg  := TRIM (SUBSTR ('ERROR COPY_CONTACT_INFO: '
                                 || SQLERRM
                                 || CHR (10)
                                 || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000));
    RETURN;
END copy_contact_info;
--
--
PROCEDURE add_esn_to_acct (ip_web_user_objid   IN     sa.table_web_user.objid%TYPE,
                           ip_esn_nick_name    IN     sa.table_x_contact_part_inst.x_esn_nick_name%TYPE,
                           ip_esn              IN     sa.table_part_inst.part_serial_no%TYPE,
                           ip_overwrite_esn    IN     NUMBER,     -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                           ip_user             IN     sa.table_user.s_login_name%TYPE,
                           ip_sourcesystem     IN     VARCHAR2,
                           op_err_code         OUT    VARCHAR2,
                           op_err_msg          OUT    VARCHAR2) IS

      op_new_contact_id   NUMBER;
      cnt_records         NUMBER;
      v_chk               NUMBER := 0;

BEGIN

      op_err_code := '0';
      op_err_msg := 'ESN added to account, Successfully';

      /*---------------------------------------------------------------------*/
      /*   get ESN  information                                              */
      /*---------------------------------------------------------------------*/
      OPEN get_esn_info (ip_esn);
      FETCH get_esn_info INTO get_esn_info_rec;

      IF get_esn_info%NOTFOUND THEN

         DBMS_OUTPUT.PUT_LINE('ERROR-01206 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT: ESN not found');

         op_err_code := '01206';
         op_err_msg  := 'ERROR-01206 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT: ESN not found';

         CLOSE get_esn_info;

         RETURN;       --Procedure stops here -- do not stop for CR57178

      END IF;

      CLOSE get_esn_info;

      /*---------------------------------------------------------------------*/
      /*  Check if ESN is linked to the account                              */
      /*---------------------------------------------------------------------*/

      IF NVL (get_esn_info_rec.web_user_objid, -1) = ip_web_user_objid AND get_esn_info_rec.part_serial_no IS NOT NULL THEN
         op_err_code := '01207';
         op_err_msg  := 'ERROR-01207 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : ESN already linked to the account';
         RETURN;                                        --Procedure stops here
      END IF;

      /*---------------------------------------------------------------------*/
      /*   Check if ESN is enrolled in autorefill program                    */
      /*---------------------------------------------------------------------*/
      OPEN get_enroll_info (ip_esn);
      FETCH get_enroll_info INTO get_enroll_info_rec;

      IF get_enroll_info%FOUND THEN

         cnt_records := 1;         --assumption: the esn belongs to an account

         IF get_enroll_info_rec.pgm_enroll2web_user IS NULL THEN
            --check if ESN belongs to any account
            SELECT COUNT (1)
              INTO cnt_records
              FROM sa.table_part_inst pi,
                   sa.table_x_contact_part_inst conpi,
                   sa.table_web_user web
             WHERE pi.part_serial_no = get_enroll_info_rec.x_esn
                   AND pi.x_domain = 'PHONES'
                   AND conpi.x_contact_part_inst2part_inst = pi.objid
                   AND web.web_user2contact = conpi.x_contact_part_inst2contact;
         END IF;

         IF cnt_records > 0 THEN
            op_err_code := '01208';
            op_err_msg := 'ERROR-01208 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : ESN is enrolled in autorefill program';

            CLOSE get_enroll_info;

            RETURN;                                     --Procedure stops here
         END IF;

      END IF;

      CLOSE get_enroll_info;

      /*---------------------------------------------------------------------*/
      /*  Get target account information                                     */
      /*---------------------------------------------------------------------*/
      OPEN get_webuser_info (ip_web_user_objid);
      FETCH get_webuser_info INTO get_webuser_info_rec;

      IF get_webuser_info%NOTFOUND THEN
         op_err_code := '01209';
         op_err_msg  := 'ERROR-01209 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Web User Account not found';
         CLOSE get_webuser_info;

         RETURN;                                        --Procedure stops here
      END IF;

      CLOSE get_webuser_info;

      IF get_webuser_info_rec.web_user2contact IS NULL THEN
         op_err_code := '01210';
         op_err_msg  := 'ERROR-01210 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Target account contact not found';
         RETURN;                                        --Procedure stops here
      END IF;

      /*----------------------------------------------------------------------------------*/
      /*         If ESN is Home Alert then check valid phone number and email             */
      /*----------------------------------------------------------------------------------*/
      IF sa.adfcrm_cust_service.esn_type (ip_esn) IN('HOME ALERT', 'CAR CONNECT') THEN

         OPEN get_contact (get_webuser_info_rec.web_user2contact);
         FETCH get_contact INTO get_contact_rec;

         IF get_contact%NOTFOUND THEN

            op_err_code := '01211';
            op_err_msg  := 'ERROR-01211 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Account contact not found';

            CLOSE get_contact;

            RETURN;                                     --Procedure stops here

         ELSE
            --Email NOT valid - Phone Validation Commented - CR41244 - 03/31/2016 - kvara
            IF NOT (REGEXP_LIKE (get_contact_rec.e_mail, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,4}')
               AND LENGTH (get_contact_rec.e_mail) > 6
               AND get_contact_rec.e_mail NOT LIKE get_contact_rec.x_cust_id || '@' || '%') THEN

              op_err_code := '01212';
              op_err_msg  := 'ERROR-01212 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Account should have a valid Email';

              CLOSE get_contact;

              RETURN;                                  --Procedure stops here

            END IF;

         END IF;

         IF get_contact%ISOPEN THEN
            CLOSE get_contact;
         END IF;

      END IF;

      /*---------------------------------------------------------------------*/
      /*   Validate that movement between accounts is allowed for active ESN */
      /*---------------------------------------------------------------------*/
      IF (NVL (ip_overwrite_esn, 0) = 0 AND get_esn_info_rec.x_part_inst_status = '52' AND get_esn_info_rec.web_user_objid IS NOT NULL) THEN
         op_err_code := '01213';
         op_err_msg  := 'ERROR-01213 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Movement between accounts is not allowed for active ESN';
         RETURN;                                        --Procedure stops here
      END IF;

      /*---------------------------------------------------------------------*/
      /*   Validate that target organization/brand is the same as            */
      /*   current ESN brand                                                 */
      /*---------------------------------------------------------------------*/
      IF (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.web_user2bus_org AND get_esn_info_rec.web_user2bus_org IS NOT NULL)
         OR (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.part_num2bus_org AND get_esn_info_rec.part_num2bus_org IS NOT NULL) THEN

         IF get_esn_info_rec.org_id = 'GENERIC' THEN
            --call procedure to link brand to esn
            phone_pkg.brand_esn (get_esn_info_rec.part_serial_no,
                                 get_webuser_info_rec.org_id,
                                 ip_user,
                                 op_err_code,
                                 op_err_msg);

            IF op_err_code = '0' THEN
               op_err_msg := 'ESN added to account, Successfully';
            ELSE
               op_err_code := '01214';
               op_err_msg  := 'ERROR-PHONE_PKG.BRAND_ESN : ' || OP_ERR_MSG;
               RETURN;                                   --Procedure stops here
            END IF;
         ELSE
            OP_ERR_CODE := '01215';
            OP_ERR_MSG  := 'ERROR-00005 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Target organization/brand is not the same as the ESN has.';
            RETURN;                                     --Procedure stops here
         END IF;

      END IF;

      /*---------------------------------------------------------------------*/
      /*   Remove Link from existing account/contact                         */
      /*---------------------------------------------------------------------*/
      BEGIN
        DELETE sa.table_x_contact_part_inst
         WHERE x_contact_part_inst2part_inst = get_esn_info_rec.objid;
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.put_line ('error in DELETE table_x_contact_part_inst ' || SQLERRM);
      END;

      /*---------------------------------------------------------------------*/
      /*  Check if the esn is the first in the account to set as primary
      /*  setting the primary ESN.
      /*---------------------------------------------------------------------*/
      SELECT DECODE (COUNT (1), 0, 1, 0) x_is_default
        INTO get_esn_info_rec.x_is_default
        FROM sa.table_x_contact_part_inst
       WHERE x_contact_part_inst2contact = get_webuser_info_rec.web_user2contact
         AND x_is_default = 1;

      -- CR40766 Do not reuse account contact. NEVER
      -- If esn is primary then link to web_user2contact else copy contact info

      DBMS_OUTPUT.put_line ('ESN default is ' || get_esn_info_rec.x_is_default);

      /*---------------------------------------------------------------------*/
      /*  Copy contact information from table_web_user.web_user2contact      */
      /*---------------------------------------------------------------------*/

      v_chk := 0;

      BEGIN
        SELECT 1
        INTO   v_chk
        FROM   sa.table_part_inst
        WHERE  part_serial_no = get_esn_info_rec.part_serial_no
        AND    get_esn_info_rec.x_part_inst_status NOT IN ('51','54')   -- CR47813 Past due or Used.
        AND    NVL(x_part_inst2contact,0) > 0                           -- Added as part of CR47433 - Defect 24219
        AND    ROWNUM < 2;
      EXCEPTION
        WHEN OTHERS THEN
         v_chk := 0;
      END;

      IF v_chk <> 1 THEN

        copy_contact_info (get_webuser_info_rec.web_user2contact,
                           ip_sourcesystem ,
                           op_new_contact_id,
                           op_err_code,
                           op_err_msg);

        IF op_err_code <> '0' THEN
          ROLLBACK;
          RETURN;                                        --Procedure stops here
        END IF;

        --end if;--CR40766 Do not reuse account contact. NEVER
        DBMS_OUTPUT.put_line ('op_new_contact_id is ' || op_new_contact_id);

        /*---------------------------------------------------------------------*/
        /*   Link ESN to new contact copied                                    */
        /*---------------------------------------------------------------------*/
        IF get_esn_info_rec.objid IS NOT NULL THEN
          UPDATE sa.table_part_inst
             SET x_part_inst2contact = op_new_contact_id
           WHERE objid = get_esn_info_rec.objid;
        END IF;

      END IF;

      /*---------------------------------------------------------------------*/
      /*   Link ESN to Target account/contact                                */
      /*---------------------------------------------------------------------*/

      INSERT INTO sa.table_x_contact_part_inst (objid,
                                                x_contact_part_inst2contact,
                                                x_contact_part_inst2part_inst,
                                                x_esn_nick_name,
                                                x_is_default)
           VALUES (seq ('x_contact_part_inst'),
                   get_webuser_info_rec.web_user2contact,
                   get_esn_info_rec.objid,
                   ip_esn_nick_name,
                   get_esn_info_rec.x_is_default);

      COMMIT;

      op_err_code := 0;
      op_err_msg := 'ESN added to account, Successfully';

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    op_err_code := SQLCODE;
    op_err_msg  := TRIM (SUBSTR ('ERROR ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : '
                        || SQLERRM
                        || CHR (10)
                        || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 4000));
    RETURN;
END add_esn_to_acct;
--
--
PROCEDURE web_user_proc (ip_webuser2contact   IN     table_web_user.web_user2contact%TYPE,
                         ip_login             IN     table_web_user.login_name%TYPE,
                         ip_squestion         IN     table_web_user.x_secret_questn%TYPE,
                         ip_sanswer           IN     table_web_user.x_secret_ans%TYPE,
                         ip_pw                IN     table_web_user.password%TYPE,
                         ip_email             IN     NUMBER, -- 1:create a dummy account, 0: email should be provided
                         op_web_user_objid    OUT    table_web_user.objid%TYPE,
                         op_err_code          OUT    VARCHAR2,
                         op_err_msg           OUT    VARCHAR2) IS

      /*------------------------------------------------------------------------------------*/
      -- Check if contact already has an account then update security question and answer
      -- otherwise create an account with ramdon and default passwd
      /*------------------------------------------------------------------------------------*/
      CURSOR web_user_info (ip_webuser2contact   IN table_web_user.web_user2contact%TYPE,
                            ip_bus_org           IN table_bus_org.objid%TYPE)
      IS
         SELECT *
           FROM sa.table_web_user
          WHERE web_user2contact = ip_webuser2contact
            AND web_user2bus_org = ip_bus_org;

      web_user_info_rec         web_user_info%ROWTYPE;

      CURSOR web_user_login (ip_login     IN table_web_user.login_name%TYPE,
                             ip_bus_org   IN table_bus_org.objid%TYPE)
      IS
         SELECT table_web_user.*,
                bo.org_id
           FROM sa.table_web_user,
                sa.table_bus_org bo
          WHERE s_login_name = UPPER(ip_login)
            AND web_user2bus_org = ip_bus_org
            AND bo.objid = web_user2bus_org;


      web_user_login_rec        web_user_login%ROWTYPE;

      CURSOR contact
      IS
         SELECT c.objid,
                cai.add_info2bus_org,
                c.x_cust_id,
                c.x_cust_id || '@' || LTRIM(web_site, 'www.') dummy_email
           FROM sa.table_contact c,
                sa.table_x_contact_add_info cai,
                sa.table_bus_org bo
          WHERE c.objid = ip_webuser2contact
            AND cai.add_info2contact = c.objid
            AND bo.objid = cai.add_info2bus_org;

      contact_rec               contact%ROWTYPE;

      CURSOR get_related_contact (ip_contact_id IN table_part_inst.x_part_inst2contact%TYPE)
      IS
         SELECT web.objid web_user_objid,
                web.web_user2contact accowner_contact_id,
                web.web_user2bus_org
           FROM sa.table_part_inst pi,
                sa.table_x_contact_part_inst conpi,
                sa.table_web_user web
          WHERE pi.x_part_inst2contact = ip_contact_id
            AND conpi.x_contact_part_inst2part_inst = pi.objid
            AND web.web_user2contact = conpi.x_contact_part_inst2contact;

      get_related_contact_rec   get_related_contact%ROWTYPE;

      v_web_user_objid          table_web_user.objid%TYPE;
      v_login                   table_web_user.login_name%TYPE;

BEGIN

      v_login := ip_login;

      IF NVL (ip_email, 0) = 0 AND v_login IS NULL THEN
         op_err_code := '01216';
         op_err_msg  := 'ERROR-01216 ESN_ACCOUNT.WEB_USER_PRC : Login/Email missing';
         RETURN;                                        --Procedure stops here
      END IF;

      IF ip_webuser2contact IS NULL THEN

         op_err_code := '01217';
         op_err_msg  := 'ERROR-01217 ESN_ACCOUNT.WEB_USER_PRC : Contact missing ';
         RETURN;

      ELSE

         OPEN contact;
         FETCH contact INTO contact_rec;

         IF contact%NOTFOUND THEN
            CLOSE contact;
            op_err_code := '01217';
            op_err_msg  := 'ERROR-01217 ESN_ACCOUNT.WEB_USER_PRC : Contact not found';
            RETURN;                                     --Procedure stops here
         END IF;

         CLOSE contact;

      END IF;

      IF NVL (ip_email, 0) = 1 THEN

         v_login := contact_rec.dummy_email;

         UPDATE sa.table_contact C
            SET c.e_mail = contact_rec.dummy_email
          WHERE c.objid = contact_rec.objid;

      END IF;

      /*---------------------------------------------------------------------*/
      --   Check if contact is linked  with an account
      /*---------------------------------------------------------------------*/
      OPEN get_related_contact (ip_webuser2contact);

      FETCH get_related_contact INTO get_related_contact_rec;

      IF get_related_contact%FOUND THEN

         IF get_related_contact_rec.accowner_contact_id <> ip_webuser2contact THEN
           CLOSE get_related_contact;
           op_err_code := '0';
           op_err_msg := 'Contact is not account owner and is already linked to that account';
           RETURN;                                     --Procedure stops here
         END IF;

      END IF;

      CLOSE get_related_contact;

      /*---------------------------------------------------------------------*/
      --     Check if login already exists
      /*---------------------------------------------------------------------*/
      OPEN web_user_login (v_login, contact_rec.add_info2bus_org);

      FETCH web_user_login INTO web_user_login_rec;

      IF web_user_login%FOUND THEN

         IF web_user_login_rec.web_user2contact <> ip_webuser2contact THEN
           CLOSE web_user_login;
           op_err_code := '01218';
           op_err_msg  := 'ERROR-01218 ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : Account already exists for login/email provided  brand:' || web_user_login_rec.org_id;
           RETURN;                                     --Procedure stops here
         END IF;

      END IF;

      CLOSE web_user_login;

      /*---------------------------------------------------------------------*/
      --   Check if contact is linked directly with an account
      /*---------------------------------------------------------------------*/
      OPEN web_user_info (ip_webuser2contact, contact_rec.add_info2bus_org);
      FETCH web_user_info INTO web_user_info_rec;

      IF web_user_info%FOUND THEN

         CLOSE web_user_info;

         /*---------------------------------------------------------------------*/
         --     Update security question and answer
         /*---------------------------------------------------------------------*/
         UPDATE sa.table_web_user w
            SET w.x_secret_questn = NVL (ip_squestion, w.x_secret_questn),
                w.s_x_secret_questn = UPPER (NVL (ip_squestion, w.s_x_secret_questn)),
                w.x_secret_ans = NVL (ip_sanswer, w.x_secret_ans),
                w.s_x_secret_ans = UPPER (NVL (ip_sanswer, w.s_x_secret_ans)),
                w.login_name = NVL (v_login, w.login_name),
                w.s_login_name = UPPER (NVL (v_login, w.login_name))
          WHERE w.objid = web_user_info_rec.objid;

         op_web_user_objid := web_user_info_rec.objid;

         /*---------------------------------------------------------------------*/
         --     Update customer email in credit card information
         /*---------------------------------------------------------------------*/
         UPDATE sa.table_x_credit_card
            SET x_customer_email = NVL(v_login, x_customer_email)
          WHERE x_credit_card2contact = ip_webuser2contact;

      ELSE

         CLOSE web_user_info;

         /*---------------------------------------------------------------------*/
         --     Create an account and link with the contact
         /*---------------------------------------------------------------------*/
         IF v_login IS NULL THEN
           op_err_code := '01219';
           op_err_msg  := 'ERROR-01219 ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : Login/Email missing';
           RETURN;                                     --Procedure stops here
         END IF;

         SELECT sa.seq ('web_user')
           INTO v_web_user_objid
           FROM DUAL;

         INSERT INTO sa.table_web_user (objid,
                                        login_name,
                                        s_login_name,
                                        password,
                                        status,
                                        x_secret_questn,
                                        s_x_secret_questn,
                                        x_secret_ans,
                                        s_x_secret_ans,
                                        web_user2user,
                                        web_user2contact,
                                        web_user2bus_org,
                                        x_last_update_date)
              VALUES (v_web_user_objid,
                      v_login,
                      UPPER (v_login),
                      ip_pw,
                      1,
                      ip_squestion,
                      UPPER (ip_squestion),
                      ip_sanswer,
                      UPPER (ip_sanswer),
                      (SELECT objid
                         FROM table_user
                        WHERE s_login_name = UPPER (USER)),
                      contact_rec.objid,
                      contact_rec.add_info2bus_org,
                      NULL);
      END IF;

      op_web_user_objid := v_web_user_objid;
      op_err_code       := '0';
      op_err_msg        := 'Account successfully processed';

      RETURN;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    op_err_code := SQLCODE;
    op_err_msg  := TRIM (SUBSTR ('ERROR ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : '
                                 || SQLERRM
                                 || CHR (10)
                                 || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,
                         4000));
    RETURN;
END web_user_proc;
--
--
PROCEDURE esn_dummy_acct_contacts (p_zip                 IN     VARCHAR2,
                                   p_phone               IN     VARCHAR2,
                                   p_f_name              IN     VARCHAR2,
                                   p_l_name              IN     VARCHAR2,
                                   p_m_init              IN     VARCHAR2,
                                   p_add_1               IN     VARCHAR2,
                                   p_add_2               IN     VARCHAR2,
                                   p_city                IN     VARCHAR2,
                                   p_st                  IN     VARCHAR2,
                                   p_country             IN     VARCHAR2,
                                   p_fax                 IN     VARCHAR2,
                                   p_dob                 IN     VARCHAR2,                                       --(String mm/dd/yyyy format)
                                   ip_do_not_phone       IN     table_x_contact_add_info.x_do_not_phone%TYPE,   -- (NEW)
                                   ip_do_not_mail        IN     table_x_contact_add_info.x_do_not_mail%TYPE,    -- (NEW)
                                   ip_do_not_sms         IN     table_x_contact_add_info.x_do_not_sms%TYPE,     -- (NEW)
                                   ip_prer_consent       IN     table_x_contact_add_info.x_prerecorded_consent%TYPE,
                                   ip_mobile_ads         IN     table_x_contact_add_info.x_do_not_mobile_ads%TYPE,
                                   ip_pin                IN     table_x_contact_add_info.x_pin%TYPE,
                                   ip_squestion          IN     table_web_user.x_secret_questn%TYPE,
                                   ip_sanswer            IN     table_web_user.x_secret_ans%TYPE,
                                   ip_email              IN     NUMBER, -- 1:create a dummy account, 0: email should be provided
                                   ip_overwrite_esn      IN     NUMBER, -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                                   ip_do_not_email       IN     NUMBER, -- 1: Not Allow email communivations, 0: Allow email communications
                                   p_brand               IN     VARCHAR2,                             -- (creating a contact only)
                                   p_pw                  IN     table_web_user.password%TYPE,         --  (creating a contact only)
                                   p_c_objid             IN     NUMBER,                               -- (updating a contact only)
                                   p_esn                 IN     table_part_inst.part_serial_no%TYPE,  -- (Add ESN to Account)
                                   ip_user               IN     sa.table_user.s_login_name%TYPE,
                                   p_shipping_address1   IN     VARCHAR2,
                                   p_shipping_address2   IN     VARCHAR2,
                                   p_shipping_city       IN     VARCHAR2,
                                   p_shipping_state      IN     VARCHAR2,
                                   p_shipping_zip        IN     VARCHAR2,
                                   p_language            IN     VARCHAR2,
                                   ip_esn_nick_name      IN     VARCHAR2,
                                   ip_sourcesystem       IN     VARCHAR2,
                                   op_email              IN OUT VARCHAR2,                             -- make this as IN OUT parameter
                                   op_web_user_objid     OUT    table_web_user.objid%TYPE,
                                   op_contact_objid      OUT    NUMBER,
                                   op_err_code           OUT    VARCHAR2,
                                   op_out_msg            OUT    VARCHAR2) AS

v_esn_count NUMBER := 0;
v_esn       table_part_inst.part_serial_no%TYPE;

BEGIN

  BEGIN
    SELECT COUNT(1)
      INTO v_esn_count
      FROM sa.table_part_inst pi,
           sa.table_mod_level ml,
           sa.table_part_num pn,
           sa.table_bus_org tbo
     WHERE tbo.objid         = pn.part_num2bus_org
       AND pn.objid          = ml.part_info2part_num
       AND ml.objid          = pi.n_part_inst2part_mod
       AND tbo.org_id        = p_brand
       AND pi.x_domain       = 'PHONES'
       AND pi.part_serial_no = TRIM(p_esn);
  EXCEPTION
    WHEN OTHERS THEN
      v_esn_count := 0;
  END;

  IF (v_esn_count = 0) AND (p_brand = 'TOTAL_WIRELESS') THEN
    v_esn := NULL;
  ELSE
    v_esn := p_esn;
  END IF;

  IF (ip_pin IS NOT NULL) AND (LENGTH(NVL(ip_pin, 0))) != 4 AND (p_brand = 'TOTAL_WIRELESS') THEN
    op_err_code := '01221';
    op_out_msg  := 'ERROR: Invalid Security PIN, this could be 4 digits.';
    RETURN;
  END IF;

  esn_account_contact (p_zip                 ,
                       p_phone               ,
                       p_f_name              ,
                       p_l_name              ,
                       p_m_init              ,
                       p_add_1               ,
                       p_add_2               ,
                       p_city                ,
                       p_st                  ,
                       p_country             ,
                       p_fax                 ,
                       op_email              ,
                       p_dob                 ,
                       ip_do_not_phone       ,
                       ip_do_not_mail        ,
                       ip_do_not_sms         ,
                       ip_prer_consent       ,
                       ip_mobile_ads         ,
                       ip_pin                ,
                       ip_squestion          ,
                       ip_sanswer            ,
                       ip_email              ,
                       ip_overwrite_esn      ,
                       ip_do_not_email       ,
                       p_brand               ,
                       p_pw                  ,
                       p_c_objid             ,
                       v_esn                 ,       -- CR57178 - pass null if ESN does notr exists.
                       ip_user               ,
                       p_shipping_address1   ,
                       p_shipping_address2   ,
                       p_shipping_city       ,
                       p_shipping_state      ,
                       p_shipping_zip        ,
                       p_language            ,
                       ip_esn_nick_name      ,
                       ip_sourcesystem       ,
                       op_web_user_objid     ,
                       op_contact_objid      ,
                       op_err_code           ,
                       op_out_msg);

  op_email := sa.CUSTOMER_INFO.get_web_user_attributes (v_esn, 'LOGIN_NAME');

  -- CR57178 - Seach email for new TW account and contact with invalid ESN.
  IF (op_email IS NULL) AND (op_contact_objid IS NOT NULL) AND (p_brand = 'TOTAL_WIRELESS') THEN
    BEGIN
      SELECT tct.e_mail
        INTO op_email
        FROM sa.table_contact tct,
             sa.table_x_contact_add_info cai,
             sa.table_bus_org tbo
       WHERE tbo.org_id = p_brand
         AND tbo.objid = cai.add_info2bus_org
         AND cai.add_info2contact = tct.objid
         AND tct.objid = op_contact_objid;
    EXCEPTION
      WHEN OTHERS THEN
        op_email := NULL;
    END;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    op_err_code := '01220';
    op_out_msg  := 'ERROR-01206 ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT 2 : In main exception';
END esn_dummy_acct_contacts;
--
--
END esn_account;
/
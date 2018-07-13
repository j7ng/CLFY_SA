CREATE OR REPLACE PROCEDURE sa."VALIDATE_PROMO_CODE" (
 p_esn VARCHAR2,
 p_red_code01 VARCHAR2 DEFAULT NULL,
 p_red_code02 VARCHAR2 DEFAULT NULL,
 p_red_code03 VARCHAR2 DEFAULT NULL,
 p_red_code04 VARCHAR2 DEFAULT NULL,
 p_red_code05 VARCHAR2 DEFAULT NULL,
 p_red_code06 VARCHAR2 DEFAULT NULL,
 p_red_code07 VARCHAR2 DEFAULT NULL,
 p_red_code08 VARCHAR2 DEFAULT NULL,
 p_red_code09 VARCHAR2 DEFAULT NULL,
 p_red_code10 VARCHAR2 DEFAULT NULL,
 p_technology VARCHAR2,
 p_transaction_amount NUMBER,
 p_source_system VARCHAR2,
 p_promo_code VARCHAR2,
 p_transaction_type VARCHAR2,
 p_zipcode VARCHAR2,
 p_language VARCHAR2,
 p_fail_flag NUMBER, --CR2739
 p_discount_amount OUT VARCHAR2,
 p_promo_units OUT NUMBER,
 p_access_days OUT NUMBER,
 p_status OUT VARCHAR2,
 p_msg OUT VARCHAR2
)
IS
/******************************************************************************/
 /* Copyright 2002 Tracfone Wireless Inc. All rights reserved */
 /* */
 /* NAME: SA.VALIDATE_PROMO_CODE */
 /* PURPOSE: To validate promocode */
 /* FREQUENCY: */
 /* PLATFORMS: Oracle 8.0.6 AND newer versions. */
 /* */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- --------------------------------------------- */
 /* 1.0 08/16/02 SL Initial Revision */
 /* */
 /* 1.1 09/16/02 SL Validate promo usage before validating */
 /* transaction type so that a nicer message */
 /* will be provided to customer. */
 /* 1.2 01/28/03 GP Added PROMOENROLLMENT when checking Transaction */
 /* parameters */
 /* 1.3 05/20/03 VA Added to pass the partnumber as a bind parameter*/
 /* to the dynamic sql */
 /* 1.4 03/31/04 VA CR2638 - Modified to pass the correct error # */
 /* 1.5 07/08/04 VA CR2739 - Modified to validate promocode for */
 /* redeemed cards to process ivr/web failure cases */
 /* p_fail_flag -> 0 for non failure cases */
 /* 1 for failure cases */
 /* 1.6 05/02/05 VA CR3609 - Promo Validation */
 /* 1.7 05/03/05 VA Fix for CR3609 */
 /* 1.8 06/09/05 VA CR4032 - Check for start date of the promocodes */
 /* 1.9 06/13/05 VA Fix for a bug in CR4032 (removed TRUNC check from SYSDATE)
 /* 1.10 12/09/05 VA CR4843 -
 /* 1.10.1.0 08/15/06 VA CR5365
 /* 1.10.1.1 08/16/06 AB CR5365
 /* 1.10.1.2 08/16/06 AB CR5365
 /* 1.10.1.3 06/13/07 CI CR6209 block promo on free airtime
 /* 1.10.1.4 06/21/07 CI CR6209 block promo on specific free airtime card only
 /* 1.10.1.5/6/7 06/27/07 VA Same as in CLFYSIT2
 /********************************************************************************************************************/
 /* NEW PVCS STRUCTURE */
 /* 1.0 06/02/08 IC PE203 promo code engine project move messages to x_clarify_codes table */
 /* 1.1-1.3 07/17/08 IC CR7331 add ability to use WEBCSR PURCHASE promo */
 /********************************************************************************************************************/

 l_promo_code VARCHAR2 (30) := LTRIM (LTRIM (p_promo_code));
 l_sp_objid NUMBER;
 l_promo_usage NUMBER := 0;
 l_promo_usage_tot NUMBER := 0;
 l_esn VARCHAR2 (30) := LTRIM (RTRIM (p_esn));
 l_technology VARCHAR2 (30)
 := UPPER (LTRIM (RTRIM (p_technology)));
 l_source_system VARCHAR2 (30)
 := UPPER (LTRIM (RTRIM (p_source_system)));
 l_transaction_type VARCHAR2 (30)
 := UPPER (LTRIM (RTRIM (p_transaction_type)));
 l_zipcode VARCHAR2 (5) := LTRIM (RTRIM (p_zipcode));
 l_language VARCHAR2 (30) := UPPER (LTRIM (RTRIM (p_language)));
 l_transaction_amount NUMBER := NVL (p_transaction_amount, 0);
 l_fail_flag NUMBER := NVL (p_fail_flag, 0);
 l_brand                VARCHAR2 (100); -- CR51519

 --CR2739
 CURSOR c_promo
 IS
 SELECT *
 FROM TABLE_X_PROMOTION
 WHERE x_promo_code = l_promo_code
 AND UPPER (x_promo_type) in ('PROMOCODE'); -- CR20399

 rec_promo c_promo%ROWTYPE;

 CURSOR c_esn
 IS
 SELECT *
 FROM TABLE_PART_INST
 WHERE part_serial_no = l_esn;

 rec_esn c_esn%ROWTYPE;

 CURSOR c_site_part
 IS
 SELECT *
 FROM TABLE_SITE_PART
 WHERE ( objid = NVL (l_sp_objid, 0)
 OR (x_service_id = l_esn AND part_status || '' = 'Active')
 )
 AND ROWNUM < 2;

 rec_site_part c_site_part%ROWTYPE;

 -- CR20399 net10 promo logic
 CURSOR c_enroll_promo (p_promo varchar2)
 IS
 select ex.*
 from X_enroll_promo_extra ex, table_X_promotion p , table_bus_org b
 where ex.Extra_promo_objid = p.objid
 and p.x_promo_code = p_promo
 and p.promotion2bus_org = b.objid
 and b.org_id = 'NET10';

 rec_enroll_promo c_enroll_promo%ROWTYPE;


 CURSOR c_zip (c_promo_objid NUMBER, c_zip VARCHAR2)
 IS
 SELECT z.*
 FROM MTM_X_PROMOTION6_X_ZIP_CODE0 MTM, TABLE_X_ZIP_CODE z
 WHERE 1 = 1
 AND MTM.x_promotion2x_zip_code = c_promo_objid
 AND z.objid = x_zip_code2x_promotion
 AND z.x_zip = c_zip;

 rec_zip c_zip%ROWTYPE;

 CURSOR c_program_zip (c_promo_objid NUMBER, c_zip VARCHAR2)
 IS
 SELECT z.*
 FROM MTM_X_PROMOTION6_X_ZIP_CODE0 MTM, TABLE_X_ZIP_CODE z
 WHERE 1 = 1
 AND MTM.x_promotion2x_zip_code + 0 IN (
 SELECT mtm2.x_promo_mtm2x_promotion
 FROM TABLE_X_PROMOTION_MTM mtm1, TABLE_X_PROMOTION_MTM mtm2
 WHERE mtm1.x_promo_mtm2x_promo_group =
 mtm2.x_promo_mtm2x_promo_group
 AND mtm1.x_promo_mtm2x_promotion = c_promo_objid)
 AND z.objid = MTM.x_zip_code2x_promotion
 AND z.x_zip = c_zip;

 CURSOR c_red_date
 IS
 SELECT x_red_date
 FROM TABLE_X_RED_CARD
 WHERE x_red_code = p_red_code01 AND x_result = 'Completed';

 rec_red_date c_red_date%ROWTYPE;

 TYPE partnum_tab_type IS TABLE OF TABLE_PART_NUM.part_number%TYPE
 INDEX BY BINARY_INTEGER;

 l_partnum_tab partnum_tab_type;

 TYPE partnum_rec_tab_type IS TABLE OF TABLE_PART_NUM%ROWTYPE
 INDEX BY BINARY_INTEGER;

 l_partnum_rec_tab partnum_rec_tab_type;

 TYPE redcard_tab_type IS TABLE OF TABLE_PART_INST.x_red_code%TYPE
 INDEX BY BINARY_INTEGER;

 l_redcard_tab redcard_tab_type;
 l_j NUMBER := 0;
 l_sql_text VARCHAR2 (4000);
 l_cursorid INTEGER;
 l_bind_var VARCHAR2 (50);
 l_rc INTEGER;
 l_chars VARCHAR2 (255);
 l_redunit NUMBER := 0;
 l_cardtype VARCHAR2 (30);
 l_redday NUMBER;
 l_step VARCHAR2 (100);
 l_ct NUMBER := 0;
 l_pm_status VARCHAR2 (30);
 l_pm_msg VARCHAR2 (2000);
 l_is_plsql VARCHAR2 (1) := 'N';
 --VAdapa 05/20/03
 l_partnum VARCHAR2 (30);
 --End 05/20/03
 l_sp_status VARCHAR2 (20);
--CR3609
 l_pin VARCHAR2 (20); --CR4843 Start
 l_corp_free NUMBER:=0; --CR6209;
BEGIN
 p_discount_amount := '0';
 p_promo_units := 0;
 p_access_days := 0;
 p_status := '0';
 p_msg := NULL;

 --CR6209 if cards have 'corp free' then do not process them;
 /*select count(1) INTO l_corp_free from dual where exists
 (select pi.part_serial_no, ts.name,ts.site_type, pi.x_part_inst_status, pi.x_domain
 from table_part_inst pi, table_inv_bin ib, table_site ts
 where ts.site_id=ib.bin_name
 and ib.objid=pi.part_inst2inv_bin
 and ts.name like 'CORP FREE%'
 and pi.x_domain='REDEMPTION CARDS'
 and pi.x_red_code IN
 (p_red_code01,
 p_red_code02,
 p_red_code03,
 p_red_code04,
 p_red_code05,
 p_red_code06,
 p_red_code07,
 p_red_code08,
 p_red_code09 ));

 if l_corp_free>=1 then
 p_status := '1578';
 p_msg := 'Invalid redemption card';
 RETURN;
 end if; */ -- this removed on 6/21/07 and will address on card by card basis below
 --END CR6209

 -- check promo code
 IF l_promo_code IS NULL
 THEN
 p_status := '1577';
 -- CR5365 Start
 -- PE203 IC
 -- p_msg := 'You did not qualify for this promotion.';
 -- p_msg := 'Error: Promotion ' || l_promo_code || ' not valid for this phone.';
 p_msg := REPLACE(Get_Code_Fun('SA.VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
 -- CR5365 End
 RETURN;
 ELSE
 -- check 5 digits promo code
 IF l_promo_code < '00000' AND l_promo_code > '99999'
 THEN
 -- p_status := '1578';
 -- p_msg := 'Error in input parameters. Five digits promocode required.';
 -- PE203 IC
 p_status := '1564';
 p_msg := Get_Code_Fun('SA.VALIDATE_PROMO_CODE',p_status,'ENGLISH');
 RETURN;
 END IF;

 -- check promo code
 OPEN c_promo;

 FETCH c_promo
 INTO rec_promo;

 IF c_promo%NOTFOUND
 THEN
 CLOSE c_promo;

 p_status := '1570';
 -- CR5365 Start
 -- p_msg := 'This promo code ' || l_promo_code || ' is not valid.';
 -- p_msg := 'Error: Promotion ' || l_promo_code || ' is not valid.';
 -- CR5365 End
 -- PE203 IC
 p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
 RETURN;
 END IF;

 CLOSE c_promo;

--CR4032 Starts
 IF SYSDATE <= rec_promo.x_start_date
 THEN
 p_status := '1570';
 -- CR5365 p_msg := 'This promo code ' || l_promo_code || ' is not valid.';
 -- p_msg := 'Error: Promotion ' || l_promo_code || ' is not valid.';
 -- PE203 IC
 p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
 RETURN;
 END IF;

--CR4032 Ends
 IF l_fail_flag = 0
 THEN
--CR2739
 IF TRUNC (SYSDATE) > rec_promo.x_end_date
 THEN
 p_status := '1571';
 -- CR5365 p_msg := 'This promo code ' || l_promo_code || ' has expired.';
 -- p_msg := 'Error: Promotion ' || l_promo_code || ' has expired.';
 -- PE203 IC
 p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
 RETURN;
 END IF;
--CR2739 Changes
 ELSIF l_fail_flag = 1
 THEN
 OPEN c_red_date;

 FETCH c_red_date
 INTO rec_red_date;

 CLOSE c_red_date;

 IF TRUNC (rec_red_date.x_red_date) > rec_promo.x_end_date
 THEN
 p_status := '1571';
 -- CR5365 p_msg := 'This promo code ' || l_promo_code || ' has expired.';
           -- p_msg := 'Error: Promotion ' || l_promo_code || ' has expired.';
           --  PE203 IC
            p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;
      END IF;
      --End CR2739 Changes
      -- check language
      IF l_language IS NULL
      THEN
         -- p_status := '1578';
         -- p_msg := 'Error in input parameters. Language required.';
         -- PE203 IC
         p_status := '1565' ;
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSIF l_language NOT IN ('ENGLISH', 'SPANISH')
      THEN
            -- p_status := '1578';
            -- p_msg := 'Error in input parameters. Language is invalid.';
            -- PE203 IC
             p_status := '1566' ;
             p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
            RETURN;
      END IF;

      -- check esn
      IF l_esn IS NULL
      THEN
       --   p_status := '1578';
       --   p_msg := 'Error in input parameters. ESN required.';
       --  PE203 IC
         p_status := '1567' ;
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSE
         OPEN c_esn;

         FETCH c_esn
          INTO rec_esn;

         IF c_esn%NOTFOUND
         THEN
            CLOSE c_esn;
            p_status := '1578';
            -- p_msg := 'Error in input parameters. ESN '  || NVL (p_esn, '<NULL>') || ' is invalid.';
            -- PE203 IC
           p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ESN', p_esn);
            RETURN;
         END IF;

         CLOSE c_esn;

         l_sp_objid := rec_esn.x_part_inst2site_part;         -- GP 01/28/2003

   -- Net10 promo logic CR20399
    OPEN c_enroll_promo(p_promo_code);
    FETCH c_enroll_promo
    INTO rec_enroll_promo;

         IF (l_transaction_type NOT IN ('ACTIVATION', 'REACTIVATION', 'PROMOENROLLMENT')) and
             ( c_enroll_promo%NOTFOUND )                   -- CR20399
         THEN
            OPEN c_site_part;

            FETCH c_site_part
             INTO rec_site_part;

            IF c_site_part%NOTFOUND and  rec_esn.x_part_inst_status not in ('50','150')  -- CR45238_TF_Fix_Promo_Validation_WEB_TAS Tim 9/14/2016
            THEN
               CLOSE c_site_part;
               CLOSE c_enroll_promo;  --CR20399
                 -- p_status := '1578';
                 -- p_msg := 'Error in input parameters. ESN '  || NVL (p_esn, '<NULL>') || 'has no service record.';
                 -- PE203 IC
                p_status := '1560';
                p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ESN', p_esn);
               RETURN;
            END IF;

            CLOSE c_site_part;
         END IF;

         CLOSE c_enroll_promo; --CR20399
      END IF;

        IF device_util_pkg.get_smartphone_fun(p_esn) = 0 THEN                                        ----- CR 23513 TF SUREPAY PHONES ARE NOT ELIGIBLE FOR PROMOTIONS- MVadlapally
            p_status := '1577';
            p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ESN', p_esn);
            RETURN;
        END IF;

      -- check source system
      IF l_source_system IS NULL
      THEN
--          p_status := '1578';
--          p_msg := 'Error in input parameters. Source system required.';
       --  PE203 IC
         p_status := '1568' ;
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSIF (    (UPPER (rec_promo.x_source_system) <> l_source_system  AND UPPER (rec_promo.x_source_system) <> 'ALL')
             AND  (UPPER (rec_promo.x_source_system) <> l_source_system  AND UPPER(l_source_system) <> 'CLARIFY')
             -- CR7331 1.3 IC added clarify source system for webcsr purchase promos
            )
      THEN

--       DBMS_OUTPUT.PUT_LINE('UPPER (rec_promo.x_source_system = ' || UPPER (rec_promo.x_source_system));
--       DBMS_OUTPUT.PUT_LINE('l_source_system = ' || l_source_system);
--       DBMS_OUTPUT.PUT_LINE('UPPER(l_source_system)= ' || UPPER(l_source_system));


         p_status := '1575';
--CR5365 Start
--          p_msg :=
--                'This promo code '
--             || l_promo_code
--             || ' is not available on '
--             || l_source_system;
--          p_msg :=
--                'Error: Promotion '
--             || l_promo_code
--             || ' is not available on '
--             || l_source_system;
--CR5365 End
        -- PE203 IC
         p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_SOURCE_SYSTEM', l_source_system);
         p_msg := REPLACE(p_msg, '__L_PROMO_CODE', l_promo_code);
         RETURN;
      END IF;

      -- check usage
      -- 1.1 validate promo usage before validating transaction type
      --
      IF (    UPPER (rec_promo.x_transaction_type) <> 'PROGRAM'
          AND NVL (rec_promo.x_usage, 0) <> 99
         )
      THEN
         IF l_transaction_type = 'PURCHASE'
         THEN
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PURCH_HDR purh, TABLE_X_DISCOUNT_HIST disc
             WHERE purh.x_ics_rflag IN ('ACCEPT','SOK')
               AND disc.x_disc_hist2x_purch_hdr = purh.objid
               AND disc.x_esn = rec_esn.part_serial_no
               AND disc.x_disc_hist2x_promo = rec_promo.objid;
         ELSE
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PROMO_HIST PH, TABLE_X_CALL_TRANS ct
             WHERE rec_promo.objid = PH.promo_hist2x_promotion + 0
               AND ct.objid = PH.promo_hist2x_call_trans
               AND ct.call_trans2site_part = rec_esn.x_part_inst2site_part;
         END IF;

         l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;
         l_promo_usage := 0;

--CR3609 Starts
         BEGIN
            SELECT part_status
              INTO l_sp_status
              FROM TABLE_SITE_PART
             WHERE objid = rec_esn.x_part_inst2site_part;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_sp_status := NULL;
         END;

         IF NVL (l_sp_status, 'zzz') <> 'Obsolete'
         THEN
            --CR3609 Ends
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PENDING_REDEMPTION
             WHERE x_pend_red2site_part = rec_esn.x_part_inst2site_part
               AND pend_red2x_promotion = rec_promo.objid;
         --CR3609 starts
         ELSE
            DELETE FROM TABLE_X_PENDING_REDEMPTION
                  WHERE x_pend_red2site_part = rec_esn.x_part_inst2site_part;

            COMMIT;
         END IF;

         --CR3609 Ends
         l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;
         IF NVL (l_promo_usage_tot, 0) >= NVL (rec_promo.x_usage, 0)
         THEN
            p_status := '1573';
--CR5365 Start
--             p_msg :=
--                   'This promo_code '
--                || l_promo_code
--                || ' has already been used '
--                || l_promo_usage_tot
--                || ' time(s).';
--CR5365 End
--            p_msg := 'Error: Promotion '
--            || l_promo_code  || ' already used ';
         -- PE203 IC
            p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;
      END IF;

      -- Check transaction parameters
      IF (l_transaction_type IS NULL)
      THEN
                 --  PE203 IC
                 --  p_status := '1578';
                 --  p_msg := 'Error in input parameters. Transaction type is required';
                     p_status := '1569' ;
                     p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
                    RETURN;
      ELSIF l_transaction_type NOT IN  ('ACTIVATION', 'REACTIVATION',
                   'REDEMPTION',  'PURCHASE', 'PROMOENROLLMENT'
              )                                               -- GP 01/28/2003
      THEN
             -- PE203 IC
             -- p_status := '1578';
             -- p_msg := 'Error in input parameters. Transaction type '  || l_transaction_type  || ' is invalid';
           p_status := '1563';
           p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_TRANSACTION_TYPE', l_transaction_type);
         RETURN;
      ELSIF (l_transaction_type = 'PURCHASE' AND l_transaction_amount = 0)
      THEN
              --  PE203 IC
              --   p_status := '1578';
              --   p_msg := 'Error in input parameters. Transaction amount can not be 0'
              --   || ' when transaction type is PURCHASE.';
             p_status := '1572';
             p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
             RETURN;
      ELSIF (l_transaction_type <> 'PURCHASE' AND l_transaction_amount > 0)
      THEN
              -- PE203 IC
              -- p_status := '1578';
              --  p_msg :=  'Error in input parameters. Transaction amount should be 0'
              --                      || ' when transaction type is not PURCHASE.';
             p_status := '1588';
             p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      END IF;
      -- Added as part of CR57150 to allow APP channel as well.
      SELECT CASE WHEN l_source_system IN ('WEB','APP') THEN sa.util_pkg.get_bus_org_id(l_esn)
	         ELSE
			 'XXX'
			 END
		INTO l_brand
		FROM dual; --CR57150
	  /*SELECT DECODE(l_source_system,'WEB',sa.util_pkg.get_bus_org_id(l_esn),'XXX')
	    INTO l_brand
		FROM dual;*/ --CR51519
	  -- Determine Potential Transactions - Clarify remains the same
      IF UPPER (rec_promo.x_transaction_type) NOT IN ('ALL', 'PROGRAM')
      THEN
         -- CR21961 VAS_APP
         -- IF l_source_system = 'WEB'
         IF l_source_system = 'WEB' or l_source_system = 'APP'
         THEN
            IF (    UPPER (rec_promo.x_transaction_type) = 'ACTIVATION'
                AND l_transaction_type NOT IN ('ACTIVATION')
               )
            THEN
                 -- CR5365  p_msg := 'This is an activation promo code.';
                 p_status := '1580';
                -- PE203 IC
                -- p_msg := 'Error: Promotion ' || l_promo_code || ' is an activation promo code.';
                p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REACTIVATION'
                   AND l_transaction_type NOT IN ('REACTIVATION', 'PURCHASE')
                  )
            THEN
               p_status := '1579';
               --CR5365   p_msg := 'This is reactivation promo code.';
               -- PE203 IC
               -- p_msg :=  'Error: Promotion ' || l_promo_code  || ' is an reactivation promo code.';
                p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'PURCHASE'
                   AND l_transaction_type NOT IN ('REACTIVATION', 'PURCHASE')
				   AND l_brand <> 'TRACFONE' --CR51519 skipping validation for tracfone only for WEB
                  )
            THEN
                    --  03/31/04 Changes p_status := '1579';
                    p_status := '1581';
                   --  CR5365  p_msg := 'This is a purchase promo code.';
                   --  PE203 IC
                   --  p_msg := 'Error: Promotion ' || l_promo_code  || ' is an purchase promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            END IF;
         ELSIF l_source_system = 'IVR'
         THEN
            IF (    UPPER (rec_promo.x_transaction_type) = 'ACTIVATION'
                AND l_transaction_type NOT IN ('ACTIVATION')
               )
            THEN
                  p_status := '1580';
                  -- PE203 IC
                  --  p_msg := 'Error: Promotion ' || l_promo_code  || ' is an activation promo code.';
                  --  CR5365  p_msg := 'This is an activation promo code.';
                  p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REACTIVATION'
                   AND l_transaction_type NOT IN ('REACTIVATION')
                  )
            THEN
               p_status := '1579';
               --  CR5365  p_msg := 'This is reactivation promo code.';
               --  PE203 IC
               -- p_msg := 'Error: Promotion ' || l_promo_code  || ' is an reactivation promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
                   RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'PURCHASE'
                   AND l_transaction_type NOT IN ('PURCHASE')
                  )
            THEN
                   -- 1.1 purchase should only accept purchase promocode
                   p_status := '1581';
                   --  CR5365   p_msg := 'This is a purchase promo code.';
                   --  PE203 IC
                   --  p_msg := 'Error: Promotion ' || l_promo_code   || ' is an purchase promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
                  RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REDEMPTION'
                   AND l_transaction_type NOT IN
                                               ('REDEMPTION', 'REACTIVATION')
                  )
            THEN
                 -- 1.1 reactivation should take reactivations and redmeption promocode
                 p_status := '1576';
                 -- CR5365  p_msg := 'This is a redemption promo code.';
                 -- PE203 IC
                 -- p_msg := 'Error: Promotion '  || l_promo_code || ' is an redemption promo code.';
                     p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
                     RETURN;
            END IF;
         ELSE
            IF (    UPPER (rec_promo.x_transaction_type) = 'ACTIVATION'
                AND l_transaction_type NOT IN ('ACTIVATION')
               )
            THEN
               p_status := '1580';
               --  CR5365    p_msg := 'This is a activation promo code.';
               -- PE203 IC
               -- p_msg := 'Error: Promotion ' || l_promo_code   || ' is an activation promo code.';
                   p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REACTIVATION'
                   AND l_transaction_type NOT IN ('REACTIVATION')
                  )
            THEN
               p_status := '1579';
               -- CR5365  p_msg := 'This is a reactivation promo code.';
               -- PE203 IC
               -- p_msg :='Error: Promotion ' || l_promo_code || ' is an reactivation promo code.';
               p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'PURCHASE'
                   AND l_transaction_type NOT IN ('PURCHASE')
                  )
            THEN
               p_status := '1581';
               -- CR5365 p_msg := 'This is a purchase promo code.';
               -- PE203 IC
               -- p_msg :=  'Error: Promotion ' || l_promo_code || ' is an purchase promo code.';
               p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            ELSIF (    UPPER (rec_promo.x_transaction_type) = 'REDEMPTION'
                   AND l_transaction_type NOT IN ('REDEMPTION')
                  )
            THEN
               p_status := '1576';
               --  CR5365 p_msg := 'This is a redemption promo code.';
               -- PE203 IC
               -- p_msg := 'Error: Promotion ' || l_promo_code  || ' is an redemption promo code.';
               p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
               RETURN;
            END IF;
         END IF;

         IF (    (   l_transaction_type = 'REDEMPTION'
                  OR UPPER (rec_promo.x_transaction_type) = 'REDEMPTION'
                 )
             AND p_red_code01 IS NULL
            )
         THEN
                p_status := '1587';
                -- CR5365    p_msg := 'This promotion requires pin.';
                -- PE203 IC
                --  p_msg := 'Error: Promotion ' || l_promo_code || ' requires pin.';
                p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;
      ELSIF UPPER (rec_promo.x_transaction_type) IN ('PROGRAM')
      THEN
         SELECT COUNT (1)
           INTO l_promo_usage
           FROM TABLE_X_PENDING_REDEMPTION
          WHERE x_pend_red2site_part = rec_esn.x_part_inst2site_part
            AND pend_red2x_promotion = rec_promo.objid;

         IF l_promo_usage > 0
         THEN
            p_status := '1584';
           -- CR5365 End p_msg := 'This promotion is already pending.';
            -- PE203 IC
            -- p_msg := 'Error: Promotion ' || l_promo_code || ' is already pending.';
              p_msg := REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            RETURN;
         END IF;

         l_promo_usage_tot := 0;

         SELECT COUNT (1)
           INTO l_promo_usage
           FROM TABLE_X_PROMOTION_MTM MTM, TABLE_X_GROUP2ESN ge
          WHERE MTM.x_promo_mtm2x_promotion = rec_promo.objid
            AND ge.groupesn2x_promo_group + 0 = MTM.x_promo_mtm2x_promo_group
            AND ge.groupesn2part_inst = rec_esn.objid;

         l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;

         IF l_promo_usage_tot = 0
         THEN
            SELECT COUNT (1)
              INTO l_promo_usage
              FROM TABLE_X_PROMO_HIST PH, TABLE_X_CALL_TRANS ct
             WHERE PH.promo_hist2x_promotion + 0 IN (
                      SELECT mtm2.x_promo_mtm2x_promotion
                        FROM TABLE_X_PROMOTION_MTM mtm1,
                             TABLE_X_PROMOTION_MTM mtm2
                       WHERE mtm1.x_promo_mtm2x_promo_group =
                                                mtm2.x_promo_mtm2x_promo_group
                         AND mtm1.x_promo_mtm2x_promotion = rec_promo.objid)
               AND ct.objid = PH.promo_hist2x_call_trans
               AND ct.call_trans2site_part = rec_esn.x_part_inst2site_part;

            l_promo_usage_tot := l_promo_usage_tot + l_promo_usage;
         END IF;

         IF l_promo_usage_tot > 0
         THEN
              p_status := '1585';
              -- CR5365  p_msg := 'You are already a member. ';
              -- PE203 IC
              -- p_msg := '    Error : You are already a member. ';
              p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
            RETURN;
         END IF;
      END IF;

      -- check technology
      IF l_technology IS NULL
      THEN
        --  p_status := '1578';
        --  p_msg := 'Error in input parameters. Technology required.';
        --  PE203 IC
         p_status := '1589';
         p_msg := Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH') ;
         RETURN;
      ELSIF (    UPPER (rec_promo.x_promo_technology) <> l_technology
             AND UPPER (rec_promo.x_promo_technology) <> 'ALL'
            )
      THEN
           p_status := '1574';
           --  CR5365 p_msg := 'This promo code ' || l_promo_code || ' is not available for '  || l_technology;
           -- PE203 IC
           -- p_msg := 'Error: Promotion '|| l_promo_code || ' is not available for ' || l_technology;
           p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
            p_msg := REPLACE(p_msg, '__L_TECHNOLOGY', l_technology);
         RETURN;
      END IF;

      -- check zip
      IF NVL (rec_promo.x_zip_required, 0) = 1
      THEN
         -- zip is required for this promotion
         OPEN c_zip (rec_promo.objid, p_zipcode);

         FETCH c_zip
          INTO rec_zip;

         IF c_zip%NOTFOUND
         THEN
            p_status := '1582';
            -- PE203 IC
            -- p_msg := 'Zip code ' || p_zipcode || ' is not part of this promotion. ';
             p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__P_ZIPCODE', p_zipcode);
            RETURN;
         END IF;
      END IF;

      -- get input red code/part number
      IF l_transaction_type = 'PURCHASE'
      THEN
         l_partnum_tab (0) := p_red_code01;
         l_partnum_tab (1) := p_red_code02;
         l_partnum_tab (2) := p_red_code03;
         l_partnum_tab (3) := p_red_code04;
         l_partnum_tab (4) := p_red_code05;
         l_partnum_tab (5) := p_red_code06;
         l_partnum_tab (6) := p_red_code07;
         l_partnum_tab (7) := p_red_code08;
         l_partnum_tab (8) := p_red_code09;
         l_partnum_tab (9) := p_red_code10;

         FOR i IN 0 .. 9
         LOOP
            IF l_partnum_tab (i) IS NOT NULL
            THEN
               BEGIN
                  SELECT pn.*
                    INTO l_partnum_rec_tab (i)
                    FROM TABLE_PART_NUM pn
                   WHERE pn.domain in  ('REDEMPTION CARDS','BILLING PROGRAM') --CR20399
                     AND part_number = l_partnum_tab (i);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     --  p_status := '1578';
                     --  p_msg := 'Error in input parameters. Invalid part number: ' || l_partnum_tab (i);
                      -- PE203 IC
                      p_status := '1562';
                      p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PARTNUM_TAB', l_partnum_tab (i));
                     RETURN;
               END;
            ELSE
               l_partnum_rec_tab (i) := NULL;
            END IF;
         END LOOP;
      ELSE
         l_redcard_tab (0) := p_red_code01;
         l_redcard_tab (1) := p_red_code02;
         l_redcard_tab (2) := p_red_code03;
         l_redcard_tab (3) := p_red_code04;
         l_redcard_tab (4) := p_red_code05;
         l_redcard_tab (5) := p_red_code06;
         l_redcard_tab (6) := p_red_code07;
         l_redcard_tab (7) := p_red_code08;
         l_redcard_tab (8) := p_red_code09;
         l_redcard_tab (9) := p_red_code10;
         l_j := 0;

         FOR i IN 0 .. 9
         LOOP
            IF l_fail_flag = 0                                       --CR2739
            THEN
               IF l_redcard_tab (i) IS NOT NULL
               THEN
                  BEGIN
                     SELECT pn.*
                       INTO l_partnum_rec_tab (i)
                       FROM TABLE_PART_NUM pn,
                            TABLE_MOD_LEVEL ml,
                            TABLE_PART_INST pi
                      WHERE 1 = 1
                        AND ml.part_info2part_num = pn.objid
                        AND n_part_inst2part_mod = ml.objid
                        AND x_domain || '' = 'REDEMPTION CARDS'
                        AND x_red_code = l_redcard_tab (i);


                        --CR6209
                        SELECT COUNT(1) INTO l_corp_free FROM dual WHERE EXISTS
                         (SELECT pi.part_serial_no, ts.name,ts.site_type, pi.x_part_inst_status, pi.x_domain
                          FROM TABLE_PART_INST pi, TABLE_INV_BIN ib, TABLE_SITE ts
                          WHERE ts.site_id=ib.bin_name
                          AND ib.objid=pi.part_inst2inv_bin
                          AND ts.name LIKE 'CORP FREE%' AND ts.TYPE=3
                          AND pi.x_domain='REDEMPTION CARDS'
                          AND pi.x_red_code =l_redcard_tab (i));

                          IF l_corp_free=1 THEN
                            l_partnum_rec_tab(i):=NULL;
                            l_redcard_tab (i):=NULL;
                          END IF;
                          --end CR6209

                  EXCEPTION
                     WHEN OTHERS
                     THEN
                          --  PE203 IC
                          --  p_status := '1578';
                          --  p_msg :=  'Invalid redemption card: '  || l_redcard_tab (i)  || ' ' || SQLERRM;
                          p_status := '1561';
                          p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_REDCARD_TAB', l_redcard_tab (i));
                          p_msg :=  REPLACE(p_msg, '__SQLERRM', SQLERRM);

                        RETURN;
                  END;
               ELSE
                  l_partnum_rec_tab (i) := NULL;
               END IF;
--CR2739 Changes
            ELSIF l_fail_flag = 1
            THEN
               IF l_redcard_tab (i) IS NOT NULL
               THEN
                  BEGIN
                     SELECT pn.*
                       INTO l_partnum_rec_tab (i)
                       FROM TABLE_PART_NUM pn,
                            TABLE_MOD_LEVEL ml,
                            TABLE_X_RED_CARD rc
                      WHERE 1 = 1
                        AND ml.part_info2part_num = pn.objid
                        AND rc.x_red_card2part_mod = ml.objid
                        AND rc.x_result = 'Completed'
                        AND rc.x_red_code = l_redcard_tab (i);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                          -- PE203 IC
                           --   p_status := '1578';
                           --    p_msg := 'Invalid redemption card: ' || l_redcard_tab (i)   || ' '  || SQLERRM;
                           p_status := '1561';
                           p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_REDCARD_TAB', l_redcard_tab (i));
                           p_msg :=  REPLACE(p_msg, '__SQLERRM', SQLERRM);
                     RETURN;
                  END;
               ELSE
                  l_partnum_rec_tab (i) := NULL;
               END IF;
            END IF;
--End CR2739 Changes
         END LOOP;
      END IF;

      l_sql_text := rec_promo.x_sql_statement;
      l_j := 0;

      IF l_sql_text IS NOT NULL
      THEN
         l_cursorid := DBMS_SQL.open_cursor;

         BEGIN
            l_step := 'parse sql';
            DBMS_SQL.parse (l_cursorid, l_sql_text, DBMS_SQL.v7);
            l_bind_var := ' :esn ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       p_esn
                                      );
            END IF;

            l_step := 'bind source';
            l_bind_var := ' :source ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_source_system
                                      );
            END IF;

            l_step := 'bind zip';
            l_bind_var := ' :zip ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       p_zipcode
                                      );
            END IF;

            l_step := 'bind total transaction amount';
            l_bind_var := ' :tot_trans ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_transaction_amount
                                      );
            END IF;

            l_step := 'bind promo start date';
            l_bind_var := ' :promo_start_date ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       rec_promo.x_start_date
                                      );
            END IF;

            l_step := 'bind esn status';
            l_bind_var := ' :pi_status ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       rec_esn.x_part_inst_status
                                      );
            END IF;

            l_step := 'bind return status';
            l_bind_var := ' :pm_status ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_pm_status,
                                       30
                                      );
               l_is_plsql := 'Y';
            END IF;

            l_step := 'bind return status';
            l_bind_var := ' :pm_msg ';

            IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable (l_cursorid,
                                       RTRIM (LTRIM (l_bind_var)),
                                       l_pm_msg,
                                       2000
                                      );
               l_is_plsql := 'Y';
            END IF;

            FOR i IN 0 .. 9
            LOOP
               l_bind_var := ' :units' || LTRIM (TO_CHAR (i, '09')) || ' ';
               l_step := 'bind ' || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  IF NVL (l_partnum_rec_tab (i).part_type, 'FREE') = 'PAID'
                  THEN
                     l_redunit :=
                                NVL (l_partnum_rec_tab (i).x_redeem_units, 0);
                  ELSE
                     l_redunit := 0;
                  END IF;

                  l_step :=
                     'bind unit: ' || l_redunit || ' l_bind_var: '
                     || l_bind_var;
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_redunit
                                         );
               END IF;

               l_step := 'bind cardtype';
               l_bind_var := ' :cardtype' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_cardtype := l_partnum_rec_tab (i).x_card_type;
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_cardtype
                                         );
               END IF;

               l_step := 'bind days';
               l_bind_var := ' :days' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_redday := NVL (l_partnum_rec_tab (i).x_redeem_days, 0);
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_redday
                                         );
               END IF;

               --VAdapa 05/20/03
               l_step := 'bind partnum';
               l_bind_var := ' :part' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_partnum := l_partnum_rec_tab (i).part_number;
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_partnum
                                         );
               END IF;

--End 05/20/03
--CR4843 Start
               l_step := 'bind pin';
               l_bind_var := ' :pin' || LTRIM (TO_CHAR (i, '09')) || ' ';

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  l_pin := l_redcard_tab (i);
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_pin
                                         );
               END IF;
--CR4843 End
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
                -- PE203 IC
                --  p_status := '1583';
                --  p_msg := 'Unexpected error when preparing SQL. ' || l_step;
               p_status := '1590';
               p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_STEP', l_step);
               RETURN;
         END;

         l_step := '';

         IF l_is_plsql = 'N'
         THEN
            l_step := 'define column';
            DBMS_SQL.define_column (l_cursorid, 1, l_chars, 10);
         END IF;

         l_step := 'execute cursor';
         l_rc := DBMS_SQL.EXECUTE (l_cursorid);
		 dbms_output.put_line('Here After Execution -->:'||l_rc);
         l_step := 'execute done';
         l_j := 0;
         dbms_output.put_line('Before loop :'||l_j||' l_is_plsql: '||l_is_plsql);
         IF l_is_plsql = 'N'
         THEN
            LOOP
               IF (DBMS_SQL.fetch_rows (l_cursorid) = 0 OR l_j > 0)
               THEN
                  dbms_output.put_line('Here Exiting from loop-->:'||l_j);
				  EXIT;
               END IF;
               dbms_output.put_line('Here l_j:'||l_j||':'||l_cursorid||':'||NVL(l_chars,'NULL'));
               DBMS_SQL.column_value (l_cursorid, 1, l_chars);
               l_j := l_j + 1;
            END LOOP;
			dbms_output.put_line('Here after loop  l_j:'||l_j);
         ELSE
            l_step := 'get value status';
            DBMS_SQL.variable_value (l_cursorid, ':pm_status', l_pm_status);
            l_step := 'get value message';
            DBMS_SQL.variable_value (l_cursorid, ':pm_msg', l_pm_msg);

            IF l_pm_status = '0'
            THEN
               l_j := l_j + 1;
            ELSE
               p_status := l_pm_status;
               p_msg := l_pm_msg;
               DBMS_SQL.close_cursor (l_cursorid);
               RETURN;
            END IF;
         END IF;

         DBMS_SQL.close_cursor (l_cursorid);
      ELSE
         --
         -- if no sql defined. it will be qualified
         --
         l_j := 1;
      END IF;

      --
      -- calculation discount amount
      --
      IF l_j > 0
      THEN
         p_promo_units := NVL (rec_promo.x_units, 0);
         p_access_days := NVL (rec_promo.x_access_days, 0);

         IF l_transaction_type in ('PURCHASE', 'BPEnrollment', 'Promocode')
         THEN
            IF NVL (rec_promo.x_discount_amount, 0) > 0
            THEN
               p_discount_amount := TO_CHAR (rec_promo.x_discount_amount);
            ELSIF NVL (rec_promo.x_discount_percent, 0) > 0
            THEN
               p_discount_amount :=
                  TO_CHAR (  rec_promo.x_discount_percent
                           / 100
                           * l_transaction_amount
                          );
            END IF;

            IF l_transaction_amount <= p_discount_amount
            THEN
               p_status := '1586';
               -- PE203 IC
               -- p_msg := 'Discount amount exceeds or equals transaction amount';
               p_msg :=  Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH');
               RETURN;
            END IF;
         END IF;

         p_status := '0';

         IF l_language <> 'SPANISH'
         THEN
            p_msg := rec_promo.x_promotion_text;
         ELSE
            p_msg := rec_promo.x_spanish_promo_text;
         END IF;

         RETURN;
      ELSE
		 p_status := '1577';
         --  CR5365    p_msg := 'You did not qualify for this promotion.';
         -- PE203 IC
         -- p_msg := 'Error: Promotion ' || l_promo_code || ' not valid for this phone.';
         p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__L_PROMO_CODE', l_promo_code);
         RETURN;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      p_status := '1583';
      -- PE203 IC
      -- p_msg := 'Unexpected error: ' || SQLERRM;
         p_msg :=  REPLACE(Get_Code_Fun('VALIDATE_PROMO_CODE',p_status,'ENGLISH'), '__SQLERRM', SQLERRM);

END;
/
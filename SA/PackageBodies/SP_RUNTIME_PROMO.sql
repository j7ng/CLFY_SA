CREATE OR REPLACE PACKAGE BODY sa."SP_RUNTIME_PROMO"
IS
/*******************************************************************************************************************
   --
   -- History:
   -- Date           Who                  Description
   -- ---------- ------------- ------------------------------------
   -- 12/12/00   SL      Change Message Display.
   --                          Message priority:
   --                             1. Annual RunTime message
   --                             2. Non-annual RunTime message
   --                             3. If more than one Non-annual
   --                                Runtime message, only display
   --                                geneal message
   --
   -- 01/26/00   SL      Change runtime promotion cursor
   --                          not to check table_x_promo_hist
   --                          Instead, promotion history record
   --                          will be checked at sql statement
   --                          level for runtime promotion.
   -- 03/14/01   SL            Change runtime message
   --
   -- 05/03/01   SL            Add Stack Day        (050301)
   --
   -- 05/17/01   SL            Add p_promo_code parameter to
   --                          DoRuntimePromo,main  (051701)
   --                          1.One runtime promo return promo code
   --                          2.Multiple promo return 99
   --                          3.No promo return 0
   --
   -- 06/26/01   SL            Add logic to issue 100 free units
   --                          to digital phone with first-time annual
   --                          card (062601)
   --
   -- 11/20/01   SL            Add logic to deal with PLUS3 renewal
   --                          process
   -- 03/05/02   SL            Add logic to deal with 1 year service
   --                          non-plus card
   06/17/02   TCS    Added code to call sp_autopay_promo to get
                           the promotional units due to autopay/hybrid(06172002).
   06/21/02   TCS          Updated the cursor c_rt_promo to exclude Hybrid and
                           autopay promotions as well(06212002).Added promotion
                           codes for Autopay programs.
   06/24/02   TCS          Deleted the parameters p_pi_objid , p_access_days_in
                           p_access_days_out as it is no longer required
                           due to changes in sp_autopay_promo.
   27/06/02   TCS          Modified  code to call the renamed package
                           autopay_promo_pkg instead of SP_AUTOPAY_PRMO.
   -- 08/16/02   SL            Promotional code project
   --                          add more params
   -- 09/30/02   TCS          Modified the code to Pass the parameter p_promo_out_code
   --                         instead of p_promo_code when calling the autopay_promo_pkg.main
   -- 09/30/02   VA           Added a check to loop through the # of times
   --                         based on the # of cards passed
   -- 10/06/02   SL           Amigo project
   -- 10/18/02   VA           Modified to handle the new runtime promotion to give 150 units for
   --                         the 1st and 2nd Plus 3 Renewals
   -- 03/04/03   VA           Elimination of bonus units and days check for a promocode
   -- 04/02/03   GP           Add binding logic for double min promo
   -- 04/04/03   SU           Excluding the RTBONUS100 from runtime as it is handled in autopay_promo_pkg --CR 1049
   -- 04/10/03   SL           Clarify Upgrade - sequence
   -- 06/02/03   VA           Excluded new autopay promocodes - RTBONUS200, RTBONUS40, RTBONUSPT1
   -- 06/11/03   VA           Excluded new autopay promocode  - RTBONUS400
   -- 06/26/03   VA           Excluded new autopay promocode  - RTBONUS50
   -- 08/22/03   VA           Modified to fix 90 days stacking issue if a promo
   --                         issues access days (< 365) instead of units - MT35638,CR1812
   -- 12/25/03   VA           Excluded new autopay promocodes - RTBONUSFH1 - CR1827B
   -- 01/18/04   VA           Removed Stack Check (CR2293,CR2294)
   -- 07/07/04   VA           CR2739 - Specified columns in "INSERT INTO TABLE_X_PENDING_REDEMPTION" statement
   -- 08/27/04   VA           CR3181 - CR3181 - Fix for DMPP Issue (Add "source"  to the dynamic sql parameters
   -- 06/01/05   VA           CR3735 - WEBCSR Changes (Removed the display of count if ESN not qualified)
   -- 06/08/05   VA           Fix for CR3735 (PVCS Revision 1.15)
   -- 02/28/06   VA          FIX DMPP Autopay Program - CR5046 (PVCS Version 1.16)
   -- 04/04/06   VA         CR5067 - Fix get_esn_objid sub-function to get the latest objid based on latest
   --                        install date (PVCS Version 1.17)
   -- 05/08/06  VA          CR5221-1 changes
   --05/11/06   VA         Fix for CR5221-1
   --05/11/06   VA         Fix for CR5221-1
   -10/13/06    CL         CR5631 (PVCS Revision 1.22)
   -10/28/06    CL         CR5631-Commented out the functions that are not in use and added "ORDERED_PREDICATES" hint
   -                 (PVCS Revision 1.23)
   -11/07/06    VA         Same as in CLFYKOZ (PVCS Recision 1.24)
   -01/24/07    TZ         CR5854   modify the delete from table_x_pending_redemption (PVCS Recision 1.25 26)
  --15/11/06   RSI	  CR4479 Billing Platform Changes -Code Added to check for enrollment into
   --		  the current Autopay programs and deliver Additional Benefits.
   -04/11/07    TZ         CR5150 change the name field name.
   --06/14/07   CI       CR6209;  block promo on free corp cards
   --06/28/07   VA		 CR6182 NET10 300 Minutes to 100 On Activation and 100 On Next 2 redemptions

   --09/15/08   YM     CR7572 1.0 NEW_PLSQL add LLPAID for part_type
   -- *******************************************************************************************************************/-- 062601 by sl
  --********************************************************************************
  --$RCSfile: SP_RUNTIME_PROMO.sql,v $
  --$Revision: 1.10 $
  --$Author: mgovindarajan $
  --$Date: 2016/09/29 14:25:16 $
  --$ $Log: SP_RUNTIME_PROMO.sql,v $
  --$ Revision 1.10  2016/09/29 14:25:16  mgovindarajan
  --$ CR42361: Allow Runtime Promotions validate for TF smartphone
  --$
  --$ Revision 1.9  2013/08/08 13:26:36  mvadlapally
  --$ *** empty log message ***
  --$
  --$ Revision 1.8  2013/08/02 21:32:07  icanavan
  --$ surepay
  --$
  --$ Revision 1.7  2012/04/03 14:44:54  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$ Revision 1.6  2011/11/08 18:07:21  kacosta
  --$ CR17076 NET10 Runtime Promotion
  --$
  --$ Revision 1.5  2011/10/26 14:37:43  kacosta
  --$ CR17076 NET10 Runtime Promotion
  --$
  --$ Revision 1.4  2011/09/20 18:23:27  kacosta
  --$ CR17076 NET10 Runtime Promotion
  --$
  --$
  --********************************************************************************
   FUNCTION is_digital_phone (p_esn VARCHAR2)
      RETURN BOOLEAN;

   g_group2esn         table_x_group2esn%ROWTYPE;                  --11/20/01
   p_site_part_objid   NUMBER;
   p_total_units_out   NUMBER;
   p_pro_code          VARCHAR2 (50);
   p_ah_msg            VARCHAR2 (500);
   p_ah_status         VARCHAR2 (5);
   p_promo_ct          NUMBER;

/********************************* cwl speed up promo */
   FUNCTION test_access_days_rt_fun (p_access_days IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      IF p_access_days IS NULL
      THEN
         RETURN 1;
      END IF;

      FOR i IN g_red_card_tab.FIRST .. g_red_card_tab.LAST
      LOOP
         IF g_red_card_tab (i).red_code IS NULL
         THEN
            EXIT;
         END IF;

         IF g_red_card_tab (i).access_days = p_access_days
         THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END;

   FUNCTION test_promo_rt_fun (p_promo_code IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      IF p_promo_code IS NULL
      THEN
         RETURN 1;
      END IF;

      FOR i IN g_red_card_tab.FIRST .. g_red_card_tab.LAST
      LOOP
         IF g_red_card_tab (i).red_code IS NULL
         THEN
            EXIT;
         END IF;

         IF g_red_card_tab (i).x_promo_code = p_promo_code
         THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END;

   FUNCTION test_group_rt_fun (p_group_name IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      IF p_group_name IS NULL
      THEN
--      dbms_output.put_line('p_group_name is null');
         RETURN 1;
      ELSE
--      dbms_output.put_line('p_group_name :'||p_group_name);
         NULL;
      END IF;

      IF g_group_name_tab.FIRST IS NOT NULL
      THEN
         FOR i IN g_group_name_tab.FIRST .. g_group_name_tab.LAST
         LOOP
--      dbms_output.put_line('i:'||i);
            IF g_group_name_tab (i).x_group_name = p_group_name
            THEN
--        dbms_output.put_line('p_group_name:'||p_group_name||'g_group_name_tab('||i||').x_group_name'||
--                                                 g_group_name_tab(i).x_group_name);
               RETURN 1;
            END IF;
         END LOOP;
      END IF;

--    dbms_output.put_line('p_group_name is not in list:'||p_group_name);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line
                         (   'test_group_rpt_fun error!!!!!!!!!!!!!!!!!!!!!:'
                          || p_group_name
                         );
   END;

   FUNCTION test_rt_fun (p_units IN VARCHAR2, p_type IN VARCHAR2)
      RETURN NUMBER
   IS
      l_units_bigstr   VARCHAR2 (1000);
      l_units_smlstr   VARCHAR2 (1000);
      l_units_idxval   NUMBER          := 0;
   BEGIN
      IF p_units IS NULL
      THEN
--      dbms_output.put_line('prom_filter is null!!!!!!!!!!!!!!!!!!!!!');
         RETURN 1;
      ELSE
--      dbms_output.put_line('p_units:'||p_units);
         l_units_bigstr := p_units;

         LOOP
            l_units_idxval := INSTR (l_units_bigstr, ',');

            IF l_units_idxval = 0
            THEN
               l_units_smlstr := l_units_bigstr;
            ELSE
               l_units_smlstr :=
                               SUBSTR (l_units_bigstr, 1, l_units_idxval - 1);
               l_units_bigstr := SUBSTR (l_units_bigstr, l_units_idxval + 1);
            END IF;

            FOR i IN g_red_card_tab.FIRST .. g_red_card_tab.LAST
            LOOP
               IF g_red_card_tab (i).red_code IS NULL
               THEN
                  EXIT;
                  RETURN 0;
               END IF;

--          dbms_output.put_line('g_red_card_tab('||i||').units:'||g_red_card_tab(i).units||
--                               ' l_units_smlstr:'||l_units_smlstr);
               IF p_type = 'ACCESS DAYS'
               THEN
                  IF g_red_card_tab (i).access_days =
                                                   TO_NUMBER (l_units_smlstr)
                  THEN
                     RETURN 1;
                  END IF;
               ELSIF p_type = 'PROMO CODES'
               THEN
                  IF g_red_card_tab (i).x_promo_code = l_units_smlstr
                  THEN
                     RETURN 1;
                  END IF;
               ELSIF p_type = 'UNITS'
               THEN
                  IF g_red_card_tab (i).units = TO_NUMBER (l_units_smlstr)
                  THEN
                     RETURN 1;
                  END IF;
               --CR17076 Start Kacosta 09/12/2011
               --ELSE
               --   RETURN 1;
               --CR17076 End Kacosta 09/12/2011
               END IF;
            END LOOP;

            EXIT WHEN l_units_idxval = 0;
         END LOOP;
      END IF;

--    dbms_output.put_line('no match on units found!!!!!!!!!!!!!!!!!!!!!');
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
--    dbms_output.put_line('exception in units function');
         RETURN 1;
   END;

/********************************* cwl speed up promo */
   PROCEDURE main (
      p_esn                      VARCHAR2,
      p_units                    NUMBER,
      p_access_days              NUMBER,
      p_red_code01               VARCHAR2,
      p_red_code02               VARCHAR2 DEFAULT NULL,
      p_red_code03               VARCHAR2 DEFAULT NULL,
      p_red_code04               VARCHAR2 DEFAULT NULL,
      p_red_code05               VARCHAR2 DEFAULT NULL,
      p_red_code06               VARCHAR2 DEFAULT NULL,
      p_red_code07               VARCHAR2 DEFAULT NULL,
      p_red_code08               VARCHAR2 DEFAULT NULL,
      p_red_code09               VARCHAR2 DEFAULT NULL,
      p_red_code10               VARCHAR2 DEFAULT NULL,
      p_source_system            VARCHAR2,                         -- 08/14/02
      p_promo_code               VARCHAR2,                         -- 08/14/02
      p_transaction_type         VARCHAR2,                         -- 08/14/02
      p_zipcode                  VARCHAR2,                         -- 08/14/02
      p_language                 VARCHAR2,                         -- 08/14/02
      p_objid                    NUMBER,                           -- 01/30/07          CR5854      call transaction id
      p_units_out          OUT   NUMBER,
      p_access_days_out    OUT   NUMBER,
      p_status             OUT   VARCHAR2,
      p_msg                OUT   VARCHAR2,
      p_promo_out_code     OUT   VARCHAR2                      -- 051701 by SL
   )
   IS
 	  -- CR4479 Billing Platform Changes
      l_error_code      NUMBER;
      l_error_message   VARCHAR2(255);
      l_bonus_minutes   NUMBER;
      -- Billing Platfrom Changes
   BEGIN

   --CR42361: Allow runtime promo for TF Smartphone
   IF (device_util_pkg.get_smartphone_fun(P_ESN) > 0 OR
      (device_util_pkg.get_smartphone_fun(P_ESN) = 0 AND sa.bau_util_pkg.get_esn_brand(P_ESN) = 'TRACFONE'))
   THEN
      doruntimepromo (p_esn,
                      p_units,
                      p_access_days,
                      p_red_code01,
                      p_red_code02,
                      p_red_code03,
                      p_red_code04,
                      p_red_code05,
                      p_red_code06,
                      p_red_code07,
                      p_red_code08,
                      p_red_code09,
                      p_red_code10,
                      p_source_system,                             -- 08/14/02
                      p_promo_code,                                -- 08/14/02
                      p_transaction_type,                          -- 08/14/02
                      p_zipcode,                                   -- 08/14/02
                      p_language,                                  -- 08/14/02
                      p_objid,                                     -- 01/30/07      CR5854      call transaction id
                      p_units_out,
                      p_access_days_out,
                      p_status,
                      p_msg,
                      p_promo_out_code                         -- 051701 by SL
                     );

      /* ------------------------------ Billing Platform Changes ---------------------------------------- */
      /* Start - CR4479 - Changes made for supporting Billing Platform                                    */
      /* Billing Platform Modifications:
                 The procedure checks for enrollment into the current autopay programs
                 and delivers the benefits.                                                               */
         BILLING_RUNTIMEPROMO (
                    p_red_code01,
                    p_red_code02,
                    p_red_code03,
                    p_red_code04,
                    p_red_code05,
                    p_red_code06,
                    p_red_code07,
                    p_red_code08,
                    p_red_code09,
                    p_red_code10,
                    p_esn,
                    l_bonus_minutes,
                    l_error_code,
                    l_error_message
                    );
          if ( l_error_code = 0 ) then      -- Success. Redemption Qualified for Billing Platform Promotions
                p_units_out := p_units_out + l_bonus_minutes;
                p_msg := l_error_message;
          end if;
      /* End   - CR4479 - Changes for supporting Billing Platform */
      /* ------------------------------ Billing Platform Changes ---------------------------------------- */
      IF (p_status = 'S' OR p_status = 'N')
      THEN
         autopay_promo_pkg.main
                               (p_esn,
                                p_units_out,
                                p_units,
                                p_promo_ct,
                                p_msg,
                                --p_promo_code,  -- changed by TCS  09/30/2002
                                p_promo_out_code, -- changed by TCS 09/30/2002
                                p_site_part_objid,
                                p_red_code01,
                                p_red_code02,
                                p_red_code03,
                                p_red_code04,
                                p_red_code05,
                                p_red_code06,
                                p_red_code07,
                                p_red_code08,
                                p_red_code09,
                                p_red_code10,
                                p_total_units_out,
                                p_ah_status,
                                p_ah_msg,
                                p_pro_code
                               );
         p_units_out := p_total_units_out;
         p_msg := p_ah_msg;
         p_promo_out_code := p_pro_code;
         p_status := p_ah_status;

         IF (p_ah_status = 'S' OR p_ah_status = 'N')
         THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
      ELSE
         ROLLBACK;
      END IF;
      END IF ;
   END;

   /*************************************************************************
   * Procedure: DoRuntimePromo
   * Description: Scan through all the runtime promotion for the ESN.
   *              If qulified, insert a row into table_x_pending_redemption
   * Basic Program Logic:
   *   1. Annual Plan Promotion
   *      1.1 Redeem annual card
   *          1.1.1 If it is First Time to redeem Annual card
   *                Insert a row into table_x_group2esn with x_annual_plan=3
   *                Else
   *                Insert a row into table_x_pending_redemption
   *      1.2 Redeem normal redemption card
   *          1.2.1 If esn is in annual plan group
   *                Insert a row into table_x_pending_redemption
   *                Else no additional free units issued
   *
   *
   *   2. Non-Annual Plan Promotion
   *      2.1 Loop all valid runtime promotion
   *          2.1.1 get x_sql_statement field, bind variables and run dynamic sql
   *                statement
   *          2.1.2 if qulified then insert a row into table_x_pending_redemption
   *                else do nothing
   *                Fetch next record
   *      2.2 End loop
   *   3. If qulified for any of runtime promotion
   *       Return 'S' with message
   *      If not qulified Return 'N' with message
   *      Else <oracle error> return 'F' with message
   **************************************************************************/
   PROCEDURE doruntimepromo (
      p_esn                      VARCHAR2,
      p_units                    NUMBER,
      p_access_days              NUMBER,
      p_red_code01               VARCHAR2,
      p_red_code02               VARCHAR2 DEFAULT NULL,
      p_red_code03               VARCHAR2 DEFAULT NULL,
      p_red_code04               VARCHAR2 DEFAULT NULL,
      p_red_code05               VARCHAR2 DEFAULT NULL,
      p_red_code06               VARCHAR2 DEFAULT NULL,
      p_red_code07               VARCHAR2 DEFAULT NULL,
      p_red_code08               VARCHAR2 DEFAULT NULL,
      p_red_code09               VARCHAR2 DEFAULT NULL,
      p_red_code10               VARCHAR2 DEFAULT NULL,
      p_source_system            VARCHAR2,                         -- 08/14/02
      p_promo_code               VARCHAR2,                         -- 08/14/02
      p_transaction_type         VARCHAR2,                         -- 08/14/02
      p_zipcode                  VARCHAR2,                         -- 08/14/02
      p_language                 VARCHAR2,                         -- 08/14/02
      p_objid                    NUMBER,                           -- 01/30/07          CR5854      call transaction id
      p_units_out          OUT   NUMBER,
      p_access_days_out    OUT   NUMBER,
      p_status             OUT   VARCHAR2,
      p_msg                OUT   VARCHAR2,
      p_promo_out_code     OUT   VARCHAR2                      -- 051701 by SL
   )
   IS
--01/26/2001 by SL
      -- Don't check promo hist at this level
      -- promo hist will be validated at sql statement level for
      -- specific promotion
      --
      --06/26/01 062601 by SL
      --
      /*
      CURSOR c_rt_promo (c_sp_objid number) IS
      SELECT *
      FROM table_X_PROMOTION a
      WHERE (sysdate BETWEEN x_start_date AND x_end_date
           OR x_end_date IS NULL)
      AND x_promo_type = 'Runtime'
      AND x_promo_code <> 'RTANNUAL'
      AND x_sql_statement IS NOT NULL
      AND NOT EXISTS (SELECT 'X'
                    FROM TABLE_X_PENDING_REDEMPTION c
                    WHERE pend_red2x_promotion = a.objid
                    AND   x_pend_red2site_part = c_sp_objid
                    );
      -- 01/24/2001 by SL */
      -- 08/16/02
      --
      /*
      CURSOR c_rt_promo (c_sp_objid number) IS
        SELECT *
        FROM table_X_PROMOTION a
        WHERE (sysdate BETWEEN x_start_date AND x_end_date
               OR x_end_date IS NULL)
        AND x_promo_type = 'Runtime'
        AND x_promo_code not in ('RTANNUAL','RTANNUAL02')
        AND x_sql_statement IS NOT NULL
        AND NOT EXISTS (SELECT 'X'
                        FROM TABLE_X_PENDING_REDEMPTION c
                        WHERE pend_red2x_promotion = a.objid
                        AND   x_pend_red2site_part = c_sp_objid
                        ); */
/********************************* cwl speed up promo */
      --CR17076 Start kacosta 10/26/2011
      --CURSOR c_rt_promo (p_restricted_use in number) --CR6182 Added the in parameter
      CURSOR c_rt_promo (c_n_esn_brand_objid table_bus_org.objid%TYPE)
      --CR17076 End kacosta 10/26/2011
      IS
         SELECT   /*+ ORDERED_PREDICATES */
                  p.*
             FROM table_x_promotion p
            WHERE 1 = 1
              AND p.x_sql_statement IS NOT NULL
              AND p.x_promo_type = 'Runtime'
              AND (   SYSDATE BETWEEN p.x_start_date AND p.x_end_date
                   OR p.x_end_date IS NULL
                  )
              AND (    p.x_promo_code NOT IN
                                      ('RTANNUAL', 'RTANNUAL02', 'RTAUTOPAY')
                   AND p.x_promo_code NOT LIKE 'RTBONUS%'
                  )
              AND 1 =
                     DECODE
                        (test_rt_fun (p.x_units_filter, 'UNITS'),
                         1, DECODE
                               (test_group_rt_fun (p.x_group_name_filter),
                                1, DECODE
                                        (test_rt_fun (p.x_promo_code_filter,
                                                      'PROMO CODES'
                                                     ),
                                         1, test_rt_fun
                                                      (p.x_access_days_filter,
                                                       'ACCESS DAYS'
                                                      ),
                                         0
                                        ),
                                0
                               ),
                         0
                        )
            -- CR17076 Start kacosta 10/27/2011
						--and nvl(x_amigo_allowed,0) = p_restricted_use --CR6182 Added the check
            AND NVL(p.promotion2bus_org,-1) = CASE
                                                WHEN p.promotion2bus_org IS NOT NULL THEN
                                                  c_n_esn_brand_objid
                                                ELSE
                                                  -1
                                              END
            -- CR17076 End kacosta 10/27/2011
         ORDER BY p.x_promo_code;

      CURSOR group_name_curs
      IS
         SELECT pg.group_name
           FROM table_x_promotion_group pg,
                table_x_group2esn ge,
                table_part_inst pi
          WHERE 1 = 1
            AND ge.groupesn2x_promo_group + 0 = pg.objid
            AND ge.groupesn2part_inst = pi.objid
            AND pi.part_serial_no = p_esn;

      l_group_name_cnt        NUMBER               := 0;
/********************************* cwl speed up promo */
/****************************comment out to test speed up promo
      CURSOR c_rt_promo
      IS
         SELECT   *
             FROM table_x_promotion a
            WHERE (   SYSDATE BETWEEN x_start_date AND x_end_date
                   OR x_end_date IS NULL
                  )
--CR5046 Start changes
--       AND x_promo_code NOT IN ('RTANNUAL', 'RTANNUAL02', 'RTAUTOPAY',
--       'RTBONUS30', 'RTBONUS60', 'RTBONUS150', 'RTBONUS300', 'RTBONUS100', --CR 1049
--       'RTBONUS200', -- VA 06/02/03
--       'RTBONUS40', 'RTBONUSPT1', -- End 06/02/03
--       --                   'RTBONUS400',   -- VA 06/11/03
--       'RTBONUS50', -- VA 06/26/03
--       'RTBONUSFH1' --VA 12/25/03 (CR1827B)
--       ) -- 06212002 TCS
              AND (    x_promo_code NOT IN
                                      ('RTANNUAL', 'RTANNUAL02', 'RTAUTOPAY')
                   AND x_promo_code NOT LIKE 'RTBONUS%'
                  )
--CR5046 End changes
              AND x_sql_statement IS NOT NULL
              AND x_promo_type = 'Runtime'
         --GP 04/02/03: Do not touch line below, double minute promo is depended on promo_code order
         ORDER BY x_promo_code;
*/
      -- END of 08/16/02
      l_i                     NUMBER;
      l_j                     NUMBER;
      l_site_part_objid       NUMBER;
      l_pi_objid              NUMBER;
      l_promogrp_objid        NUMBER;
      l_ann_promo_info        promo_rec_t;
      l_ann2_promo_info       promo_rec_t;                      --062601 by SL
      l_sql_text              VARCHAR2 (4000);
      l_cursorid              INTEGER;
      l_rc                    INTEGER;
      l_chars                 VARCHAR2 (10);
      l_dummy                 VARCHAR2 (10);
      l_units_total           NUMBER               := 0;
      l_max_access_days       NUMBER               := 0;
      l_ann                   NUMBER               := 0;
      l_non_ann               NUMBER               := 0;
      l_esn_in_ann_plan       BOOLEAN              := NULL;
      l_process_annual_plan   BOOLEAN              := TRUE;
      l_promo_msg             VARCHAR2 (1000);
      l_promo_code            VARCHAR2 (50);                 -- 05/17/01 by SL
      l_bind_var              VARCHAR2 (50);                 -- 01/26/01 by SL
      l_g_msg                 VARCHAR (1000);                -- 01/26/01 by SL
      l_ann_num               NUMBER               := 0;
      l_rt_promo_ct           NUMBER               := 0;
      --062601 count total number of rt promotion
      l_start_date            DATE                 := SYSDATE;     -- 11/20/01
      l_end_date              DATE;                                -- 11/20/01
      l_action_type           VARCHAR2 (20)        := 'ACTIVATION';
      -- 11/20/01
      l_renewal_promo         promo_rec_t;                         -- 11/20/01
      l_renewal               BOOLEAN              := FALSE;       -- 11/20/01
      l_promo_rec             c_rt_promo%ROWTYPE;                  -- 08/16/02
      l_in_promo_units        NUMBER               := 0;           -- 08/16/02
      l_in_promo_days         NUMBER               := 0;           -- 08/16/02
      -- GP 04/01/2003
      l_pm_status             VARCHAR2 (30);
      l_pm_msg                VARCHAR2 (2000);
      l_is_plsql              VARCHAR2 (1)         := 'N';
      l_step                  VARCHAR2 (200);
      --
      --Variable to decide on the # of times to loop - 09/30/02
      l_loop_times            NUMBER               := 1;
      --Variable added for 10/18/02 changes
      l_ren_cnt               NUMBER               := 0;
      l_pend_cnt              NUMBER               := 0;
      l_is_digital            BOOLEAN;
      l_esn_ship_date         DATE;
      l_esn_status            VARCHAR2 (20);
      --Variable added to get the total access days of promo and pin - 08/22/03
      l_promo_pin_days        NUMBER               := 0;

      --test
      CURSOR c_test
      IS
         SELECT *
           FROM table_x_group2esn
          WHERE groupesn2part_inst IN (SELECT objid
                                         FROM table_part_inst
                                        WHERE part_serial_no = p_esn);

      --test
--CR5221-1 Start
      l_ctr                   NUMBER               := 0;
      l_chk                   NUMBER               := 0;
      l_highest_units         NUMBER               := 0;
      l_objid                 NUMBER               := 0;
      l_promo_type            VARCHAR2 (20);
      l_long_units            NUMBER               := 0;
--CR5221-1 End

   BEGIN
-----------------------------------------------------------------------------------------------------
-- new cwl code to bypass promos
-----------------------------------------------------------------------------------------------------
      -- no anroid promos
      --CR42361: Allow TF Smartphone for Runtime promotions.
      IF device_util_pkg.get_smartphone_fun(P_ESN) = 0 AND sa.bau_util_pkg.get_esn_brand(P_ESN) <> 'TRACFONE'
      THEN
      return ;
      end if ;

      g_group_name_tab.DELETE;

      FOR group_name_rec IN group_name_curs
      LOOP
         DBMS_OUTPUT.put_line (   'group_name_rec.x_group_name'
                               || group_name_rec.group_name
                              );
         g_group_name_tab (l_group_name_cnt).x_group_name :=
                                                     group_name_rec.group_name;
         l_group_name_cnt := l_group_name_cnt + 1;
      END LOOP;

      IF g_group_name_tab.FIRST IS NOT NULL
      THEN
         FOR i IN g_group_name_tab.FIRST .. g_group_name_tab.LAST
         LOOP
            DBMS_OUTPUT.put_line (   'g_group_name_tab('
                                  || i
                                  || ').x_group_name'
                                  || g_group_name_tab (i).x_group_name
                                 );
         END LOOP;
      END IF;

-----------------------------------------------------------------------------------------------------
-- new cwl code to bypass promos
-----------------------------------------------------------------------------------------------------
      --
      -- Initialize variables
      --
      g_red_card_tab.DELETE;
      g_non_ann_card_tab.DELETE;
      g_ann_card_tab.DELETE;
      g_red_card_tab (0).red_code := p_red_code01;
      g_red_card_tab (1).red_code := p_red_code02;
      g_red_card_tab (2).red_code := p_red_code03;
      g_red_card_tab (3).red_code := p_red_code04;
      g_red_card_tab (4).red_code := p_red_code05;
      g_red_card_tab (5).red_code := p_red_code06;
      g_red_card_tab (6).red_code := p_red_code07;
      g_red_card_tab (7).red_code := p_red_code08;
      g_red_card_tab (8).red_code := p_red_code09;
      g_red_card_tab (9).red_code := p_red_code10;
      l_i := 0;
      l_site_part_objid := NULL;
      l_max_access_days := NVL (p_access_days, 0);                 -- 08/16/02
      p_status := 'F';
      p_units_out := p_units;
      p_access_days_out := p_access_days;
      --10/18/02 changes
      l_is_digital := is_digital_phone (p_esn);
      get_esn_info (p_esn, l_esn_ship_date, l_esn_status);

      --End 10/18/02 Changes
      FOR i IN 0 .. 9
      LOOP
         IF g_red_card_tab (i).red_code IS NOT NULL
         THEN
            get_red_card_info (g_red_card_tab (i));

            IF (   g_red_card_tab (i).units IS NULL
                OR g_red_card_tab (i).access_days IS NULL
               )
            THEN
               p_status := 'F';
               p_msg :=
                     'Redemption card '
                  || g_red_card_tab (i).red_code
                  || ' is invalid.';
               RETURN;
            END IF;

            IF (   (g_red_card_tab (i).annual_status <> 'ANNUAL')
                OR (g_red_card_tab (i).annual_status IS NULL)
               )
            THEN
               g_non_ann_card_tab (l_non_ann) := g_red_card_tab (i);
               l_non_ann := l_non_ann + 1;
            ELSE
               g_ann_card_tab (l_ann) := g_red_card_tab (i);
               l_ann := l_ann + 1;
            END IF;
         END IF;
      END LOOP;

      --
      --Run the loop once if no cards is passed -- 09/30/02
      IF (g_non_ann_card_tab.COUNT + g_ann_card_tab.COUNT) <> 0
      THEN
         l_loop_times := g_non_ann_card_tab.COUNT + g_ann_card_tab.COUNT;
      ELSE
         l_loop_times := 1;
      END IF;

      --end 09/30/02 changes
      --
      --debug
      --DEBUG01;
      --return;
      /* verify site part */
      l_site_part_objid := get_esn_objid (p_esn);
      p_site_part_objid := l_site_part_objid;

      IF l_site_part_objid IS NULL
      THEN
         p_status := 'N';
         p_msg := 'Fail to find objid for esn ' || p_esn;
         RETURN;
      END IF;

      /* verify part inst */
      l_pi_objid := get_esn_part_inst_objid (p_esn);

      IF l_pi_objid IS NULL
      THEN
         p_status := 'N';
         p_msg := 'Fail to find part inst objid for esn ' || p_esn;
         RETURN;
      END IF;

      /* verify promotion group */
      l_promogrp_objid := get_promogrp_objid ('ANNUALPLAN');
      l_ann_promo_info := get_ann_promo_info;

      IF (   (l_promogrp_objid IS NULL)
          OR (l_ann_promo_info.promo_objid IS NULL)
          OR (get_restricted_use (p_esn) <> 0)
         )                                  -- 10/06/02 amigo will not qualify
      THEN
         l_process_annual_plan := FALSE;
      END IF;

      -- 08/16/02
      --
      l_promo_code := LTRIM (RTRIM (p_promo_code));
      l_promo_pin_days := 0;

      IF (l_promo_code IS NOT NULL)
      THEN
         BEGIN
            SELECT *
              INTO l_promo_rec
              FROM table_x_promotion
             WHERE x_promo_code = LTRIM (RTRIM (p_promo_code))
               AND x_promo_type = 'Promocode';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_status := 'F';
               p_msg := 'Promo Code ' || p_promo_code || ' is not valid.';
               RETURN;
         END;

         -- 03/04/03 Changes
         --          IF (   NVL (l_promo_rec.x_units, 0) <> 0
         --              OR NVL (l_promo_rec.x_access_days, 0) <> 0)
         --          THEN
         ---- End 03/04/03 Changes
         SELECT COUNT (1)
           INTO l_rc
           FROM table_x_pending_redemption
          WHERE pend_red2x_promotion = l_promo_rec.objid
            AND x_pend_red2site_part = l_site_part_objid;

         IF l_rc = 0
         THEN
            INSERT INTO table_x_pending_redemption
                        (objid, pend_red2x_promotion,
                         x_pend_red2site_part, x_pend_type
                         --, x_granted_from2x_call_trans                          --CR5854
                         , redeem_in2call_trans                                   --CR5150  change the field name from CR5854
                        )
                 VALUES (
                         -- 04/10/03 seq_x_pending_redemption.nextval + POWER (2, 28),
                         seq ('x_pending_redemption'), l_promo_rec.objid,
                         l_site_part_objid, l_promo_rec.x_promo_type
                         , p_objid                                              --CR5854
                        );

            IF UPPER (p_source_system) <> 'CLARIFY'
            THEN
               l_in_promo_units := NVL (l_promo_rec.x_units, 0);
               l_in_promo_days := NVL (l_promo_rec.x_access_days, 0);
               l_promo_code := l_promo_rec.x_promo_code;
               l_rt_promo_ct := l_rt_promo_ct + 1;
               p_msg := l_promo_rec.x_promotion_text;
            END IF;
         END IF;

         -- 03/04/03 Changes
         --         END IF;
         -- End 03/04/03 Changes
         IF (UPPER (l_promo_rec.x_transaction_type) = 'PROGRAM')
         THEN
            BEGIN
               SELECT x_promo_mtm2x_promo_group
                 INTO l_promogrp_objid
                 FROM table_x_promotion_mtm mtm
                WHERE mtm.x_promo_mtm2x_promotion = l_promo_rec.objid;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_status := 'F';
                  p_msg := 'Promo group is not defined for this promotion.';
                  RETURN;
            END;

            l_end_date := l_start_date + l_promo_rec.x_access_days;

            SELECT COUNT (1)
              INTO l_rc
              FROM table_x_group2esn
             WHERE groupesn2part_inst = l_pi_objid
               AND groupesn2x_promo_group = l_promogrp_objid;

            IF l_rc = 0
            THEN
               BEGIN
                  INSERT INTO table_x_group2esn
                              (objid, x_annual_plan, groupesn2part_inst,
                               groupesn2x_promo_group, x_end_date,
                               x_start_date
                              )
                       VALUES (
                               -- 04/10/03 seq_x_group2esn.nextval + POWER (2, 28),
                               seq ('x_group2esn'), 3,          -- pending new
                                                      l_pi_objid,
                               l_promogrp_objid, l_end_date,
                               l_start_date
                              );

                  l_promogrp_objid := NULL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_status := 'F';
                     p_msg :=
                           'Fail to insert part inst '
                        || l_pi_objid
                        || ' and promo group '
                        || l_promogrp_objid
                        || ' into table_x_group2esn >> '
                        || SUBSTR (SQLERRM, 1, 100);
                     RETURN;
               END;
            END IF;
         END IF;
      END IF;

      l_ctr := l_ctr + 1;                                           --CR5221-1
      crea_promo_arr (l_promo_code,
                      l_in_promo_units,
                      l_ctr,
                      l_promo_rec.objid,
                      'Promocode',
                      l_chk
                     );

      --CR5221-1

      -- END of 08/16/02
      --
      --  **********  Start to process Annual Plan ********************
      --
      IF (l_process_annual_plan = TRUE AND g_red_card_tab.COUNT > 0)
      THEN
         --
         --  Process Annual card if any
         --
         IF g_ann_card_tab.COUNT > 0
         THEN
            FOR i IN 0 .. g_ann_card_tab.COUNT - 1
            LOOP
               IF (   (l_esn_status = '52' AND is_annual_plan (p_esn) = TRUE)
                   OR l_esn_in_ann_plan = TRUE
                  )
               THEN
                  BEGIN
                     INSERT INTO table_x_pending_redemption
                                 (objid,
                                  pend_red2x_promotion,
                                  x_pend_red2site_part, x_pend_type
                                  --, x_granted_from2x_call_trans                                   --CR5854
                                  , redeem_in2call_trans                                   --CR5150  change the field name from CR5854
                                 )
                          VALUES (
                                  -- 04/10/03 seq_x_pending_redemption.nextval + POWER (2, 28),
                                  seq ('x_pending_redemption'),
                                  l_ann_promo_info.promo_objid,
                                  l_site_part_objid, 'Runtime'
                                  , p_objid                                                      --CR5854
                                 );

                     l_units_total :=
                               l_units_total + NVL (l_ann_promo_info.units, 0);
                     -- sl 050301 Stack Day
                     --IF l_ann_promo_info.access_days > l_max_access_days THEN
                     --   l_max_access_days := l_ann_promo_info.access_days;
                     --END IF;
                     l_max_access_days :=
                              l_max_access_days + l_ann_promo_info.access_days;
                     -- end sl 050301
                     l_promo_code := l_ann_promo_info.promo_code;
                     -- 05/17/01 by sl
                     l_rt_promo_ct := l_rt_promo_ct + 1;              --062601
                     p_msg := l_ann_promo_info.MESSAGE;
                     l_ctr := l_ctr + 1;
                     --CR5221-1                             --062601
                     crea_promo_arr (l_promo_code,
                                     l_ann_promo_info.units,
                                     l_ctr,
                                     l_ann_promo_info.promo_objid,
                                     'Runtime',
                                     l_chk
                                    );                              --CR5221-1
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_status := 'F';
                        p_msg :=
                              'Fail to insert into table_x_pending_redemption.'
                           || 'Red code='
                           || g_non_ann_card_tab (i).red_code
                           || ' Site part objid='
                           || l_site_part_objid
                           || ' Promo objid='
                           || l_ann_promo_info.promo_objid
                           || SUBSTR (SQLERRM, 100);
                        RETURN;
                  END;

                  l_esn_in_ann_plan := TRUE;

                  -- 11/20/01
                  -- Add renewal process
                  --  1.get info. of renewal promotion
                  --  2.copy old entry to table_x_group_hist
                  --  3.update existing entry in table_x_group2esn
                  BEGIN
--10/18/02 Changes
                     /*                     SELECT objid, x_units, x_access_days, x_promotion_text,
                            x_promo_code
                       INTO l_renewal_promo
                       FROM table_x_promotion
                      WHERE (   SYSDATE BETWEEN x_start_date AND x_end_date
                             OR x_end_date IS NULL)
                        AND  0 = get_restricted_use ( p_esn )  -- 10/06/02 amigo will not qualify
                        AND x_promo_code = 'RTANNUALRN'
                        AND x_promo_type = 'Runtime';*/
                     SELECT objid,
                            x_units,
                            x_access_days,
                            x_promotion_text,
                            x_promo_code,
                            x_usage
                       INTO l_renewal_promo
                       FROM table_x_promotion
                      WHERE (   SYSDATE BETWEEN x_start_date AND x_end_date
                             OR x_end_date IS NULL
                            )
                        AND 0 = get_restricted_use (p_esn)
                        -- 10/06/02 amigo will not qualify
                        AND x_promo_code = 'RTANNRN02'
                        AND x_promo_type = 'Runtime';

                     -- End 10/18/02 Changes
                     l_renewal := TRUE;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;

--10/18/02 Changes
                  BEGIN
                     SELECT COUNT (1)
                       INTO l_ren_cnt
                       FROM table_x_promotion pr,
                            table_x_promo_hist ph,
                            table_x_call_trans ct
                      WHERE ph.promo_hist2x_promotion = pr.objid
                        AND ph.promo_hist2x_call_trans = ct.objid
                        AND ct.x_service_id = p_esn
                        AND x_promo_code || '' IN ('RTANNRN02', 'RTANNUALRN')
                        AND x_promo_type || '' = 'Runtime';
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_ren_cnt := 0;
                  END;

                  BEGIN
                     SELECT COUNT (1)
                       INTO l_pend_cnt
                       FROM table_x_promotion pr,
                            table_x_pending_redemption pend,
                            table_site_part sp
                      WHERE sp.objid = pend.x_pend_red2site_part
                        AND pend.pend_red2x_promotion = pr.objid
                        AND x_promo_code || '' IN ('RTANNRN02')
                        AND sp.objid = l_site_part_objid;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_pend_cnt := 0;
                  END;

                  --End 10/18/02 Changes
                  IF l_renewal = TRUE
                  THEN
-- 10/18/02 Changes Continue only if it is a digital esn and shipped before March 01, 2002
                     IF     l_is_digital
                        AND NVL (l_esn_ship_date, SYSDATE) < '01-mar-02'
                     THEN
                        IF (l_ren_cnt + l_pend_cnt) <
                                                  l_renewal_promo.promo_usage
                        THEN
--End 10/18/02 Changes
                           l_end_date :=
                                l_start_date
                              + g_ann_card_tab (i).access_days
                              + NVL (l_renewal_promo.access_days, 0);

                           BEGIN
                              INSERT INTO table_x_pending_redemption
                                          (objid,
                                           pend_red2x_promotion,
                                           x_pend_red2site_part, x_pend_type
                                           --, x_granted_from2x_call_trans                                   --CR5854
                                           , redeem_in2call_trans                                   --CR5150  change the field name from CR5854
                                          )
                                   VALUES (
                                           -- 04/10/03 seq_x_pending_redemption.nextval +POWER (2, 28),
                                           seq ('x_pending_redemption'),
                                           l_renewal_promo.promo_objid,
                                           l_site_part_objid, 'Runtime'
                                           , p_objid                                                      --CR5854
                                          );
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 p_status := 'F';
                                 p_msg :=
                                       'Fail to insert into table_x_pending_redemption.'
                                    || ' Site part objid='
                                    || l_site_part_objid
                                    || ' Promo objid='
                                    || l_renewal_promo.promo_objid
                                    || SUBSTR (SQLERRM, 100);
                                 RETURN;
                           END;

                           BEGIN
                              INSERT INTO table_x_group_hist
                                          (objid,
                                           x_start_date, x_end_date,
                                           x_action_date, x_action_type,
                                           x_annual_plan,
                                           grouphist2part_inst,
                                           grouphist2x_promo_group
                                          )
                                   VALUES (
                                           -- 04/10/03 seq_x_group_hist.nextval + POWER (2, 28),
                                           seq ('x_group_hist'),
                                           l_start_date, l_end_date,
                                           l_start_date, 'RENEWAL',
                                           g_group2esn.x_annual_plan,
                                           g_group2esn.groupesn2part_inst,
                                           g_group2esn.groupesn2x_promo_group
                                          );
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 p_status := 'F';
                                 p_msg :=
                                       'Fail to insert part inst '
                                    || l_pi_objid
                                    || ' and promo group '
                                    || l_promogrp_objid
                                    || ' into table_x_group_hist >> '
                                    || SUBSTR (SQLERRM, 1, 100);
                                 RETURN;
                           END;

                           -- update existe record
                           BEGIN
                              UPDATE table_x_group2esn
                                 SET x_start_date = l_start_date,
                                     x_end_date = l_end_date,
                                     x_annual_plan = 2
                               WHERE groupesn2part_inst = l_pi_objid
                                 AND groupesn2x_promo_group = l_promogrp_objid;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 p_status := 'F';
                                 p_msg :=
                                       'Fail to update table_x_group_hist >> '
                                    || SUBSTR (SQLERRM, 1, 100);
                                 RETURN;
                           END;

                           l_units_total :=
                                l_units_total + NVL (l_renewal_promo.units, 0);
                           l_max_access_days :=
                                l_max_access_days
                              + NVL (l_renewal_promo.access_days, 0);
                           l_promo_code := l_renewal_promo.promo_code;
                           l_rt_promo_ct := l_rt_promo_ct + 1;
                           p_msg := l_renewal_promo.MESSAGE;
                           l_ctr := l_ctr + 1;                      --CR5221-1
                           crea_promo_arr (l_promo_code,
                                           l_renewal_promo.units,
                                           l_ctr,
                                           l_renewal_promo.promo_objid,
                                           'Runtime',
                                           l_chk
                                          );                        --CR5221-1
                        END IF;
--end of usage check
                     END IF;
-- end of esn technology and ship date check
                  END IF;
--end of renewal process
               -- end 11/20/01
               ELSE
                  --
                  -- Redeem first annual card
                  --
                  -- 11/20/01 add x_end_date=sysdate+ access days on the card
                  --          add entry to table_x_group_hist
                  l_end_date := l_start_date + g_ann_card_tab (i).access_days;

                  BEGIN
                     INSERT INTO table_x_group2esn
                                 (objid, x_annual_plan, groupesn2part_inst,
                                  groupesn2x_promo_group, x_end_date,
                                  x_start_date
                                 )
                          VALUES (
                                  -- 04/10/03 seq_x_group2esn.nextval + POWER (2, 28),
                                  seq ('x_group2esn'), 3,       -- pending new
                                                         l_pi_objid,
                                  l_promogrp_objid, l_end_date,
                                  l_start_date
                                 );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_status := 'F';
                        p_msg :=
                              'Fail to insert part inst '
                           || l_pi_objid
                           || ' and promo group '
                           || l_promogrp_objid
                           || ' into table_x_group2esn >> '
                           || SUBSTR (SQLERRM, 1, 100);
                        RETURN;
                  END;

                  -- 11/20/01
                  --
                  BEGIN
                     INSERT INTO table_x_group_hist
                                 (objid, x_start_date,
                                  x_end_date, x_action_date, x_action_type,
                                  x_annual_plan, grouphist2part_inst,
                                  grouphist2x_promo_group
                                 )
                          VALUES (
                                  -- 04/10/03 seq_x_group_hist.nextval + POWER (2, 28),
                                  seq ('x_group_hist'), l_start_date,
                                  l_end_date, l_start_date, l_action_type,
                                  1, l_pi_objid,
                                  l_promogrp_objid
                                 );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_status := 'F';
                        p_msg :=
                              'Fail to insert part inst '
                           || l_pi_objid
                           || ' and promo group '
                           || l_promogrp_objid
                           || ' into table_x_group_hist >> '
                           || SUBSTR (SQLERRM, 1, 100);
                        RETURN;
                  END;

                  -- end 11/20/01
                  l_esn_in_ann_plan := TRUE;

                  --
                  -- 062601
                  -- If phone is digital, issue promotion 'RTANNUAL02'
                  --                  IF is_digital_phone (p_esn)
                  IF l_is_digital
                  THEN
                     BEGIN
                        SELECT objid,
                               x_units,
                               x_access_days,
                               x_promotion_text,
                               x_promo_code,
                               x_usage
                          INTO l_ann2_promo_info
                          FROM table_x_promotion
                         WHERE (   SYSDATE BETWEEN x_start_date AND x_end_date
                                OR x_end_date IS NULL
                               )
                           AND SYSDATE - 365 <
                                  (SELECT NVL (MIN (install_date), SYSDATE)
                                     FROM table_site_part sp
                                    WHERE sp.part_status || '' IN
                                                       ('Active', 'Inactive')
                                      AND sp.site_part2site =
                                             (SELECT sp2.site_part2site
                                                FROM table_site_part sp2
                                               WHERE sp2.objid =
                                                             l_site_part_objid)
                                      AND sp.x_service_id = p_esn)
                           AND 0 = get_restricted_use (p_esn)
                           -- 10/06/02 amigo will not qualify
                           AND x_promo_code = 'RTANNUAL02'
                           AND x_promo_type = 'Runtime';
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;

                     IF l_ann2_promo_info.promo_code IS NOT NULL
                     THEN
                        INSERT INTO table_x_pending_redemption
                                    (objid,
                                     pend_red2x_promotion,
                                     x_pend_red2site_part, x_pend_type
                                     --, x_granted_from2x_call_trans                                   --CR5854
                                     , redeem_in2call_trans                                   --CR5150  change the field name from CR5854
                                    )
                             VALUES (
                                     -- 04/10/03 seq_x_pending_redemption.nextval + POWER (2, 28),
                                     seq ('x_pending_redemption'),
                                     l_ann2_promo_info.promo_objid,
                                     l_site_part_objid, 'Runtime'
                                     , p_objid                                                      --CR5854
                                    );

                        l_units_total :=
                              l_units_total + NVL (l_ann2_promo_info.units, 0);
                        l_max_access_days :=
                             l_max_access_days + l_ann2_promo_info.access_days;
                        l_promo_code := l_ann2_promo_info.promo_code;
                        l_rt_promo_ct := l_rt_promo_ct + 1;           --062601
                        p_msg := l_ann2_promo_info.MESSAGE;
--062601
                        l_ctr := l_ctr + 1;                         --CR5221-1
                        crea_promo_arr (l_promo_code,
                                        l_ann2_promo_info.units,
                                        l_ctr,
                                        l_ann2_promo_info.promo_objid,
                                        'Runtime',
                                        l_chk
                                       );                           --CR5221-1
                     END IF;
                  END IF;
               --
               --END of 062601
               END IF;
            END LOOP;
-- g_ann_card_tab.count -1
         END IF;

         --
         -- Process Non-Annual card if any
         --
         IF NVL (l_esn_in_ann_plan, FALSE) <> TRUE
         THEN
            l_esn_in_ann_plan := is_annual_plan (p_esn);
         END IF;

         IF (    (NVL (l_esn_in_ann_plan, FALSE) = TRUE)
             AND (g_non_ann_card_tab.COUNT > 0)
            )
         THEN
            FOR i IN 0 .. g_non_ann_card_tab.COUNT - 1
            LOOP
               IF (    g_non_ann_card_tab (i).units > 10
                   AND l_esn_in_ann_plan = TRUE
                  )
               THEN
                  --
                  -- Only red cards (unit>10 and in annula plan group)
                  -- are qualified for the additional free units
                  -- of annual plan
                  --
                  BEGIN
                     INSERT INTO table_x_pending_redemption
                                 (objid,
                                  pend_red2x_promotion,
                                  x_pend_red2site_part, x_pend_type
                                  --, x_granted_from2x_call_trans                                   --CR5854
                                  , redeem_in2call_trans                                   --CR5150  change the field name from CR5854
                                 )
                          VALUES (
                                  -- 04/10/03 seq_x_pending_redemption.nextval + POWER (2, 28),
                                  seq ('x_pending_redemption'),
                                  l_ann_promo_info.promo_objid,
                                  l_site_part_objid, 'Runtime'
                                  , p_objid                                                      --CR5854
                                 );

                     l_units_total :=
                               l_units_total + NVL (l_ann_promo_info.units, 0);
                     -- sl 050301 Stack Day
                     --IF l_ann_promo_info.access_days > l_max_access_days THEN
                     --   l_max_access_days := l_ann_promo_info.access_days;
                     --END IF;
                     l_promo_code := l_ann_promo_info.promo_code;  -- 05/17/01
                     l_max_access_days :=
                              l_max_access_days + l_ann_promo_info.access_days;
                     -- end sl 050301
                     l_rt_promo_ct := l_rt_promo_ct + 1;              --062601
                     p_msg := l_ann_promo_info.MESSAGE;               --062601
                     l_ctr := l_ctr + 1;                            --CR5221-1
                     crea_promo_arr (l_promo_code,
                                     l_ann_promo_info.units,
                                     l_ctr,
                                     l_ann_promo_info.promo_objid,
                                     'Runtime',
                                     l_chk
                                    );                              --CR5221-1
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_status := 'F';
                        p_msg :=
                              'Fail to insert into table_x_pending_redemption.'
                           || 'Red code='
                           || g_non_ann_card_tab (i).red_code
                           || ' Site part objid='
                           || l_site_part_objid
                           || ' Promo objid='
                           || l_ann_promo_info.promo_objid
                           || SUBSTR (SQLERRM, 100);
                        RETURN;
                  END;
               END IF;
            END LOOP;
--end of non-annual card loop
         END IF;
      END IF;                               /* l_process_annual_plan = true */

      --
      --      ********* End of annual plan process *********
      --
      --
      --      ********* Start to process Non-Annual-Plan Promotion
      --
      l_i := 0;

--       --test
--       DBMS_OUTPUT.put_line ('before main loop:');
--
--       FOR c_test_rec IN c_test
--       LOOP
--          DBMS_OUTPUT.put_line ('part objid: ' || c_test_rec.groupesn2part_inst
--                               );
--          DBMS_OUTPUT.put_line (   'promo group objid: '
--                                || c_test_rec.groupesn2x_promo_group
--                               );
--       END LOOP;
--
--       DBMS_OUTPUT.put_line ('before main loop end:');

      --test
      -- Main Loop to check all runtime promotion for this esn
      -- 08/16/02
      -- FOR c_rt_promo_rec IN c_rt_promo(l_site_part_objid) LOOP
      --CR17076 Start kacosta 10/26/2011
      --FOR c_rt_promo_rec IN c_rt_promo (get_restricted_use(p_esn)) --CR6182 Added the in parameter
      FOR c_rt_promo_rec IN c_rt_promo(bau_util_pkg.get_esn_brand_objid(p_esn))
      --CR17076 End kacosta 10/26/2011
      LOOP
         --04/03/03
         DBMS_OUTPUT.put_line ('promotion: ' || c_rt_promo_rec.x_promo_code);
--          DBMS_OUTPUT.put_line ('count: ' || (l_loop_times - 1));
         l_sql_text := c_rt_promo_rec.x_sql_statement;

         --    FOR i in 0..9 LOOP   -- 08/16/02
        FOR i IN 0 .. (l_loop_times - 1)                          --09/30/02
        LOOP
          if g_red_card_tab(i).is_free_corp=0 then --CR6209
            l_cursorid := DBMS_SQL.open_cursor;
            l_step := NULL;
            l_is_plsql := 'N';
            l_pm_status := NULL;
            l_pm_msg := NULL;
            l_j := 0;

            BEGIN
               l_step := 'parse sql';
               DBMS_SQL.parse (l_cursorid, l_sql_text, DBMS_SQL.v7);
               --01/26/01 by SL
               l_bind_var := ' :esn ';
               l_step := 'Binding l_bind_var ' || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          p_esn
                                         );
               END IF;

               -- 12/08/00
               --08/16/02 FOR i in 0..9 LOOP
               -- 01/26/01 by SL
               -- REPLACE:
               -- dbms_sql.bind_variable(l_cursorid,':red_units'||ltrim(to_char(i,'09')),
               --     NVL(g_red_card_tab(i).units,0) );
               --08/16/02
               -- l_bind_var := ' :red_units'||ltrim(to_char(i,'09'))||' ';
               l_bind_var := ' :units ';
               l_step := 'Binding l_bind_var ' || l_bind_var;

               -- END 08/16/02
               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  -- sl 050301 Stack Day
                  -- if the card is paid red card, its units will be used
                  -- against runtime promotion check otherwise 0 units will
                  -- be used.
                  -- CR7572 YM
                  --IF NVL (g_red_card_tab (i).part_type, 'FREE') = 'PAID'
                  IF NVL (g_red_card_tab (i).part_type, 'FREE') in ('PAID','LLPAID')
                  THEN
                     -- 03/05/02
                     --
                     --04/02/03
                     /* (    g_red_card_tab (i).access_days = 365
                       AND ((g_red_card_tab (i).annual_status <> 'ANNUAL')
                            OR (g_red_card_tab (i).annual_status IS NULL)))
                     THEN
                        DBMS_SQL.bind_variable (
                           l_cursorid,
                           RTRIM (LTRIM (l_bind_var)),
                           365
                        );
                        DBMS_OUTPUT.PUT_LINE('using units: '||365);
                     ELSE */
                     DBMS_SQL.bind_variable (l_cursorid,
                                             RTRIM (LTRIM (l_bind_var)),
                                             NVL (g_red_card_tab (i).units, 0)
                                            );
--                      DBMS_OUTPUT.put_line (   'using units: '
--                                            || NVL (g_red_card_tab (i).units,
--                                                    0)
--                                           );
                  -- 04/02/03 END IF;
                  ELSE
                     DBMS_SQL.bind_variable (l_cursorid,
                                             RTRIM (LTRIM (l_bind_var)),
                                             0
                                            );
                     DBMS_OUTPUT.put_line ('using units: ' || 0);
                  END IF;
               --
               -- END sl 050301
               END IF;

               -- GP 04/02/2003
               l_bind_var := ' :part_num ';
               l_step :=
                     c_rt_promo_rec.x_promo_code
                  || 'Binding l_bind_var '
                  || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          g_red_card_tab (i).part_num
                                         );
--                   DBMS_OUTPUT.put_line (   'part num binded '
--                                         || g_red_card_tab (i).part_num
--                                        );
               END IF;

               -- GP 04/02/2003
               l_bind_var := ' :access_days ';
               l_step :=
                     c_rt_promo_rec.x_promo_code
                  || 'Binding l_bind_var '
                  || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          g_red_card_tab (i).access_days
                                         );
--                   DBMS_OUTPUT.put_line (   'access days binded '
--                                         || g_red_card_tab (i).access_days
--                                        );
               END IF;

               l_bind_var := ' :card_type ';
               l_step :=
                     c_rt_promo_rec.x_promo_code
                  || 'Binding l_bind_var '
                  || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable
                                       (l_cursorid,
                                        RTRIM (LTRIM (l_bind_var)),
                                        NVL (g_red_card_tab (i).annual_status,
                                             'N'
                                            )
                                       );
--                   DBMS_OUTPUT.put_line (   'part num binded '
--                                         || g_red_card_tab (i).part_num
--                                        );
               END IF;

               -- END GP 04/02/2003
               -- GP 04/02/2003
               l_bind_var := ' :pin_promocode ';
               l_step :=
                     c_rt_promo_rec.x_promo_code
                  || 'Binding l_bind_var '
                  || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          g_red_card_tab (i).x_promo_code
                                         );
--                   DBMS_OUTPUT.put_line (   'promo_code binded '
--                                         || g_red_card_tab (i).x_promo_code
--                                        );
               END IF;

               -- END GP 04/02/2003
               -- GP 04/02/2003
               l_bind_var := ' :pm_status ';
               l_step := 'Binding l_bind_var ' || l_bind_var;

--                DBMS_OUTPUT.put_line (   l_step
--                                      || ' '
--                                      || NVL (INSTR (l_sql_text, l_bind_var),
--                                              0)
--                                     );
               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_pm_status,
                                          30
                                         );
                  l_is_plsql := 'Y';
               END IF;

               -- END GP 04/02/2003
               -- GP 04/02/2003
               l_bind_var := ' :pm_msg ';
               l_step := 'Binding l_bind_var ' || l_bind_var;

--                DBMS_OUTPUT.put_line (   l_step
--                                      || ' '
--                                      || NVL (INSTR (l_sql_text, l_bind_var),
--                                              0)
--                                     );
               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          l_pm_msg,
                                          2000
                                         );
                  l_is_plsql := 'Y';
               END IF;

               -- END GP 04/02/2003
               --CR3181 Changes
               l_bind_var := ' :source ';
               l_step := 'Binding l_bind_var ' || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          p_source_system
                                         );
               END IF;

               --End CR3181 Changes

               --CR17076 Start kacosta 09/09/2011
               l_bind_var := ' :call_trans_objid ';
               l_step := 'Binding l_bind_var ' || l_bind_var;

               IF NVL (INSTR (l_sql_text, l_bind_var), 0) > 0
               THEN
                  DBMS_SQL.bind_variable (l_cursorid,
                                          RTRIM (LTRIM (l_bind_var)),
                                          p_objid
                                         );
               END IF;
               --CR17076 End kacosta 09/09/2011

--                DBMS_OUTPUT.put_line ('is_plsql: ' || l_is_plsql);

               --l_is_plsql := 'Y';
               IF l_is_plsql = 'N'
               THEN
                  l_step := 'Define Column step ' || l_chars;
                  DBMS_SQL.define_column (l_cursorid, 1, l_chars, 10);
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  IF DBMS_SQL.is_open (l_cursorid)
                  THEN
                     DBMS_SQL.close_cursor (l_cursorid);
                  END IF;

                  p_units_out := p_units;
                  p_access_days_out := p_access_days;
                  p_status := 'F';
                  p_msg :=
                        c_rt_promo_rec.x_promo_code
                     || '. Fail to build dynamic SQL: '
                     || SUBSTR (SQLERRM, 1, 100)
                     || ' '
                     || l_step
                     || ' pos='
                     || DBMS_SQL.last_error_position;
                  RETURN;
            END;

--             BEGIN
--                --test
--                DBMS_OUTPUT.put_line ('before exec:');
--
--                FOR c_test_rec IN c_test
--                LOOP
--                   DBMS_OUTPUT.put_line (   'part objid: '
--                                         || c_test_rec.groupesn2part_inst
--                                        );
--                   DBMS_OUTPUT.put_line (   'promo group objid: '
--                                         || c_test_rec.groupesn2x_promo_group
--                                        );
--                END LOOP;
--
--                DBMS_OUTPUT.put_line ('before exec end:');
--                l_rc := DBMS_SQL.EXECUTE (l_cursorid);
--                --test
--                DBMS_OUTPUT.put_line ('after exec:');
--
--                FOR c_test_rec IN c_test
--                LOOP
--                   DBMS_OUTPUT.put_line (   'part objid: '
--                                         || c_test_rec.groupesn2part_inst
--                                        );
--                   DBMS_OUTPUT.put_line (   'promo group objid: '
--                                         || c_test_rec.groupesn2x_promo_group
--                                        );
--                END LOOP;
--
--                DBMS_OUTPUT.put_line ('after exec end:');
--             EXCEPTION
--                WHEN OTHERS
--                THEN
--                   IF DBMS_SQL.is_open (l_cursorid)
--                   THEN
--                      DBMS_SQL.close_cursor (l_cursorid);
--                   END IF;
--
--                   p_units_out := p_units;
--                   p_access_days_out := p_access_days;
--                   p_status := 'F';
--                   p_msg :=
--                         c_rt_promo_rec.x_promo_code
--                      || '. Fail to execute dynamic SQL: '
--                      || SUBSTR (SQLERRM, 1, 100)
--                      || ' '
--                      || l_step;
--                   RETURN;p_units_out

            --             END;
            l_j := 0;
            l_rc := DBMS_SQL.EXECUTE (l_cursorid);
            l_j := 0;

            IF l_is_plsql = 'N'
            THEN
               LOOP
                  IF (DBMS_SQL.fetch_rows (l_cursorid) = 0 OR l_j > 0)
                  THEN
                     EXIT;
                  END IF;

                  DBMS_SQL.column_value (l_cursorid, 1, l_chars);
                  l_j := l_j + 1;
--                   DBMS_OUTPUT.put_line ('Qualified');
               END LOOP;
            ELSE
               BEGIN
--04/02/03
                  DBMS_SQL.variable_value (l_cursorid,
                                           ':pm_status',
                                           l_pm_status
                                          );
--                   DBMS_OUTPUT.put_line ('l_pm_status: ' || l_pm_status);
                  DBMS_SQL.variable_value (l_cursorid, ':pm_msg', l_pm_msg);
--                   DBMS_OUTPUT.put_line ('l_pm_msg: ' || l_pm_msg);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_status := 'F';
                     p_msg :=
                           c_rt_promo_rec.x_promo_code
                        || ' Fail to do variable variable: pos='
                        || DBMS_SQL.last_error_position
                        || ' '
                        || SUBSTR (SQLERRM, 1, 100);
                     RETURN;
               END;

               IF l_pm_status = '0'
               THEN
--                   DBMS_OUTPUT.put_line ('Qualified');
                  l_j := l_j + 1;
               END IF;
            END IF;

            DBMS_SQL.close_cursor (l_cursorid);

            IF    (l_is_plsql = 'N' AND l_j > 0)
               OR (l_is_plsql = 'Y' AND l_pm_status = '0')
            THEN
               --
               -- Qualified for the runtime promotion
               --
               BEGIN
                  INSERT INTO table_x_pending_redemption
                              (objid,
                               pend_red2x_promotion, x_pend_red2site_part,
                               x_pend_type
                               --, x_granted_from2x_call_trans                                   --CR5854
                               , redeem_in2call_trans                                   --CR5150  change the field name from CR5854
                              )
                       VALUES (
                               -- 04/10/03 seq_x_pending_redemption.nextval + POWER (2, 28),
                               seq ('x_pending_redemption'),
                               c_rt_promo_rec.objid, l_site_part_objid,
                               'Runtime'
                               , p_objid                                                      --CR5854
                              );

                  l_promo_code := c_rt_promo_rec.x_promo_code;     -- 05/17/01
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_status := 'F';
                     p_msg :=
                           'Fail to insert a record into table_x_pending_redemption: '
                        || SUBSTR (SQLERRM, 1, 100);
                     RETURN;
               END;

               l_units_total := l_units_total + c_rt_promo_rec.x_units;
               l_rt_promo_ct := l_rt_promo_ct + 1;                    --062601
               p_msg := c_rt_promo_rec.x_promotion_text;              --062601
               --sl 050301 Stack Day
               --IF c_rt_promo_rec.x_access_days > l_max_access_days THEN
               --   l_max_access_days := c_rt_promo_rec.x_access_days;
               --END IF;
               l_max_access_days :=
                              l_max_access_days + c_rt_promo_rec.x_access_days;
               --end sl 050301
               l_i := l_i + 1;
               l_ctr := l_ctr + 1;                                  --CR5221-1
               crea_promo_arr (l_promo_code,
                               c_rt_promo_rec.x_units,
                               l_ctr,
                               c_rt_promo_rec.objid,
                               'Runtime',
                               l_chk
                              );
            END IF;
         --CR5221-1
          end if; --CR6209
        END LOOP;
-- 08/16/02
      END LOOP;                                            -- End of main loop

      DBMS_OUTPUT.put_line ('finish promos');
      p_promo_ct := l_rt_promo_ct;

      IF l_rt_promo_ct = 0
      THEN
         -- No redemption card qulified for annual-plan promotion
         -- and No runtime promotion found for this esn
         p_status := 'N';
--CR3735 Starts
--          p_msg := l_rt_promo_ct || '#' || 'Esn ' || p_esn ||
--          ' is not qualified for run time promotion';
         p_msg :=
               'Esn ' || p_esn || ' is not qualified for run time promotion.';
--CR3735 Ends
         p_promo_out_code := '0';
--05/17/01 by sl
      ELSE
         --
         -- This esn qulified at least one runtime promotion
         -- Or one annual plan promotion
         --
         p_units_out := p_units + l_units_total;

         --sl 050301 Stack Day
         --If access days parsed into this store procedure is greater than 90 days
         -- then use that access day
         --
         -- p_access_days_out := l_max_access_days;
         --11/20/01 add logic for renewal
         --Start Remove Stack Check
         --CR17076 Start kacosta 11/08/2011
         --IF l_renewal
         --THEN
         --   p_access_days_out := l_max_access_days;
         --ELSE
         --   IF p_access_days > 90
         --   THEN
         --      p_access_days_out := p_access_days;
         --   ELSE
         --      p_access_days_out := l_max_access_days;
         --   END IF;
         --END IF;
         -- Removed the IF p_access_days > 90 check
         p_access_days_out := l_max_access_days;
         --CR17076 End kacosta 11/08/2011

         /*
         --sl 050301 Stack Day
         --If access days parsed into this store procedure is greater than 90 days
         -- then use that access day
         --
         -- p_access_days_out := l_max_access_days;
         --11/20/01 add logic for renewal
         IF l_renewal
         THEN
            p_access_days_out := l_max_access_days;
         ELSE
            IF p_access_days > 90
            THEN
               p_access_days_out := p_access_days;
            ELSE
               IF l_max_access_days > 90
               THEN
                  p_access_days_out := 90;
               ELSE
                  p_access_days_out := l_max_access_days;
               END IF;
            END IF;
         --end sl 050301
         END IF;

         */
         --End Remove Stack Check
         --end  11/20/01
         --
         -- 08/16/02
         --
         p_units_out := p_units_out + l_in_promo_units;

         --Start Remove Stack Check
         IF l_in_promo_days > 0
         THEN
            p_access_days_out := p_access_days_out + l_in_promo_days;
         END IF;

         /*         IF l_in_promo_days > 0
         THEN
            IF    l_in_promo_days = 365
               OR p_access_days_out >= 365
            THEN
               p_access_days_out :=
                  LEAST (p_access_days_out + l_in_promo_days, 365 + 90);
            ELSE
         --VAdapa 08/22/03
         --                p_access_days_out :=
         --                   GREATEST (p_access_days_out, l_in_promo_days);
               l_promo_pin_days := p_access_days_out + l_in_promo_days;


               IF l_promo_pin_days > 90
               THEN
                  p_access_days_out := 90;
               ELSE
                  p_access_days_out := l_promo_pin_days;
               END IF;
            END IF;
         END IF;
         */
         --End Remove Stack Check
         -- end of 08/16/02
         p_status := 'S';
         l_g_msg :=
               'Your most recent airtime redemption has qualified you for multiple '
            || 'TracFone promotions. '
            || (p_units_out - p_units)
            || ' free units have been added to your phone.';

         IF l_rt_promo_ct > 1
         THEN
                --CR5221-1 start
            --CR5221-1 Start
            IF l_chk > 0
            THEN              --only if the esn is qualified for RTLONG promo
               l_highest_units := 0;

               FOR i IN g_promo_tab.FIRST .. g_promo_tab.LAST
               LOOP
                  IF l_highest_units < g_promo_tab (i).x_units
                  THEN
                     l_highest_units := g_promo_tab (i).x_units;
                     l_objid := g_promo_tab (i).p_objid;
                     l_promo_type := g_promo_tab (i).p_type;
                  END IF;

                  IF g_promo_tab (i).x_promo_code LIKE 'RTLONG%'
                  THEN
                     l_long_units := l_long_units + g_promo_tab (i).x_units;
                  END IF;

                  DBMS_OUTPUT.put_line (   g_promo_tab (i).x_promo_code
                                        || '    '
                                        || g_promo_tab (i).x_units
                                       );
               END LOOP;

               DBMS_OUTPUT.put_line ('l_long_units ' || l_long_units);

               IF l_highest_units > 0
               THEN
                  DELETE FROM table_x_pending_redemption
                        WHERE x_pend_red2site_part = l_site_part_objid
                          --AND x_granted_from2x_call_trans = p_objid          --CR5854       call transaction id
                          AND redeem_in2call_trans  = p_objid                  --CR5150  change the field name from CR5854
                          AND pend_red2x_promotion <>
                                          (SELECT objid
                                             FROM table_x_promotion
                                            WHERE x_promo_code LIKE 'RTLONG%');

                  INSERT INTO table_x_pending_redemption
                              (objid, pend_red2x_promotion,
                               x_pend_red2site_part, x_pend_type
                               --, x_granted_from2x_call_trans                --CR5854       call transaction id
                               , redeem_in2call_trans                  --CR5150  change the field name from CR5854
                              )
                       VALUES (
                               -- 04/10/03 seq_x_pending_redemption.nextval + POWER (2, 28),
                               seq ('x_pending_redemption'), l_objid,
                               l_site_part_objid, l_promo_type
                               , p_objid                                    --CR5854       call transaction id
                              );

                  p_units_out := p_units + l_highest_units + l_long_units;
               END IF;

               DBMS_OUTPUT.put_line ('p_units_out ' || p_units_out);
               p_status := 'S';
               l_g_msg :=
                     'Your most recent airtime redemption has qualified you for multiple '
                  || 'TracFone promotions. '
                  || (p_units_out - p_units)
                  || ' free units have been added to your phone.';
            END IF;

            --CR5221-1 End
             --CR5221 End
            p_msg := l_g_msg;
            p_promo_out_code := '99';
         ELSE
            p_msg := p_msg;
            p_promo_out_code := l_promo_code;
         END IF;
      END IF;

      p_msg := SUBSTR (p_msg, 1, 250);                             -- 12/12/00
     --
     -- CR16379 Start kacosta 03/09/2012
     DECLARE
       --
       l_i_error_code    INTEGER := 0;
       l_v_error_message VARCHAR2(32767) := 'SUCCESS';
       --
     BEGIN
       --
       promotion_pkg.expire_double_if_esn_is_triple(p_esn           => p_esn
                                                   ,p_error_code    => l_i_error_code
                                                   ,p_error_message => l_v_error_message);
       --
       IF (l_i_error_code <> 0) THEN
         --
         dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with error: ' || l_v_error_message);
         --
       END IF;
       --
     EXCEPTION
       WHEN others THEN
         --
         dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with Oracle error: ' || SQLCODE);
         --
     END;
     -- CR16379 End kacosta 03/09/2012
     --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_status := 'F';
         p_msg := '<Unexpected Error> ' || SUBSTR (SQLERRM, 1, 100);
   END doruntimepromo;

   /******************************************
   * Function get_esn_objid
   * IN: varchar2
   * OUT: number  -- objid
   *******************************************/
   FUNCTION get_esn_objid (p_esn VARCHAR2)
      RETURN NUMBER
   IS
      --CR5067 start
      CURSOR c1
      IS
         SELECT   objid
             FROM table_site_part
            WHERE part_status != 'Active' AND x_service_id = p_esn
         ORDER BY install_date DESC;

      r1            c1%ROWTYPE;
      --CR5067 end
      v_esn_objid   NUMBER;
   BEGIN
      -- 050301 bug fix
      -- change the way of getting most recent esn objid
      BEGIN
         SELECT objid
           INTO v_esn_objid
           FROM table_site_part
          WHERE part_status = 'Active' AND x_service_id = p_esn;

         RETURN v_esn_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
--CR5067 start
               OPEN c1;

               FETCH c1
                INTO r1;

               IF c1%FOUND
               THEN
                  v_esn_objid := r1.objid;
                  RETURN v_esn_objid;
               ELSE
                  RETURN NULL;
               END IF;

               CLOSE c1;
--
--                SELECT MAX (objid)
--                  INTO v_esn_objid
--                  FROM table_site_part
--                 WHERE part_status != 'Active' AND x_service_id = p_esn;

            -- RETURN v_esn_objid;
--CR5067 end
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN NULL;
            END;
         WHEN OTHERS
         THEN
            RETURN NULL;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_esn_objid;

   /******************************************
   * Function get_esn_part_inst_objid
   * IN: varchar2
   * OUT: number  -- objid
   *******************************************/
   FUNCTION get_esn_part_inst_objid (p_esn VARCHAR2)
      RETURN NUMBER
   IS
      v_esn_pi_objid   NUMBER;
   BEGIN
      SELECT objid
        INTO v_esn_pi_objid
        FROM table_part_inst
       WHERE x_domain = 'PHONES' AND part_serial_no = p_esn;

      RETURN v_esn_pi_objid;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_esn_part_inst_objid;

   /******************************************
   * Function is_annual_plan
   * IN: esn (varchar2)
   * RETURN: Boolean
   *******************************************/
   FUNCTION is_annual_plan (p_esn VARCHAR2)
      RETURN BOOLEAN
   IS
      v_ann_promogrp_objid   NUMBER;
      v_esn_objid            NUMBER;
      v_dummy                VARCHAR2 (1);
   BEGIN
      v_ann_promogrp_objid := get_promogrp_objid ('ANNUALPLAN');   --08/16/02
      v_esn_objid := get_esn_part_inst_objid (p_esn);

      IF ((v_ann_promogrp_objid IS NULL) OR (v_esn_objid IS NULL))
      THEN
         RETURN FALSE;
      END IF;

      -- 11/20/01 get whole record
      --SELECT 'x'
      --INTO v_dummy
      SELECT *
        INTO g_group2esn
        FROM table_x_group2esn
       WHERE groupesn2x_promo_group = v_ann_promogrp_objid
         AND groupesn2part_inst = v_esn_objid
         AND ROWNUM < 2;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_annual_plan;

   /******************************************
   * Procedure get_red_card_info
   * IN:  redemption card record
   * OUT:
   *******************************************/
   PROCEDURE get_red_card_info (p_card_rec IN OUT red_card_rec_t)
   IS
      v_card_rec   red_card_rec_t;
   BEGIN
      v_card_rec := p_card_rec;

      -- 050301
      -- add retrieveing part_type
      SELECT pi.x_red_code,
             pn.x_redeem_units,
             pn.x_redeem_days,
             pn.part_number,
             pn.x_card_type,
             pn.part_type,
             pr.x_promo_code,
             --next column added for CR6209 on 6/14/07
             (select count(1)
                 from table_inv_bin ib, table_site ts
                 where ts.site_id=ib.bin_name
                 and ib.objid=pi.part_inst2inv_bin
                 and ts.name like 'CORP FREE%')
        INTO p_card_rec
        FROM table_part_inst pi,
             table_mod_level ml,
             table_part_num pn,
             table_x_promotion pr
       WHERE pi.x_red_code = p_card_rec.red_code
         AND pi.n_part_inst2part_mod = ml.objid
         AND pi.x_domain = 'REDEMPTION CARDS'
         AND ml.part_info2part_num = pn.objid
         AND pn.domain = 'REDEMPTION CARDS'
         AND pn.part_num2x_promotion = pr.objid(+);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_card_rec := v_card_rec;
   END;

   /******************************************
   * Procedure get_ann_promo_info
   * IN AND OUT:  promo info record promo_rec
   *******************************************/
   FUNCTION get_ann_promo_info
      RETURN promo_rec_t
   IS
      v_promo_rec   promo_rec_t;
   BEGIN
      SELECT objid,
             x_units,
             x_access_days,
             x_promotion_text,
             x_promo_code,
             x_usage                                                --05/17/01
        INTO v_promo_rec
        FROM table_x_promotion
       WHERE (SYSDATE BETWEEN x_start_date AND x_end_date
              OR x_end_date IS NULL
             )
         AND x_promo_code = 'RTANNUAL'
         AND x_promo_type = 'Runtime';

      RETURN v_promo_rec;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN v_promo_rec;
   END get_ann_promo_info;

   /******************************************
   * Function get_ann_promogrp_objid
   * Description: get annual promotion group objid
   * IN: None
   * RETURN: Number
   *******************************************/
   --08/16/02 FUNCTION get_ann_promogrp_objid RETURN Number
   FUNCTION get_promogrp_objid (p_group_name VARCHAR2)
      RETURN NUMBER
   IS
      v_promogrp_objid   NUMBER;
   BEGIN
      SELECT objid
        INTO v_promogrp_objid
        FROM table_x_promotion_group
       WHERE (SYSDATE BETWEEN x_start_date AND x_end_date
              OR x_end_date IS NULL
             )
         AND group_name = p_group_name                          --'ANNUALPLAN'
                                      ;

      RETURN v_promogrp_objid;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_promogrp_objid;

   /*************************************
   * Funtion is_digital_phone
   *         find out if esn is digital
   * return true if the phone is digital
   *        false if the phone is analog
   **************************************/
   --062601
   FUNCTION is_digital_phone (p_esn VARCHAR2)
      RETURN BOOLEAN
   IS
      v_dummy   VARCHAR2 (10);
   BEGIN
      SELECT 'x'
        INTO v_dummy
        FROM table_part_num pn, table_mod_level ml, table_part_inst pi
       WHERE pn.domain = 'PHONES'
         AND pn.x_technology IN ('TDMA', 'CDMA')
         AND pn.objid = ml.part_info2part_num
         AND pi.n_part_inst2part_mod = ml.objid
         AND pi.x_domain = 'PHONES'
         AND pi.part_serial_no = p_esn;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_digital_phone;

--*********************************************************
-- DEBUG PROCEDURE
--*********************************************************
   PROCEDURE debug01
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('ANNUAL CARD....' || g_ann_card_tab.COUNT);

      FOR i IN 0 .. g_ann_card_tab.COUNT - 1
      LOOP
         DBMS_OUTPUT.put_line ('red code: ' || g_ann_card_tab (i).red_code);
         DBMS_OUTPUT.put_line ('units: ' || g_ann_card_tab (i).units);
         DBMS_OUTPUT.put_line ('access_day: '
                               || g_ann_card_tab (i).access_days
                              );
         DBMS_OUTPUT.put_line ('part_num: ' || g_ann_card_tab (i).part_num);
         DBMS_OUTPUT.put_line (   'annual_status: '
                               || g_ann_card_tab (i).annual_status
                               || CHR (10)
                              );
      END LOOP;

      DBMS_OUTPUT.put_line ('NON ANNUAL CARD....' || g_non_ann_card_tab.COUNT);

      FOR i IN 0 .. g_non_ann_card_tab.COUNT - 1
      LOOP
         DBMS_OUTPUT.put_line ('red code: ' || g_non_ann_card_tab (i).red_code
                              );
         DBMS_OUTPUT.put_line ('units: ' || g_non_ann_card_tab (i).units);
         DBMS_OUTPUT.put_line (   'access_day: '
                               || g_non_ann_card_tab (i).access_days
                              );
         DBMS_OUTPUT.put_line ('part_num: ' || g_non_ann_card_tab (i).part_num);
         DBMS_OUTPUT.put_line (   'annual_status: '
                               || g_non_ann_card_tab (i).annual_status
                               || CHR (10)
                              );
      END LOOP;
   END debug01;

   /******************************************
   --10/18/02 Changes
   * Procedure get_esn_info
   * IN: varchar2
   * OUT: date,varchar2 -- ship date and status
   *******************************************/
   PROCEDURE get_esn_info (
      p_esn           IN       VARCHAR2,
      esn_ship_date   OUT      DATE,
      esn_status      OUT      VARCHAR2
   )
   IS
   BEGIN
      SELECT x_creation_date, x_part_inst_status
        INTO esn_ship_date, esn_status
        FROM table_part_inst
       WHERE x_domain = 'PHONES' AND part_serial_no = p_esn;
   EXCEPTION
      WHEN OTHERS
      THEN
         esn_ship_date := NULL;
         esn_status := NULL;
   END get_esn_info;

-- End 10/18/02 Changes

   /*******************************************/
--CR5221-1 Start
   PROCEDURE crea_promo_arr (
      p_promo_code         VARCHAR2,
      p_units              NUMBER,
      p_counter            NUMBER,
      p_objid              NUMBER,
      p_type               VARCHAR2,
      p_is_check     OUT   NUMBER
   )
   IS
   BEGIN
      g_promo_tab (p_counter).x_promo_code := p_promo_code;
      g_promo_tab (p_counter).x_units := p_units;
      g_promo_tab (p_counter).p_objid := p_objid;
      g_promo_tab (p_counter).p_type := p_type;

      IF g_promo_tab (p_counter).x_promo_code LIKE 'RTLONG%'
      THEN
         p_is_check := NVL (p_is_check, 0) + 1;
      END IF;
   END crea_promo_arr;
--CR5221-1 Start
END;
/
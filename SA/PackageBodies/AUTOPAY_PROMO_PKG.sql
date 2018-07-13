CREATE OR REPLACE PACKAGE BODY sa."AUTOPAY_PROMO_PKG"
IS
/***************************************************************
   --
   -- History:
   -- Date        Who       Description
   -- ---------- ------------- ------------------------------------
   06/17/2002 TCS           Initial version
   -- 10/04/2002 SL            Add esn binding
   -- 03/26/2003 Suganthi      Promotion for only PAID cards - CR 1138
   -- 04/03/2003 Suganthi      Double miutes for 100 units and partnumber APP100 --CR1409
   -- 04/10/2003 SL            Clarify Upgrade-sequence
   -- 07/07/04   VA            CR2739 - Specified columns in "INSERT INTO TABLE_X_PENDING_REDEMPTION" statement
   -- 01/07/05   VA            CR3190 - Removed the word "Tracfone" in the display message
   -- 06/01/05   VA            CR3735 - WEBCSR Changes (Removed the display of count if ESN not qualified)
   --                          (PVCS Revision 1.6)
   -- 06/08/05   VA            Fix for CR3735 (PVCS Revision 1.7)
   -- **************************************************************/
   g_esn VARCHAR2 (30); --10/04/02
   g_part_number VARCHAR2 (30); --CR1409
   PROCEDURE main(
      p_esn VARCHAR2,
      p_units NUMBER,
      p_units_in NUMBER,
      p_promo_ct NUMBER,
      p_msg_in VARCHAR2,
      p_promo_code_in VARCHAR2,
      p_site_part_objid NUMBER,
      p_red_code01 VARCHAR2,
      p_red_code02 VARCHAR2
      DEFAULT NULL,
      p_red_code03 VARCHAR2
      DEFAULT NULL,
      p_red_code04 VARCHAR2
      DEFAULT NULL,
      p_red_code05 VARCHAR2
      DEFAULT NULL,
      p_red_code06 VARCHAR2
      DEFAULT NULL,
      p_red_code07 VARCHAR2
      DEFAULT NULL,
      p_red_code08 VARCHAR2
      DEFAULT NULL,
      p_red_code09 VARCHAR2
      DEFAULT NULL,
      p_red_code10 VARCHAR2
      DEFAULT NULL,
      p_units_out OUT NUMBER,
      p_status OUT VARCHAR2,
      p_msg OUT VARCHAR2,
      p_promo_code OUT VARCHAR2
   )
   IS
   BEGIN
      doautopaypromo_prc ( p_esn, p_units, p_units_in, p_promo_ct, p_msg_in,
      p_promo_code_in, p_site_part_objid, p_red_code01, p_red_code02,
      p_red_code03, p_red_code04, p_red_code05, p_red_code06, p_red_code07,
      p_red_code08, p_red_code09, p_red_code10, p_units_out, p_status, p_msg,
      p_promo_code );
      IF ( p_status = 'S'
      OR p_status = 'N')
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END;
   /*************************************************************************
   * Procedure  : DoAutopayPromo_prc
   * Description: Check if the ESN is registered for Autopay/Hybrid plan  and
   *              if qualified ,insert a row in the x_pending_redemption.
   *
   * Basic Program Logic:
   *   1. Redeeming the cards.
   *      1.1 Redeem cards with Autopay Plan
   *
   *      1.2 Redeem cards with Hybrid plans
   *
   **************************************************************************/
   PROCEDURE doautopaypromo_prc(
      p_esn VARCHAR2,
      p_units NUMBER,
      p_units_in NUMBER,
      p_promo_ct NUMBER,
      p_msg_in VARCHAR2,
      p_promo_code_in VARCHAR2,
      p_site_part_objid NUMBER,
      p_red_code01 VARCHAR2,
      p_red_code02 VARCHAR2
      DEFAULT NULL,
      p_red_code03 VARCHAR2
      DEFAULT NULL,
      p_red_code04 VARCHAR2
      DEFAULT NULL,
      p_red_code05 VARCHAR2
      DEFAULT NULL,
      p_red_code06 VARCHAR2
      DEFAULT NULL,
      p_red_code07 VARCHAR2
      DEFAULT NULL,
      p_red_code08 VARCHAR2
      DEFAULT NULL,
      p_red_code09 VARCHAR2
      DEFAULT NULL,
      p_red_code10 VARCHAR2
      DEFAULT NULL,
      p_units_out OUT NUMBER,
      p_status OUT VARCHAR2,
      p_msg OUT VARCHAR2,
      p_promo_code OUT VARCHAR2
   )
   IS
      v_site_part_objid NUMBER := p_site_part_objid;
      v_autopay_promo_info promo_rec_t;
      v_hybrid_promo_info promo_rec_t;
      v_process_autopay_plan BOOLEAN := FALSE;
      v_process_hybrid_plan BOOLEAN := FALSE;
      v_is_hybrid_plan BOOLEAN := FALSE;
      v_units_total NUMBER := 0;
      v_promo_msg VARCHAR2 (1000);
      v_promo_code VARCHAR2 (50);
      v_autohybrid_promo_ct NUMBER := p_promo_ct;
      v_g_msg VARCHAR (1000);
   BEGIN
      g_esn := p_esn; -- 10/04/02
      -- Initialize variables
      g_red_card_tab.delete;
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
      p_status := 'F';
      p_units_out := p_units;
      /* Getting the autopay promotion information, Checking whether the ESN is registered for autopay plan
         and Setting the flag to decide whether to give autopay  promotion or not.*/
      v_autopay_promo_info := get_autopay_promo_info_fun;
      IF (is_autopay_plan_fun (p_esn) = TRUE)
      AND (v_autopay_promo_info.promo_objid IS NOT NULL)
      THEN
         v_process_autopay_plan := TRUE;
      END IF;
      /* Checking if the ESN is registered for Hybrid Plan */
      IF (is_hybrid_plan_fun (p_esn) = TRUE)
      THEN
         v_is_hybrid_plan := TRUE;
      END IF;
      /*  **********  Start to process the Redemption cards *********************/
      IF (g_red_card_tab.COUNT > 0)
      THEN
         FOR i IN 0 .. g_red_card_tab.COUNT - 1
         /* Start processing for all the redemption cards */
         LOOP

            /*Get the redemption card details*/
            IF g_red_card_tab (i).red_code IS NOT NULL
            THEN
               get_red_card_info_prc (g_red_card_tab (i));
            END IF;
            IF g_red_card_tab (i).part_type = 'PAID'
            THEN
--CR 1138- 03/26/2003
               g_part_number := g_red_card_tab (i).part_num; --CR1409
               /*Start processing for autopay plan*/
               IF ( v_process_autopay_plan = TRUE
               AND ( g_red_card_tab (i).units IS NOT NULL
               OR g_red_card_tab (i).access_days IS NOT NULL))
               THEN
                  BEGIN
                     INSERT
                     INTO table_x_pending_redemption(
                        objid,
                        pend_red2x_promotion,
                        x_pend_red2site_part,
                        x_pend_type
                     ) VALUES(
                        -- 04/10/03 seq_x_pending_redemption.nextval+power(2,28),
                        seq ('x_pending_redemption'),
                        v_autopay_promo_info.promo_objid,
                        v_site_part_objid,
                        'Runtime'
                     );
                     v_units_total := v_units_total + NVL (v_autopay_promo_info.units
                     , 0);
                     v_promo_code := v_autopay_promo_info.promo_code;
                     p_msg := v_autopay_promo_info.message;
                     v_autohybrid_promo_ct := v_autohybrid_promo_ct + 1;
                     EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_status := 'F';
                        p_msg :=
                        'Fail to insert into table_x_pending_redemption.' ||
                        'Red code=' || g_red_card_tab ( i ).red_code ||
                        ' Site part objid=' || v_site_part_objid ||
                        ' Promo objid=' || v_autopay_promo_info.promo_objid ||
                        SUBSTR ( SQLERRM, 100 );
                        RETURN;
                  END;

               /* End of processing for the Autopay Plan */
               ELSE

                  /*Get the Hybrid promotion information */
                  v_hybrid_promo_info := get_hybrid_promo_info_fun (
                  g_red_card_tab (i).units);
                  IF ( v_is_hybrid_plan = TRUE
                  AND v_hybrid_promo_info.promo_objid IS NOT NULL)
                  THEN
                     v_process_hybrid_plan := TRUE;
                  END IF;
                  /* Start Processing for the Hybrid Plan */
                  IF (v_process_hybrid_plan = TRUE)
                  THEN
                     BEGIN
                        INSERT
                        INTO table_x_pending_redemption
                        (
                           objid,
                           pend_red2x_promotion,
                           x_pend_red2site_part,
                           x_pend_type
                        ) VALUES(
                           --04/10/03 seq_x_pending_redemption.nextval+power(2,28),
                           seq ('x_pending_redemption'),
                           v_hybrid_promo_info.promo_objid,
                           v_site_part_objid,
                           'Runtime'
                        );
                        v_units_total := v_units_total + NVL (
                        v_hybrid_promo_info.units, 0);
                        v_promo_code := v_hybrid_promo_info.promo_code;
                        p_msg := v_hybrid_promo_info.message;
                        v_autohybrid_promo_ct := v_autohybrid_promo_ct + 1;
                        EXCEPTION
                        WHEN OTHERS
                        THEN
                           p_status := 'F';
                           p_msg :=
                           'Fail to insert into table_x_pending_redemption.' ||
                           'Red code=' || g_red_card_tab ( i ).red_code ||
                           ' Site part objid=' || v_site_part_objid ||
                           ' Promo objid=' || v_hybrid_promo_info.promo_objid
                           || SUBSTR ( SQLERRM, 100 );
                           RETURN;
                     END;
                     -- Reinitialize the hybrid info */
                     v_hybrid_promo_info := NULL;
                     v_process_hybrid_plan := FALSE;
                  END IF;
/* End of processing for the Hybrid Plan*/
               END IF;
/* End of processing of autopay or hybrid*/
            END IF;
--CR 1138- 03/26/2003
         END LOOP;

      /*End of processing of all the redemption cards */
      END IF;
      IF v_autohybrid_promo_ct = 0
      THEN

         /* No redemption card qualified for any Tracfone promotion */
         p_status := 'N';
         --CR3190 Start
         /* p_msg := v_autohybrid_promo_ct ||
                  '#' ||
                  'Esn ' ||
                  p_esn ||
                  ' is not qualified for Tracfone promotion';*/
--CR3735 Starts
--          p_msg := v_autohybrid_promo_ct || '#' || 'Esn ' || p_esn ||
--          ' is not qualified for promotion';
         p_msg := 'Esn ' || p_esn ||
         ' is not qualified for promotion.';
--CR3735 Ends
         --CR3190 End
         p_promo_code := '0';
      ELSE

         /* This esn qualified for at least one Tracfone promotion*/
         p_units_out := p_units + v_units_total;
         p_status := 'S';
         v_g_msg :=
         'Your most recent airtime redemption has qualified you for multiple '
         || 'Tracfone promotions. ' || (p_units_out - p_units_in ) ||
         '  free units have been added to your phone.';
         IF v_autohybrid_promo_ct > 1
         THEN
            p_msg := v_g_msg;
            p_promo_code := '99';
         ELSE

            /* If there is only one promotion check if it is from Runtime Promotion or
               if it is Autopay /Hybrid */
            IF (p_promo_ct = 1)
            THEN
               p_msg := p_msg_in;
               p_promo_code := p_promo_code_in;
            ELSE
               p_msg := p_msg;
               p_promo_code := v_promo_code;
            END IF;
         END IF;
      END IF;
      p_msg := SUBSTR (p_msg, 1, 250);
      EXCEPTION
      WHEN OTHERS
      THEN
         p_status := 'F';
         p_msg := '<Unexpected Error> ' || SUBSTR (SQLERRM, 1, 100);
   END doautopaypromo_prc;
   /***************  Functions  **************************/
   /******************************************
   * Function get_autopay_detail_fun
    Description: Returns the program type 2-autopay,3-hybrid
   * IN: varchar2
   * OUT: number  --program_type.
   *******************************************/
   FUNCTION get_autopay_detail_fun(
      p_esn VARCHAR2
   )
   RETURN NUMBER
   IS
      v_program_type NUMBER;
   BEGIN
      SELECT x_program_type
      INTO v_program_type
      FROM table_x_autopay_details
      WHERE x_esn = p_esn
      AND x_status = 'A';
      RETURN v_program_type;
      EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_autopay_detail_fun;
   /******************************************
   * Function is_autopay_plan_fun
   * Description:Check if the esn is registered for autopay plan.
   IN: esn (varchar2)
   * RETURN: Boolean
   *******************************************/
   FUNCTION is_autopay_plan_fun(
      p_esn VARCHAR2
   )
   RETURN BOOLEAN
   IS
      v_esn_objid NUMBER;
      v_program_type NUMBER;
   BEGIN
      v_esn_objid := sp_runtime_promo.get_esn_part_inst_objid (p_esn);
      v_program_type := get_autopay_detail_fun (p_esn);
      IF ( NVL (v_program_type, 0) != 2
      OR (v_esn_objid IS NULL))
      THEN
         RETURN FALSE;
      END IF;
      RETURN TRUE;
      EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_autopay_plan_fun;
   /******************************************
   * Function is_hybrid_plan_fun
   * Description:Check if the esn is registered for hybrid plan
   IN: esn (varchar2)
   * RETURN: Boolean
   *******************************************/
   FUNCTION is_hybrid_plan_fun(
      p_esn IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      v_esn_objid NUMBER;
      v_program_type NUMBER;
   BEGIN
      v_esn_objid := sp_runtime_promo.get_esn_part_inst_objid (p_esn);
      v_program_type := get_autopay_detail_fun (p_esn);
      IF ( NVL (v_program_type, 0) != 3
      OR (v_esn_objid IS NULL))
      THEN
         RETURN FALSE;
      END IF;
      RETURN TRUE;
      EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_hybrid_plan_fun;
   /******************************************
   * Procedure get_red_card_info_prc
   * Description:Get the details about the redemption card.
   IN and OUT:  redemption card record
   ********************************************/
   PROCEDURE get_red_card_info_prc(
      p_card_rec IN OUT red_card_rec_t
   )
   IS
      v_card_rec red_card_rec_t;
   BEGIN
      v_card_rec := p_card_rec;
      ----modified based on Dan's Review
      SELECT pi.x_red_code,
         pn.x_redeem_units,
         pn.x_redeem_days,
         pn.part_number,
         pn.x_card_type,
         pn.part_type
      INTO p_card_rec
      FROM table_part_num pn, table_mod_level ml, table_part_inst pi
      WHERE pn.domain = 'REDEMPTION CARDS'
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.x_domain = 'REDEMPTION CARDS'
      AND pi.x_red_code = p_card_rec.red_code;
      /*
      --modified based on Dan's Review

      SELECT pi.x_red_code, pn.x_redeem_units,
         pn.x_redeem_days,
         pn.part_number, pn.x_card_type, pn.part_type
      INTO  p_card_rec
      FROM table_part_inst pi, table_mod_level ml,
       table_part_num pn
      WHERE pi.x_red_code = p_card_rec.red_code
          AND   pi.n_part_inst2part_mod = ml.objid
      AND   pi.x_domain = 'REDEMPTION CARDS'
      AND   ml.part_info2part_num = pn.objid
      AND   pn.domain = 'REDEMPTION CARDS';

      */
      EXCEPTION
      WHEN OTHERS
      THEN
         p_card_rec := v_card_rec;
   END get_red_card_info_prc;
   /******************************************
   * Function get_autopay_promo_info_fun
   * Description:Get the autopay promotion information.
   * OUT:  autopay promo info record.
   *******************************************/
   FUNCTION get_autopay_promo_info_fun
   RETURN promo_rec_t
   IS
      v_promo_rec promo_rec_t;
   BEGIN
      SELECT objid,
         x_units,
         x_access_days,
         x_promotion_text,
         x_promo_code,
         x_sql_statement
      INTO v_promo_rec
      FROM table_x_promotion
      WHERE ( SYSDATE BETWEEN x_start_date
      AND x_end_date
      OR x_end_date IS NULL)
      AND x_promo_code = 'RTAUTOPAY'
      AND x_promo_type = 'Runtime';
      RETURN v_promo_rec;
      EXCEPTION
      WHEN OTHERS
      THEN
         RETURN v_promo_rec;
   END get_autopay_promo_info_fun;
   /******************************************
   * Function get_hybrid_promo_info_fun
   * Description:Get the hybrid promotion information.
   * OUT: Hybrid promo info record.
   IN : Redemption card units
   *******************************************/
   FUNCTION get_hybrid_promo_info_fun(
      p_red_units VARCHAR2
   )
   RETURN promo_rec_t
   IS
      v_promo_rec promo_rec_t;
      v_sql_text LONG;
      v_cursorid INTEGER;
      v_bind_var VARCHAR2 (50);
      v_rc INTEGER;
      CURSOR ctbonus_c
      IS
      SELECT objid,
         x_units,
         x_access_days,
         x_promotion_text,
         x_promo_code,
         x_sql_statement
      FROM table_x_promotion
      WHERE ( SYSDATE BETWEEN x_start_date
      AND x_end_date
      OR x_end_date
      IS
      NULL)
      AND x_promo_code LIKE 'RTBONUS%'
      AND x_promo_type = 'Runtime';
   BEGIN
      FOR v_promo_rec IN ctbonus_c
      LOOP
         v_sql_text := v_promo_rec.x_sql_statement;
         v_cursorid := DBMS_SQL.open_cursor;
         BEGIN
            DBMS_SQL.parse (v_cursorid, v_sql_text, DBMS_SQL.v7);
            v_bind_var := ':red_units';
            IF NVL (INSTR (v_sql_text, v_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable ( v_cursorid, RTRIM (LTRIM (v_bind_var)),
               p_red_units );
            END IF;
            --10/04/02
            -- bind esn
            v_bind_var := ':esn';
            IF NVL (INSTR (v_sql_text, v_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable ( v_cursorid, RTRIM (LTRIM (v_bind_var)),
               g_esn );
            END IF;
            -- end 10/04/02
            --Bind partnumber APP100 CR1409
            v_bind_var := ':part_number';
            IF NVL (INSTR (v_sql_text, v_bind_var), 0) > 0
            THEN
               DBMS_SQL.bind_variable ( v_cursorid, RTRIM (LTRIM (v_bind_var)),
               g_part_number );
            END IF;
            --end CR1409
            EXCEPTION
            WHEN OTHERS
            THEN
               IF DBMS_SQL.is_open (v_cursorid)
               THEN
                  DBMS_SQL.close_cursor (v_cursorid);
               END IF;
               RETURN NULL;
         END;
         v_rc := DBMS_SQL.         execute (v_cursorid);
         IF (DBMS_SQL.fetch_rows (v_cursorid) > 0)
         THEN

            -- 09/24/02
            -- close cursor before return
            --
            DBMS_SQL.close_cursor (v_cursorid);
            -- end
            RETURN v_promo_rec;
         END IF;
         DBMS_SQL.close_cursor (v_cursorid);
      END LOOP;
      v_promo_rec := NULL;
      RETURN v_promo_rec;
      EXCEPTION
      WHEN OTHERS
      THEN

         -- 09/24/02
         -- close cursor before return
         --
         IF DBMS_SQL.is_open (v_cursorid)
         THEN
            DBMS_SQL.close_cursor (v_cursorid);
         END IF;
         -- end
         RETURN NULL;
   END get_hybrid_promo_info_fun;
END autopay_promo_pkg;
/
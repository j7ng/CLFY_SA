CREATE OR REPLACE PROCEDURE sa."SP_IVR_PROMO_SERVICE"
(
  p_esn              IN VARCHAR2
 ,p_promo_group_name IN VARCHAR2
 ,p_red_code01       IN VARCHAR2 DEFAULT NULL
 ,p_red_code02       IN VARCHAR2 DEFAULT NULL
 ,p_red_code03       IN VARCHAR2 DEFAULT NULL
 ,p_red_code04       IN VARCHAR2 DEFAULT NULL
 ,p_red_code05       IN VARCHAR2 DEFAULT NULL
 ,p_red_code06       IN VARCHAR2 DEFAULT NULL
 ,p_red_code07       IN VARCHAR2 DEFAULT NULL
 ,p_red_code08       IN VARCHAR2 DEFAULT NULL
 ,p_red_code09       IN VARCHAR2 DEFAULT NULL
 ,p_red_code10       IN VARCHAR2 DEFAULT NULL
 ,p_act_type         IN VARCHAR2
 ,p_result           OUT NUMBER
 ,p_msg              OUT VARCHAR2
) AS
  /************************************************************************************************|
  |    Copyright   Tracfone  Wireless Inc. All rights reserved                                    |
  |                                                                                             |
  | NAME     :       SP_IVR_PROMO_SERVICE  procedure                                |
  | PURPOSE                                                                                        |
  | FREQUENCY:                                                                                  |
  | PLATFORMS:                                                                                     |
  |                                                                                             |
  | REVISIONS:                                                                                  |
  | VERSION  DATE        WHO              PURPOSE                                            |
  | -------  ---------- -----             ------------------------------------------------------   |
  | 1.0      06/28/05   SL                Initial revision                                   |
  | 1.1      07/19/05   SL                CR3922                                                   |
  | 1.2      07/20/05   SL                CR4282  NET10 promotion for redemption of 300,600        |
  | 1.3      08/03/05   VA                CR4374
  | 1.4      08/15/05   VA                CR4392
  | 1.5      08/16/05   VA                Fix for CR4392 (PVCS Revision 1.13)
  | 1.6      11/09/06   VA                CR5759 changes
  | 1.7      12/19/06   VA    CR5874 -1 XMAS FIX-Zero unit cases and 30 day message - Scripting and text changes

  | NEW PVCS FILE STRUCTURE NEW_PLSQL
  | 1.0/1.1      08/31/09   NG    BRAND_SEP Separate the Brand and Source System
  |                           incorporate use of new table TABLE_BUS_ORG to retrieve
  |                           brand information that was previously identified by the fields
  |                           x_restricted_use and/or amigo from table_part_num
  |
  | 1.2           06/03/11 ICanavan CR16379 / CR16344 triple minute promo
  |************************************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SP_IVR_PROMO_SERVICE.sql,v $
  --$Revision: 1.3 $
  --$Author: kacosta $
  --$Date: 2012/04/03 15:13:36 $
  --$ $Log: SP_IVR_PROMO_SERVICE.sql,v $
  --$ Revision 1.3  2012/04/03 15:13:36  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  CURSOR c_promo_group IS
    SELECT *
      FROM table_x_promotion_group
     WHERE UPPER(group_name) = UPPER(TRIM(p_promo_group_name));

  CURSOR c_esn IS
    SELECT pi.objid
          ,bo.org_id --x_restricted_use -- BRAND_SEP
      FROM table_part_num  pn
          ,table_mod_level ml
          ,table_part_inst pi
          ,table_bus_org   bo
     WHERE 1 = 1
       AND ml.part_info2part_num = pn.objid
       AND pi.n_part_inst2part_mod = ml.objid
       AND pi.part_serial_no = TRIM(p_esn)
       AND pn.part_num2bus_org = bo.objid;

  CURSOR c_this_group IS
    SELECT *
      FROM table_x_group2esn
     WHERE groupesn2part_inst = (SELECT objid
                                   FROM table_part_inst
                                  WHERE part_serial_no = p_esn)
       AND groupesn2x_promo_group IN (SELECT objid
                                        FROM table_x_promotion_group
                                       WHERE group_name IN ('90_DAY_SERVICE'
                                                           ,'52020_GRP'))
       AND x_end_date > SYSDATE;

  --CR4282
  CURSOR c_this_group2 IS
    SELECT *
      FROM table_x_group2esn
     WHERE groupesn2part_inst = (SELECT objid
                                   FROM table_part_inst
                                  WHERE part_serial_no = p_esn)
       AND groupesn2x_promo_group IN (SELECT objid
                                        FROM table_x_promotion_group
                                       WHERE group_name IN ('NET10_300_GRP'
                                                           ,'NET10_600_GRP'))
       AND x_end_date > SYSDATE;

  c_this_group_rec c_this_group%ROWTYPE;

  --CR4392 Starts
  CURSOR c_this_group3 IS
    SELECT *
      FROM table_x_group2esn
     WHERE groupesn2part_inst = (SELECT objid
                                   FROM table_part_inst
                                  WHERE part_serial_no = p_esn)
       AND groupesn2x_promo_group IN (SELECT objid
                                        FROM table_x_promotion_group
                                       WHERE group_name IN ('POST_PURCH_TEST_GRP_1'
                                                           ,'POST_PURCH_TEST_GRP_2'
                                                           ,'POST_PURCH_TEST_GRP_3'))
       AND x_end_date > SYSDATE;

  c_this_group3_rec c_this_group3%ROWTYPE;

  --CR4392 Ends
  TYPE t_g_red_card_tab IS TABLE OF table_part_inst.x_red_code%TYPE INDEX BY BINARY_INTEGER;

  g_red_card_tab    t_g_red_card_tab;
  c_promo_group_rec c_promo_group%ROWTYPE;
  c_esn_rec         c_esn%ROWTYPE;
  l_autopay_cnt     NUMBER := 0;
  l_annual_cnt      NUMBER := 0;
  l_pend_cnt        NUMBER := 0;
  l_dbl_min_cnt     NUMBER := 0;
  l_this_cnt        NUMBER := 0;
  l_dummy           NUMBER := 0;
  l_pastdue         NUMBER := 0;
  l_40_cnt          NUMBER := 0;
  -- CR3922
  l_result CHAR(1); --CR5759
BEGIN
  p_result := 1;

  OPEN c_promo_group;

  FETCH c_promo_group
    INTO c_promo_group_rec;

  CLOSE c_promo_group;

  IF c_promo_group_rec.group_name IS NULL THEN
    p_result := 1;
    p_msg    := 'Invalid promotion group ' || p_promo_group_name;
    RETURN;
    --CR4374 Starts
  ELSIF TRUNC(SYSDATE) > c_promo_group_rec.x_end_date THEN
    p_result := 1;
    p_msg    := 'Promotion group Expired' || p_promo_group_name;
    RETURN;
    --CR4374 Ends
  ELSIF c_promo_group_rec.group_name NOT IN ('90_DAY_SERVICE'
                                            ,'52020_GRP'
                                            ,'NET10_300_GRP'
                                            ,'NET10_600_GRP'
                                            ,'POST_PURCH_TEST_GRP_1'
                                            ,'POST_PURCH_TEST_GRP_2'
                                            ,'POST_PURCH_TEST_GRP_3') --CR4392
   THEN
    p_result := 1;
    p_msg    := 'Invalid promotion group ' || p_promo_group_name;
    RETURN;
  ELSIF c_promo_group_rec.group_name IN ('NET10_300_GRP'
                                        ,'NET10_600_GRP') THEN
    IF p_act_type <> '1' THEN
      p_result := 1;
      p_msg    := 'Promotion group: ' || c_promo_group_rec.group_name || ' requires activation to qualify.';
      RETURN;
    END IF;
  END IF;

  OPEN c_esn;

  FETCH c_esn
    INTO c_esn_rec;

  CLOSE c_esn;

  IF c_esn_rec.objid IS NULL THEN
    p_result := 1;
    p_msg    := 'Invalid ESN ' || p_esn;
    RETURN;
  END IF;

  -- BRAND_SEP
  IF c_promo_group_rec.group_name IN ('NET10_300_GRP'
                                     ,'NET10_600_GRP')
     AND c_esn_rec.org_id != 'NET10' THEN
    p_result := 1;
    p_msg    := 'Promotion group: ' || c_promo_group_rec.group_name || ' requires NET10 phone to qualify.';
    RETURN;
  END IF;

  IF c_promo_group_rec.group_name NOT IN ('POST_PURCH_TEST_GRP_1'
                                         ,'POST_PURCH_TEST_GRP_2'
                                         ,'POST_PURCH_TEST_GRP_3') THEN
    --CR4392
    IF c_promo_group_rec.x_current_count >= c_promo_group_rec.x_max_count THEN
      p_result := 1;
      p_msg    := 'Max count reached';

      IF c_promo_group_rec.x_end_date > SYSDATE THEN
        UPDATE table_x_promotion_group u
           SET x_end_date = SYSDATE
         WHERE u.objid = c_promo_group_rec.objid;

        COMMIT;
      END IF;

      RETURN;
    END IF;
  END IF; --CR4392

  g_red_card_tab.delete;
  g_red_card_tab(0) := p_red_code01;
  g_red_card_tab(1) := p_red_code02;
  g_red_card_tab(2) := p_red_code03;
  g_red_card_tab(3) := p_red_code04;
  g_red_card_tab(4) := p_red_code05;
  g_red_card_tab(5) := p_red_code06;
  g_red_card_tab(6) := p_red_code07;
  g_red_card_tab(7) := p_red_code08;
  g_red_card_tab(8) := p_red_code09;
  g_red_card_tab(9) := p_red_code10;

  FOR i IN 0 .. 9 LOOP
    IF TRIM(g_red_card_tab(i)) IS NOT NULL THEN
      SELECT COUNT(1)
        INTO l_dummy
        FROM table_part_num  pn
            ,table_mod_level ml
            ,table_part_inst pi
       WHERE 1 = 1
         AND pn.x_redeem_days = 365
         AND ml.part_info2part_num = pn.objid
         AND pi.n_part_inst2part_mod + 0 = ml.objid
         AND pi.x_red_code = TRIM(g_red_card_tab(i));

      l_annual_cnt := l_annual_cnt + l_dummy;

      -- CR3922 ONLY 40 minute card can qualify 52020_GRP
      IF c_promo_group_rec.group_name = '52020_GRP' THEN
        SELECT COUNT(1)
          INTO l_dummy
          FROM table_part_num  pn
              ,table_mod_level ml
              ,table_part_inst pi
         WHERE 1 = 1
           AND pn.x_redeem_units = 40
           AND ml.part_info2part_num = pn.objid
           AND pi.n_part_inst2part_mod + 0 = ml.objid
           AND pi.x_red_code = TRIM(g_red_card_tab(i));

        l_40_cnt := l_40_cnt + l_dummy;
      END IF;
      -- end CR3922
    END IF;
  END LOOP;

  IF l_annual_cnt > 0 THEN
    p_result := 1;
    p_msg    := 'PENDing annual card found.';
    RETURN;
  END IF;

  IF l_40_cnt = 0
     AND c_promo_group_rec.group_name = '52020_GRP' THEN
    p_result := 1;
    p_msg    := 'Need to redeem 40 minute card to qualify.';
    RETURN;
  END IF;

  IF c_promo_group_rec.group_name IN ('52020_GRP'
                                     ,'90_DAY_SERVICE') THEN
    OPEN c_this_group;

    FETCH c_this_group
      INTO c_this_group_rec;

    CLOSE c_this_group;

    IF c_this_group_rec.objid IS NOT NULL THEN
      p_result := 1;
      p_msg    := 'Already a member of 52020_GRP or 90_DAY_SERVICE';
      RETURN;
    END IF;
  ELSIF c_promo_group_rec.group_name IN ('NET10_300_GRP'
                                        ,'NET10_600_GRP') THEN
    OPEN c_this_group2;

    FETCH c_this_group2
      INTO c_this_group_rec;

    CLOSE c_this_group2;

    IF c_this_group_rec.objid IS NOT NULL THEN
      p_result := 1;
      p_msg    := 'Already a member of NET10_300_GRP or NET10_600_GRP';
      RETURN;
    END IF;
    --CR4392 Starts
  ELSIF c_promo_group_rec.group_name IN ('POST_PURCH_TEST_GRP_1'
                                        ,'POST_PURCH_TEST_GRP_2'
                                        ,'POST_PURCH_TEST_GRP_3') THEN
    OPEN c_this_group3;

    FETCH c_this_group3
      INTO c_this_group3_rec;

    CLOSE c_this_group3;

    IF c_this_group3_rec.objid IS NOT NULL THEN
      p_result := 1;
      p_msg    := 'Already a member of Post Purchase Tracfone Price Tests';
      RETURN;
    END IF;
    --CR4392 Ends
  END IF;

  SELECT COUNT(1)
    INTO l_autopay_cnt
    FROM table_x_autopay_details
   WHERE 1 = 1
     AND x_status = 'A'
     AND x_esn = p_esn;

  IF l_autopay_cnt > 0 THEN
    p_result := 1;
    p_msg    := 'Already Autopay member';
    RETURN;
  END IF;

  SELECT COUNT(1)
    INTO l_annual_cnt
    FROM table_part_num     pn
        ,table_mod_level    ml
        ,table_x_red_card   rc
        ,table_x_call_trans ct
   WHERE 1 = 1
     AND pn.x_redeem_days = 365
     AND ml.part_info2part_num = pn.objid
     AND rc.x_red_card2part_mod = ml.objid
     AND ct.objid = rc.red_card2call_trans
     AND ct.x_result = 'Completed'
     AND ct.x_service_id = p_esn
     AND ct.x_transact_date + 0 >= SYSDATE - 365;

  IF l_annual_cnt > 0 THEN
    p_result := 1;
    p_msg    := 'Already redeemed annual card or double card in last 365 days';
    RETURN;
  END IF;

  SELECT COUNT(1)
    INTO l_dbl_min_cnt
    FROM table_x_group2esn
   WHERE groupesn2part_inst = (SELECT objid
                                 FROM table_part_inst
                                WHERE part_serial_no = p_esn)
     AND groupesn2x_promo_group IN (SELECT objid
                                      FROM table_x_promotion_group
                                     WHERE group_name IN ('52293_GRP1'
                                                         ,'52293_GRP2'
                                                         ,'52312_GRP'
                                                         ,'DBLMIN_ADVAN_GRP'
                                                         ,'DBLMIN_GRP'
                                                         ,'DBLMN_3390_GRP'
                                                         ,'X3XMN_GRP' -- CR16379 / CR16344
                                                          ))
     AND x_end_date > SYSDATE;

  IF l_dbl_min_cnt > 0 THEN
    p_result := 1;
    p_msg    := 'Already Double Minute member';
    RETURN;
  END IF;

  SELECT COUNT(1)
    INTO l_pend_cnt
    FROM table_x_pending_redemption p
   WHERE x_pend_red2site_part = (SELECT objid
                                   FROM table_site_part
                                  WHERE x_service_id = p_esn
                                    AND part_status || '' = 'Active'
                                    AND ROWNUM = 1)
     AND x_pend_type IN ('Runtime'
                        ,'Promocode');

  IF l_pend_cnt > 0 THEN
    p_result := 1;
    p_msg    := 'PENDing promotion exists';
    RETURN;
  END IF;

  --CR4392 Starts
  IF stack_duedate_calc_pkg.is_ae_esn(p_esn) THEN
    p_result := 1;
    p_msg    := 'Annual Service Esn.';
    RETURN;
  END IF;

  --CR4392 Ends
  IF c_promo_group_rec.group_name NOT IN ('NET10_300_GRP'
                                         ,'NET10_600_GRP') THEN
    --CR5874-1
    INSERT INTO table_x_group2esn
      (objid
      ,x_annual_plan
      ,groupesn2part_inst
      ,groupesn2x_promo_group
      ,x_start_date
      ,x_end_date)
    VALUES
      (seq('x_group2esn')
      ,0
      ,c_esn_rec.objid
      ,c_promo_group_rec.objid
      ,SYSDATE
      ,TO_DATE('01-JAN-2035'
              ,'DD-MON-RRRR'));
    --CR5874-1
  ELSE
    p_result := 1;
    p_msg    := 'ESN ' || p_esn || ' not qualified for ivr promotion';
    RETURN;
  END IF;

  --    IF c_promo_group_rec.group_name = 'NET10_300_GRP'
  --    THEN
  --       SELECT objid
  --         INTO l_dummy
  --         FROM table_x_promotion_group
  --        WHERE group_name = 'NET10_600_GRP';
  --
  --       INSERT INTO table_x_group2esn
  --                   (objid, x_annual_plan, groupesn2part_inst,
  --                    groupesn2x_promo_group, x_start_date, x_end_date
  --                   )
  --            VALUES (sa.seq ('x_group2esn'), 0, c_esn_rec.objid,
  --                    l_dummy, SYSDATE, TO_DATE ('01-JAN-2035', 'DD-MON-RRRR')
  --                   );
  --    END IF;
  --CR5874-1
  IF c_promo_group_rec.group_name NOT IN ('POST_PURCH_TEST_GRP_1'
                                         ,'POST_PURCH_TEST_GRP_2'
                                         ,'POST_PURCH_TEST_GRP_3') --CR4392
   THEN
    IF c_promo_group_rec.x_max_count > 0 THEN
      UPDATE table_x_promotion_group
         SET x_current_count = x_current_count + 1
       WHERE objid = c_promo_group_rec.objid;
    END IF;
  END IF; --CR4392

  --CR5759
  IF c_promo_group_rec.group_name IN ('BUY_1_GET_1_GRP') THEN
    get_buygetfree_qual_prc(p_esn
                           ,p_promo_group_name
                           ,l_result);

    IF l_result <> 'S' THEN
      p_result := 1;
      p_msg    := 'ESN ' || p_esn || ' not qualified for ivr promotion';
      RETURN;
    END IF;
  END IF;

  --CR5759
  COMMIT;
  p_result := 0;
  p_msg    := 'ESN ' || p_esn || ' qualify for ivr promotion';
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
  WHEN others THEN
    p_result := 99;
    p_msg    := 'SQL error: ' || SQLERRM;
END;
/
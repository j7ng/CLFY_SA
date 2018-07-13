CREATE OR REPLACE PACKAGE BODY sa."STACK_DUEDATE_CALC_PKG"
IS
/********************************************************************************/
   /*    Copyright ) 2004 Tracfone  Wireless Inc. All rights reserved              */
   /*                                                                              */
   /* NAME:         STACK_DUEDATE_CALC(PACKAGE SPECIFICATION)                      */
   /* PURPOSE:      To calculate the stacking days for an esn during redemption    */
   /* FREQUENCY:                                                                   */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                               */
   /* REVISIONS:                                                                   */
   /* VERSION  DATE     WHO        PURPOSE                                         */
   /* ------  ----     ------      --------------------------------------------    */
   /* 1.0    01/15/04  VAdapa      Initial  Revision                               */
   /* 1.1    02/11/04  VAdapa      CR2481 - Fix for radioshack esns to receive     */
   /*                              correct due date (IS_AE_ESN)                    */
   /* 1.2    02/19/04  VAdapa      If the current due date is more than the new    */
   /*                              calculated due date, return the current due date*/
   /* 1.3    01/12/05  VAdapa      CR3509 - Fix to exclude 0 access days cards     */
   /* 1.4    09/22/04  VAdapa      CR3190 - Net 10 Changes                         */
   /* 1.5    06/03/05  VAdapa      CR3945 - Website Super-Size Top-Up Offers
   /* 1.6/1.7 06/03/05 VAdapa      Checked out to check-in with the correct PVCS revision
   /* 1.8    06/06/05  VAdapa      Fix to return the best among two when calculating the due date for 60 day access cards
   /* 1.9    06/07/05  VAdapa      Fix not to include the promo cards while calculating days for the non-annual plan cards
   /* 1.10   06/20/05  VAdapa      CR4184 - EME Winback Double minute/double day Promo on any non-annual redeemed cards
   /* 1.11   06/21/05  VAdapa      Fix for CR4184 (Null Pointer Exception Error Fixed)
   /* 1.11   06/21/05  VAdapa      Fix for CR4184 (Null Pointer Exception Error Fixed)
   /* 1.12   07/01/05  VAdapa      CR4102 - Enroll a random sample (Changes to GET_STACKDAYS_MULTIPLIER)
   /* 1.13   07/03/05  VAdapa      Fix for CR4102
   /* 1.14   07/03/05  VAdapa      Fix for CR4102
   /* 1.15   07/22/05  VAdapa      CR4282 -  NET10 - Increase Service Days on 300  minute airtime cards
   /* 1.16   08/18/05  VAdapa      CR4392
   /* 1.17   03/23/06  Nguada      CR5161 Filter Double Access for Net10 cards
   /* 1.18   03/27/06  VAdapa/Curt Based on Curt's recommendations, changes have been made to improve the performance
   /* 1.19   04/06/06  VAdapa    CR5141 - Added logic to override the stacking day limit if there are promo days
   /* 1.20/1.21   05/04/06  VAdapa    CR5197  - Modified to return the higher due date
   /* 1.22    06/21/06 VAdapa      CR5247 - Exclude the redcards that are attached to this promo "PROMO_CARD"
   /* 1.23/1.24    10/13/06 VAdapa    CR5625
   /* 1.25     10/25/06     VAdapa    CR5702
   /* 1.26    11/02/06  VAdapa   CR5702-2
	/* 1.26.1.1    02/16/07  VAdapa   CR6048 - Service days correction
   /* 1.27 /1.28   02/01/07   VAdapa   CR5848 - Tracfone and Net10 Airtime Price Change
                            Remove the Stacking limit based on table_x_parameter setting
	/* 1.29        02/23/07     VAdapa     Merged CR6048 with CR5848
	/* 1.30        02/27/07     VAdapa     Modified to fix edfect #138 under CR 5848
   /* 1.31    03/09/07	RSI          CR4479 - Billing Platform Determining stack policy changes merged
   ------------------------------------------------------------------------------------------------------------------------------------------
   ----------- NEW PVCS STRUCTURE
   /* 1.0      CR7485 block Dec 24-28 due dates
   /* 1.1      8/27/09 NGuada     BRAND_SEP Separate the Brand and Source System
   /********************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: STACK_DUEDATE_CALC_PKG.sql,v $
  --$Revision: 1.3 $
  --$Author: kacosta $
  --$Date: 2012/04/03 14:46:30 $
  --$ $Log: STACK_DUEDATE_CALC_PKG.sql,v $
  --$ Revision 1.3  2012/04/03 14:46:30  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  --********************************************************************************
  --
   PROCEDURE main (
      p_esn                   VARCHAR2,
      p_esn_type              VARCHAR2,
      p_red_code01            VARCHAR2,
      p_red_code02            VARCHAR2 DEFAULT NULL,
      p_red_code03            VARCHAR2 DEFAULT NULL,
      p_red_code04            VARCHAR2 DEFAULT NULL,
      p_red_code05            VARCHAR2 DEFAULT NULL,
      p_red_code06            VARCHAR2 DEFAULT NULL,
      p_red_code07            VARCHAR2 DEFAULT NULL,
      p_red_code08            VARCHAR2 DEFAULT NULL,
      p_red_code09            VARCHAR2 DEFAULT NULL,
      p_red_code10            VARCHAR2 DEFAULT NULL,
      p_curr_due_date         VARCHAR2,
      p_trans_type            VARCHAR2,
      p_sourcesystem          VARCHAR2,                              --CR3181
      p_promo_days            NUMBER,                                --CR4392
      p_new_due_date    OUT   VARCHAR2,
      p_status          OUT   VARCHAR2,
      p_msg             OUT   VARCHAR2
   )
   IS
      l_ann                     NUMBER                            := 0;
      l_dmpp                    NUMBER                            := 0;
      l_non_ann                 NUMBER                            := 0;
      l_net10_cnt               NUMBER                            := 0;
      --CR3190
      l_running_duedate      DATE;
      l_curr_due_date           DATE;
      l_step                              VARCHAR2 (200);
      l_dmdd_date                DATE;
      l_promo_card_days  NUMBER                            := 0;

      --CR5625
      CURSOR c_get_param_days
      IS
         SELECT *
           FROM TABLE_X_PARAMETERS
          WHERE x_param_name IN ('EXTEND_SERVICE_DAYS');

      r_get_param_days          c_get_param_days%ROWTYPE;

      CURSOR c_get_param_start_date
      IS
         SELECT *
           FROM TABLE_X_PARAMETERS
          WHERE x_param_name IN ('QUALIFY_EXTEND_START_DATE');

      r_get_param_start_date    c_get_param_start_date%ROWTYPE;

      CURSOR c_get_param_end_date
      IS
         SELECT *
           FROM TABLE_X_PARAMETERS
          WHERE x_param_name IN ('QUALIFY_EXTEND_END_DATE');

      r_get_param_end_date      c_get_param_end_date%ROWTYPE;
      l_param_days              NUMBER;
      l_param_start_date        DATE;
      l_param_end_date          DATE;
      l_extend_flag             NUMBER                            := 0;

--CR3945
   ---- CR4479 : Billing Platform Changes Start
      l_stacking_policy VARCHAR2(20);  --CR4479 : Determines the Max. Stacking Policy
      l_prev_due_date   DATE        ;  --CR4479 : For determining, which card gives the max. days (GAP Stacking)
      l_max_days        NUMBER:=0   ;  --CR4479 : For determining, which card gives the max. days (GAP Stacking)
                                        -- GAP Stacking Logic:
                                        -- For all the redemption cards, find the card that gives the max.number of
                                        -- days. This will be added to the date passed into the procedure when
                                        -- the max. stacking policy is GAP Stacking
    ---- CR4479 : Billing Platfrom Changes End
--CR5848
      CURSOR c_get_param_stack_limit
      IS
         SELECT *
           FROM TABLE_X_PARAMETERS
          WHERE x_param_name IN ('STACK_LIMIT');

      r_get_param_stack_limit   c_get_param_stack_limit%ROWTYPE;
      l_param_stack_limit       NUMBER;
--CR5848
   BEGIN
--CR5625
      OPEN c_get_param_days;

      FETCH c_get_param_days
       INTO r_get_param_days;

      IF c_get_param_days%FOUND
      THEN
         l_param_days := r_get_param_days.x_param_value;
      ELSE
         l_param_days := NULL;
      END IF;

      CLOSE c_get_param_days;

      OPEN c_get_param_start_date;

      FETCH c_get_param_start_date
       INTO r_get_param_start_date;

      IF c_get_param_start_date%FOUND
      THEN
         l_param_start_date := r_get_param_start_date.x_param_value;
      ELSE
         l_param_start_date := NULL;
      END IF;

      CLOSE c_get_param_start_date;

      OPEN c_get_param_end_date;

      FETCH c_get_param_end_date
       INTO r_get_param_end_date;

      IF c_get_param_end_date%FOUND
      THEN
         l_param_end_date := r_get_param_end_date.x_param_value;
      ELSE
         l_param_end_date := NULL;
      END IF;

      CLOSE c_get_param_end_date;

      IF     l_param_days IS NOT NULL
         AND l_param_start_date IS NOT NULL
         AND l_param_end_date IS NOT NULL
      THEN
         l_extend_flag := 1;
      ELSE
         l_extend_flag := 0;
      END IF;

      --CR5625
--CR5848
      OPEN c_get_param_stack_limit;

      FETCH c_get_param_stack_limit
       INTO r_get_param_stack_limit;

      IF c_get_param_stack_limit%FOUND
      THEN
         l_param_stack_limit := r_get_param_stack_limit.x_param_value;
      ELSE
         l_param_stack_limit := 1;
      END IF;

--CR5848
      g_red_card_tab.DELETE;
      g_non_ann_card_tab.DELETE;
      g_dmpp_card_tab.DELETE;
      g_ann_card_tab.DELETE;
      g_net10_card_tab.DELETE;                                        --CR3190
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
      l_curr_due_date := TO_DATE (p_curr_due_date, 'mm/dd/yyyy hh24:mi:ss');
      l_running_duedate := l_curr_due_date;

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

            --CR3190 Start
            IF g_red_card_tab (i).brand_name = 'NET10'
            THEN
               g_net10_card_tab (l_net10_cnt) := g_red_card_tab (i);
               l_net10_cnt := l_net10_cnt + 1;
            ELSE
               --CR3190 End
               IF     (    (   (g_red_card_tab (i).annual_status <> 'ANNUAL'
                               )
                            OR (g_red_card_tab (i).annual_status IS NULL)
                           )
                       AND (    (g_red_card_tab (i).access_days <> 365)
                            AND g_red_card_tab (i).access_days <> 0
                           )
                      )                                       --CR3509 Changes
                  AND (NVL (g_red_card_tab (i).x_promo_code, 'CCC') <>
                                                                  'PROMO_CARD'
                      )                                         --CR3945 (1.9)
               THEN
                  g_non_ann_card_tab (l_non_ann) := g_red_card_tab (i);
                  l_non_ann := l_non_ann + 1;
               ELSIF (    (g_red_card_tab (i).access_days = 365)
                      -- CR16379 Start kacosta 03/12/2012
                      --AND (g_red_card_tab (i).x_promo_code = 'RTDBL000')
                      AND (g_red_card_tab(i).x_promo_code IN ('RTDBL000','RTX3X000'))
                      -- CR16379 End kacosta 03/12/2012
                      AND (NVL (g_red_card_tab (i).x_promo_code, 'CCC') <>
                                                                  'PROMO_CARD'
                          )                                           --CR5247
                     )
               THEN
                  g_dmpp_card_tab (l_dmpp) := g_red_card_tab (i);
                  l_dmpp := l_dmpp + 1;
               ELSIF (    (g_red_card_tab (i).access_days = 365)
                      -- CR16379 Start kacosta 03/12/2012
                      --AND (NVL (g_red_card_tab (i).x_promo_code, 'ZZZ') <>
                      --                                              'RTDBL000'
                      --    )
                      AND (NVL(g_red_card_tab(i).x_promo_code, 'ZZZ') NOT IN ('RTDBL000','RTX3X000'))
                      -- CR16379 End kacosta 03/12/2012
                      AND (NVL (g_red_card_tab (i).x_promo_code, 'CCC') <>
                                                                  'PROMO_CARD'
                          )                                           --CR5247
                     )                                        --CR3509 Changes
               THEN
                  g_ann_card_tab (l_ann) := g_red_card_tab (i);
                  l_ann := l_ann + 1;
               END IF;
            END IF;

            -- NET10 Check(CR3190)
            --CR3945 Starts
            IF g_red_card_tab (i).x_promo_code = 'PROMO_CARD'
            THEN
               l_promo_card_days :=
                           l_promo_card_days + g_red_card_tab (i).access_days;
            END IF;
--CR3945 Ends
         END IF;
      END LOOP;

--CR5848
      DBMS_OUTPUT.put_line ('l_param_stack_limit ' || l_param_stack_limit);

      IF l_param_stack_limit = 0
      THEN
         IF l_net10_cnt > 0
         THEN
            FOR z IN 1 .. l_net10_cnt
            LOOP
               l_running_duedate :=
                  calc_nolimit_dd (p_esn,
                                   l_running_duedate,
                                   g_net10_card_tab (z - 1).access_days,
                                   p_promo_days
                                  );
            END LOOP;
         END IF;                                                    --Rev 1.30

         IF l_non_ann > 0
         THEN
            FOR j IN 1 .. l_non_ann
            LOOP
               l_running_duedate :=
                  calc_nolimit_dd (p_esn,
                                   l_running_duedate,
                                   g_non_ann_card_tab (j - 1).access_days,
                                   p_promo_days
                                  );
            END LOOP;
         END IF;                                                    --Rev 1.30

         IF l_ann > 0
         THEN
            FOR j IN 1 .. l_ann
            LOOP
               l_running_duedate :=
                  calc_nolimit_dd (p_esn,
                                   l_running_duedate,
                                   g_ann_card_tab (j - 1).access_days,
                                   p_promo_days
                                  );
            END LOOP;
         END IF;                                                    --Rev 1.30

         IF l_dmpp > 0
         THEN
            FOR j IN 1 .. l_dmpp
            LOOP
               l_running_duedate :=
                  calc_nolimit_dd (p_esn,
                                   l_running_duedate,
                                   g_dmpp_card_tab (j - 1).access_days,
                                   p_promo_days
                                  );
            END LOOP;
         END IF;
      ELSE
--CR5848 End
      --CR3190 Start
         IF l_net10_cnt > 0
         THEN
            FOR z IN 1 .. l_net10_cnt
            LOOP
         l_prev_due_date := l_running_duedate;           -- CR4479
--Cr4282 Start
            --             l_running_duedate := calc_net10_dd(l_running_duedate,
            --             g_net10_card_tab (z - 1).access_days);
               l_running_duedate :=
                  calc_net10_dd (p_esn,
                                 l_running_duedate,
                                 g_net10_card_tab (z - 1).access_days,
                                 g_net10_card_tab (z - 1).units
                                );
--CR4282 End
         -- CR4479 Start
         IF ( l_running_duedate - l_prev_due_date > l_max_days ) THEN
            l_max_days := l_running_duedate - l_prev_due_date;
         END IF;
         -- CR4479 End

            END LOOP;
            l_max_days := l_max_days + ( l_curr_due_date-SYSDATE );  -- CR4479
         ELSE
            --CR3190 End
            IF p_esn_type = 'RG'
            THEN
               /* Process Non-Annual Cards here */
               l_step :=
                       'Stack Non-Annual Cards for Non-Annual Plan Customers';

               IF l_non_ann > 0
               THEN
                  IF NOT is_ae_esn (p_esn)
                  THEN
                     FOR j IN 1 .. l_non_ann
                     LOOP
                                          l_prev_due_date := l_running_duedate;           -- CR4479
--CR4184 Starts
                     --                      l_running_duedate := calc_reg_card_dd (l_running_duedate,
                     --                      l_ann, l_dmpp);
                     --                      l_running_duedate := calc_reg_card_dd (p_esn,l_running_duedate, l_ann, l_dmpp);
                        l_running_duedate :=
                           calc_reg_card_dd (p_esn,
                                             l_running_duedate,
                                             l_ann,
                                             l_dmpp,
                                             p_promo_days
                                            );
--CR4392
                  --CR4184 Ends
                  -- CR4479 Start
                     IF ( l_running_duedate - l_prev_due_date > l_max_days ) THEN
                        l_max_days := l_running_duedate - l_prev_due_date;
                     END IF;
                  -- CR4479 End

                     END LOOP;
                  ELSE
                     FOR j IN 1 .. l_non_ann
                     LOOP
l_prev_due_date := l_running_duedate;           -- CR4479
--CR4184 Starts
                     --                      l_running_duedate := calc_apdm_reg_card_dd (
                     --                      l_running_duedate, l_ann, l_dmpp);
                     --                   l_running_duedate := calc_apdm_reg_card_dd (p_esn,l_running_duedate, l_ann, l_dmpp);
                        l_running_duedate :=
                           calc_apdm_reg_card_dd (p_esn,
                                                  l_running_duedate,
                                                  l_ann,
                                                  l_dmpp,
                                                  p_promo_days
                                                 );
--CR4392
                  --CR4184 Ends
                   -- CR4479 Start
                         IF ( l_running_duedate - l_prev_due_date > l_max_days ) THEN
                            l_max_days := l_running_duedate - l_prev_due_date;
                         END IF;
                   -- CR4479 End

                     END LOOP;
                  END IF;
               END IF;

               /* Process Annual Cards here */
               l_step := 'Stack Annual Cards for Non-Annual Plan Customers';

               IF l_ann > 0
               THEN
                  FOR j IN 1 .. l_ann
                  LOOP
--                  l_running_duedate := calc_365_card_dd (l_running_duedate);
                     l_running_duedate :=
                           calc_365_card_dd (l_running_duedate, p_promo_days);
--CR4392
              END LOOP;
           l_max_days := 365; -- Annual Card CR4479

               END IF;

               /* Process DMPP Cards here */
               l_step :=
                     'Stack Double Minute Cards for Non-Annual Plan Customers';

               IF l_dmpp > 0
               THEN
                  FOR j IN 1 .. l_dmpp
                  LOOP
--                  l_running_duedate := calc_365_card_dd (l_running_duedate);
                     l_running_duedate :=
                           calc_365_card_dd (l_running_duedate, p_promo_days);
--CR4392
                  END LOOP;
               l_max_days := 365; -- Annual Card CR4479
                  l_step :=
                     'Update Double Minute Due Date for Non-Annual Plan Customers';
                  l_dmdd_date := SYSDATE + 365 * g_dmpp_card_tab.COUNT;

                  IF NOT put_dmpp_info (p_esn,
                                        'RG',
                                        l_dmdd_date,
                                        p_sourcesystem
                                       )
                  --CR3181
                  THEN
                     p_status := 'F';
                     p_msg :=
                           'Failed to update Double Minute Due Date Non-Annual Plan Customers '
                        || SUBSTR (SQLERRM, 1, 100);
                     RETURN;
                  END IF;
               END IF;

               IF NOT is_ae_esn (p_esn)
               THEN
                  IF p_trans_type IN ('ACTIVATION', 'REACTIVATION')
                  THEN
                     IF    (l_ann = 1 AND l_dmpp = 0)
                        OR (l_ann = 0 AND l_dmpp = 1)
                     THEN
                        l_running_duedate := SYSDATE + 365;
                     END IF;
                  END IF;
               END IF;
            ELSIF p_esn_type IN ('AC', 'AE')
            THEN
               /* Process Non-Annual Cards here */
               l_step := 'Stack Non-Annual Cards for Annual Plan Customers';

               IF l_non_ann > 0
               THEN
                  FOR j IN 1 .. l_non_ann
                  LOOP
                  l_prev_due_date := l_running_duedate;           -- CR4479
--CR4184 Starts
                  --                   l_running_duedate := calc_apdm_reg_card_dd (l_running_duedate
                  --                   , l_ann, l_dmpp);
                  --                   l_running_duedate := calc_apdm_reg_card_dd (p_esn,l_running_duedate, l_ann, l_dmpp);
                     l_running_duedate :=
                        calc_apdm_reg_card_dd (p_esn,
                                               l_running_duedate,
                                               l_ann,
                                               l_dmpp,
                                               p_promo_days
                                              );
--CR4392
               --CR4184 Ends
                 -- CR4479 Start
                     IF ( l_running_duedate - l_prev_due_date > l_max_days ) THEN
                        l_max_days := l_running_duedate - l_prev_due_date;
                     END IF;
                  -- CR4479 End

                  END LOOP;
               END IF;

               /* Process Annual Cards here */
               l_step := 'Stack Annual Cards for Annual Plan Customers';

               IF l_ann > 0
               THEN
                  FOR j IN 1 .. l_ann
                  LOOP
--                  l_running_duedate := calc_365_card_dd (l_running_duedate);
                     l_running_duedate :=
                           calc_365_card_dd (l_running_duedate, p_promo_days);
--CR4392
                  END LOOP;
                  l_max_days := 365; -- Annual Card CR4479
               END IF;


               /* Process DMPP Cards here */
               l_step := 'Stack Double Minute Cards for Annual Plan Customers';

               IF l_dmpp > 0
               THEN
                  FOR j IN 1 .. l_dmpp
                  LOOP
--                  l_running_duedate := calc_365_card_dd (l_running_duedate);
                     l_running_duedate :=
                           calc_365_card_dd (l_running_duedate, p_promo_days);
--CR4392
                  END LOOP;
				l_max_days := 365; -- Annual Card CR4479

                  l_step :=
                     'Update Double Minute Due Date for Annual Plan Customers';

                  IF p_esn_type = 'AC' AND is_ap_trans_sameday (p_esn)
                  THEN
                     IF NOT put_dmpp_info (p_esn,
                                           'AC',
                                           l_curr_due_date,
                                           p_sourcesystem
                                          )                           --CR3181
                     THEN
                        p_status := 'F';
                        p_msg :=
                              'Failed to update Double Minute Due Date for Annual Plan Customers '
                           || SUBSTR (SQLERRM, 1, 100);
                        RETURN;
                     END IF;
                  ELSIF p_esn_type = 'AE'
                  THEN
                     l_dmdd_date := SYSDATE + 365 * g_dmpp_card_tab.COUNT;

                     IF NOT put_dmpp_info (p_esn,
                                           'AE',
                                           l_dmdd_date,
                                           p_sourcesystem
                                          )                           --CR3181
                     THEN
                        p_status := 'F';
                        p_msg :=
                              'Failed to update Double Minute Due Date for Allow Stacking Customers  '
                           || SUBSTR (SQLERRM, 1, 100);
                        RETURN;
                     END IF;
                  END IF;
               END IF;
            /* Process for DM cards */
            ELSIF p_esn_type = 'DM'
            THEN
               /* Process Non-Annual Cards here */
               l_step := 'Stack Non-Annual Cards for Double Minute Customers';

               IF l_non_ann > 0
               THEN
                  FOR j IN 1 .. l_non_ann
                  LOOP
	l_prev_due_date := l_running_duedate;           -- CR4479
--CR4184 Starts
                  --                   l_running_duedate := calc_apdm_reg_card_dd (l_running_duedate
                  --                   , l_ann, l_dmpp);
                  --                   l_running_duedate := calc_apdm_reg_card_dd (p_esn,l_running_duedate, l_ann, l_dmpp);
                     l_running_duedate :=
                        calc_apdm_reg_card_dd (p_esn,
                                               l_running_duedate,
                                               l_ann,
                                               l_dmpp,
                                               p_promo_days
                                              );
--CR4392
               --CR4184 Ends
                  -- CR4479 Start
                     IF ( l_running_duedate - l_prev_due_date > l_max_days ) THEN
                        l_max_days := l_running_duedate - l_prev_due_date;
                     END IF;
                  -- CR4479 End

                  END LOOP;
               END IF;

               /* Process Annual Cards here */
               l_step := 'Stack Annual Cards for Double Minute Customers';

               IF l_ann > 0
               THEN
                  FOR j IN 1 .. l_ann
                  LOOP
--                  l_running_duedate := calc_365_card_dd (l_running_duedate);
                     l_running_duedate :=
                           calc_365_card_dd (l_running_duedate, p_promo_days);
--CR4392
                  END LOOP;
                  l_max_days := 365; -- Annual Card CR4479
               END IF;

               /* Process for DMPP Cards here */
               l_step :=
                       'Stack Double Minute Cards for Double Minute Customers';

               IF l_dmpp > 0
               THEN
                  FOR j IN 1 .. l_dmpp
                  LOOP
--                  l_running_duedate := calc_365_card_dd (l_running_duedate);
                     l_running_duedate :=
                           calc_365_card_dd (l_running_duedate, p_promo_days);
--CR4392
                  END LOOP;
				  l_max_days := 365; -- Annual Card CR4479
                  l_step :=
                     'Update Double Minute Due Date for Double Minute Customers';

                  IF NOT put_dmpp_info (p_esn,
                                        'DM',
                                        l_running_duedate,
                                        p_sourcesystem
                                       )                              --CR3181
                  THEN
                     p_status := 'F';
                     p_msg :=
                           'Failed to update Double Minute Due Date for Double Minute Customers '
                        || SUBSTR (SQLERRM, 1, 100);
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;                                        --NET10 Check (CR3190)
      END IF;                                                         --CR5484

      l_running_duedate := l_running_duedate + l_promo_card_days;     --CR3945
      p_status := 'S';
      p_msg := 'Success';

     --CR5625 Start
--        --02/19/04 Change
--       /* Assign the final Due Date to return*/
--       IF l_running_duedate < l_curr_due_date
--       THEN
--          p_new_due_date := TO_CHAR (l_curr_due_date, 'mm/dd/yyyy hh24:mi:ss');
--       ELSE
--          p_new_due_date :=
--                          TO_CHAR (l_running_duedate, 'mm/dd/yyyy hh24:mi:ss');
--       END IF;
--    --End 02/19/04 Change

	  -- CR7485 BEGIN
      IF l_running_duedate < l_curr_due_date
      THEN
         IF l_extend_flag = 1
         THEN
--cr7485
            IF l_curr_due_date BETWEEN TO_DATE(TO_CHAR(l_param_start_date,'ddmon')||
                                                       TO_CHAR(l_curr_due_date,'yyyy'),'ddmonyyyy')
                                   AND TO_DATE(TO_CHAR(l_param_end_date,'ddmon')||
                                       TO_CHAR(l_curr_due_date,'yyyy'),'ddmonyyyy')
/*
--cr7485
            IF l_curr_due_date BETWEEN l_param_start_date AND l_param_end_date
*/
            THEN
               l_curr_due_date := l_curr_due_date + l_param_days;
            ELSE
               l_curr_due_date := l_curr_due_date;
            END IF;
         ELSE
            l_curr_due_date := l_curr_due_date;
         END IF;

         p_new_due_date := TO_CHAR (l_curr_due_date, 'mm/dd/yyyy hh24:mi:ss');
      ELSE
         IF l_extend_flag = 1
         THEN
--cr7485
            IF l_running_duedate BETWEEN TO_DATE(TO_CHAR(l_param_start_date,'ddmon')||
                                                       TO_CHAR(l_running_duedate,'yyyy'),'ddmonyyyy')
                                   AND TO_DATE(TO_CHAR(l_param_end_date,'ddmon')||
                                       TO_CHAR(l_running_duedate,'yyyy'),'ddmonyyyy')
/*
--cr7485
            IF l_running_duedate BETWEEN l_param_start_date AND l_param_end_date
*/
            THEN
               l_running_duedate := l_running_duedate + l_param_days;
            ELSE
               l_running_duedate := l_running_duedate;
            END IF;
         ELSE
            l_running_duedate := l_running_duedate;
         END IF;

         p_new_due_date :=
                          TO_CHAR (l_running_duedate, 'mm/dd/yyyy hh24:mi:ss');
      END IF;

	  -- CR7485 END
      -- CR5625 End
      --- Billing Platform Changes - CR4479
      l_stacking_policy := Billing_Getmaxstackpolicy ( p_esn );

      IF ( l_stacking_policy = 'FULL' ) THEN
            NULL;
            -- No need to change anything. Existing p_new_due_date computes based on FULL Stacking.
      ELSIF ( l_stacking_policy = 'GAP' ) THEN
            -- Compute the max days given by the redemption cards entered.
            /*
            p_new_due_date := TO_CHAR ( l_curr_due_date + l_promo_card_days + l_max_days, 'mm/dd/yyyy hh24:mi:ss');
            -- Get the max days offered by any of the cards.
            */
            -- As per discussion, in GAP Stacking, the no. of days to be given is "current_date" + max. days given by the card.
--            p_new_due_date := TO_CHAR( GREATEST(l_curr_due_date, sysdate+NVL(l_promo_card_days,0) + NVL(l_max_days,0)) , 'mm/dd/yyyy hh24:mi:ss');
              l_running_duedate := GREATEST( SYSDATE + l_promo_card_days + l_max_days, l_curr_due_date);
              p_new_due_date := TO_CHAR ( l_running_duedate , 'mm/dd/yyyy hh24:mi:ss');
      ELSIF ( l_stacking_policy = 'NO' ) THEN
            -- No stacking permitted. No change in the expiry date. Return existing expiry date.
            p_new_due_date := p_curr_due_date;
      END IF;

      --- Billing Platform Changes - END
   EXCEPTION
      WHEN OTHERS
      THEN
         p_new_due_date :=
                         TO_CHAR (l_running_duedate, 'mm/dd/yyyy hh24:mi:ss');
         p_status := 'F';
         p_msg :=
               'Failed at step : '
            || l_step
            || ' due to '
            || SUBSTR (SQLERRM, 1, 100);
         RETURN;
   END main;

   --
   FUNCTION calc_reg_card_dd (
      p_esn              IN   VARCHAR2,                               --CR4184
      p_curr_expy_date   IN   DATE,
      p_ann_card_cnt     IN   NUMBER,
      p_dmpp_card_cnt    IN   NUMBER,
      p_promo_days       IN   NUMBER                                  --CR4392
   )
      RETURN DATE
   IS
      p_due_date           DATE;
      --CR4184 Starts
      l_days_multiplier    NUMBER := 1;
      l_stack_multiplier   NUMBER := 1;
      --CR4184 Ends
      l_promo_expy_date    DATE;
--CR4392
   BEGIN
      l_promo_expy_date := p_curr_expy_date + NVL (p_promo_days, 0); --CR4392
      get_stackdays_multiplier (p_esn, l_days_multiplier, l_stack_multiplier);

      --CR4184

      --If there are any annual plan cards or double minute prepaid plan cards, do not include non-annual plan cards in due_date calculation
      IF p_ann_card_cnt > 0 OR p_dmpp_card_cnt > 0
      THEN
         p_due_date := p_curr_expy_date;
      ELSE
--CR5702-2 Start
         IF (p_curr_expy_date - SYSDATE) < (60 * l_stack_multiplier)
         THEN
            p_due_date :=
               LEAST ((p_curr_expy_date + (60 * l_days_multiplier)),
                      (SYSDATE + 180 * l_days_multiplier
                      )
                     );
         ELSE
            IF (p_curr_expy_date - SYSDATE) > (180 * l_stack_multiplier)
            THEN
               p_due_date := p_curr_expy_date;
            ELSE
               p_due_date :=
                  LEAST ((p_curr_expy_date + (60 * l_days_multiplier)),
                         (SYSDATE + 180 * l_days_multiplier
                         )
                        );
            END IF;
         END IF;
      END IF;

--CR5702-2 End
-- --         IF (p_curr_expy_date - SYSDATE) < 60
--          --         IF ((p_curr_expy_date - SYSDATE) < (60 * l_stack_multiplier) --CR4184
--          IF (l_promo_expy_date - SYSDATE) <
--                                            (60 * l_stack_multiplier
--                                            )                          --CR4392
--          THEN
-- --            p_due_date := p_curr_expy_date + 60;
--             --            p_due_date := p_curr_expy_date + (60 * l_days_multiplier);
--             p_due_date := l_promo_expy_date + (60 * l_days_multiplier);
-- --CR4392
--          --CR4184
--          ELSE
--             --CR5197 start
-- --             IF (l_promo_expy_date - SYSDATE) >
-- --                                           (120 * l_stack_multiplier
-- --                                           )                           --CR4392
--             IF (l_promo_expy_date - SYSDATE) >
--                                           (180 * l_stack_multiplier
--                                           )                           --CR5702
--             THEN
--                p_due_date := p_curr_expy_date;
--             ELSE
-- --            p_due_date := SYSDATE + 120;
-- --               p_due_date := SYSDATE + (120 * l_stack_multiplier);
--                p_due_date := SYSDATE + (180 * l_stack_multiplier);   --CR5702
--             END IF;
--          END IF;
      --CR5197 End
--      END IF;

      --Revision 1.8
      --      RETURN p_due_date;
--CR6048
      IF NVL (p_promo_days, 0) <> 0
      THEN
         p_due_date := p_due_date + NVL (p_promo_days, 0);
      END IF;

--CR6048
      IF p_due_date > p_curr_expy_date
      THEN
         RETURN p_due_date;
      ELSE
         RETURN p_curr_expy_date;
      END IF;
   --Revision 1.8
   EXCEPTION
      WHEN OTHERS
      THEN
         p_due_date := p_curr_expy_date;
         RETURN p_due_date;
   END calc_reg_card_dd;

   --
   FUNCTION calc_apdm_reg_card_dd (
      p_esn              IN   VARCHAR2,                               --CR4184
      p_curr_expy_date   IN   DATE,
      p_ann_card_cnt     IN   NUMBER,
      p_dmpp_card_cnt    IN   NUMBER,
      p_promo_days       IN   NUMBER                                  --CR4392
   )
      RETURN DATE
   IS
      p_due_date           DATE;
      --CR4184 Starts
      l_days_multiplier    NUMBER := 1;
      l_stack_multiplier   NUMBER := 1;
      --CR4184 Ends
      l_promo_expy_date    DATE;
--CR4392
   BEGIN
      l_promo_expy_date := p_curr_expy_date + NVL (p_promo_days, 0); --CR4392
      get_stackdays_multiplier (p_esn, l_days_multiplier, l_stack_multiplier);
      --CR4184
      DBMS_OUTPUT.put_line ('l_days_multiplier ' || l_days_multiplier);
      DBMS_OUTPUT.put_line ('l_stack_multiplier ' || l_stack_multiplier);

      --If there are any annual plan cards or double minute prepaid plan cards, do not include non-annual plan cards in due_date calculation
      IF p_ann_card_cnt > 0 OR p_dmpp_card_cnt > 0
      THEN
         p_due_date := p_curr_expy_date;
--CR5702-2 Start
      ELSE
         IF (p_curr_expy_date - SYSDATE) > (180 * l_stack_multiplier)
         THEN
            p_due_date := p_curr_expy_date;
         ELSE
            p_due_date :=
               LEAST ((p_curr_expy_date + (60 * l_days_multiplier)),
                      (SYSDATE + 180 * l_days_multiplier
                      )
                     );
         END IF;
      END IF;

-- --         IF (p_curr_expy_date - SYSDATE) < 60
--          --         IF (p_curr_expy_date - SYSDATE) < (60 * l_stack_multiplier) --CR4184
--          IF (l_promo_expy_date - SYSDATE) <
--                                            (60 * l_stack_multiplier
--                                            )                          --CR4392
--          THEN
-- --            p_due_date := p_curr_expy_date + 60;
--             --            p_due_date := p_curr_expy_date + (60 * l_days_multiplier);
--             p_due_date := l_promo_expy_date + (60 * l_days_multiplier);
-- --CR4392
--          --CR4184
--          ELSE
-- --            IF (p_curr_expy_date - SYSDATE) > 120
--             --            IF (p_curr_expy_date - SYSDATE) > (120 * l_stack_multiplier) --CR4184
-- --             IF (l_promo_expy_date - SYSDATE) >
-- --                                           (120 * l_stack_multiplier
-- --                                           )                           --CR4392
--             IF (l_promo_expy_date - SYSDATE) >
--                                           (180 * l_stack_multiplier
--                                           )                           --CR5702
--             THEN
--                p_due_date := p_curr_expy_date;
--             ELSE
-- /* It is between 60 and 120 - No Action*/
--                --            p_due_date := SYSDATE + 120;
-- --               p_due_date := SYSDATE + (120 * l_stack_multiplier);
-- --CR4184
--                p_due_date := SYSDATE + (180 * l_stack_multiplier);   --CR5702
--             END IF;
--          END IF;
--      END IF;
--CR6048
--CR5702-2 End
      --CR5141 start
      IF NVL (p_promo_days, 0) <> 0
      THEN
         p_due_date := p_due_date + p_promo_days;
      END IF;

--
--       --CR5141 end
--CR6048
      RETURN p_due_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_due_date := p_curr_expy_date;
         RETURN p_due_date;
   END calc_apdm_reg_card_dd;

   --
   FUNCTION calc_365_card_dd (
      p_curr_expy_date   IN   DATE,
      p_promo_days       IN   NUMBER                                  --CR4392
   )
      RETURN DATE
   IS
      p_due_date          DATE;
      l_promo_expy_date   DATE;
--CR4392
   BEGIN
      l_promo_expy_date := p_curr_expy_date + NVL (p_promo_days, 0); --CR4392
      --      p_due_date := LEAST ((p_curr_expy_date + 365), (SYSDATE + 730));
      p_due_date := LEAST ((l_promo_expy_date + 365), (SYSDATE + 730));
      --CR4392
      RETURN p_due_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_due_date := p_curr_expy_date;
         RETURN p_due_date;
   END calc_365_card_dd;

   --
   --CR3190 Start
   FUNCTION calc_net10_dd (
      p_esn              IN   VARCHAR2,                               --CR4282
      p_curr_expy_date   IN   DATE,
      p_access_days      IN   NUMBER,
      p_units            IN   NUMBER                                 -- CR4282
   )
      RETURN DATE
   IS
      p_due_date          DATE;
      p_running_date      DATE;
      l_days_multiplier   NUMBER := 1;
   BEGIN
--CR4282 Start
      get_net10days_multiplier (p_esn,
                                p_units,
                                p_access_days,
                                l_days_multiplier
                               );
      --      p_running_date := SYSDATE + p_access_days;
      p_running_date := SYSDATE + (p_access_days * l_days_multiplier);

      --CR4282 End
      IF p_running_date > p_curr_expy_date
      THEN
         p_due_date := p_running_date;
      ELSE
         p_due_date := p_curr_expy_date;
      END IF;

      RETURN p_due_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_due_date := p_curr_expy_date;
         RETURN p_due_date;
   END calc_net10_dd;

--CR5848
   FUNCTION calc_nolimit_dd (
      p_esn              IN   VARCHAR2,
      p_curr_expy_date   IN   DATE,
      p_access_days      IN   NUMBER,
      p_promo_days       IN   NUMBER
   )
      RETURN DATE
   IS
      p_due_date          DATE;
      p_running_date      DATE;
      l_promo_expy_date   DATE;
   BEGIN
      l_promo_expy_date := p_curr_expy_date + NVL (p_promo_days, 0);
      p_running_date := l_promo_expy_date + p_access_days;

      IF p_running_date > p_curr_expy_date
      THEN
         p_due_date := p_running_date;
      ELSE
         p_due_date := p_curr_expy_date;
      END IF;

      RETURN p_due_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_due_date := p_curr_expy_date;
         RETURN p_due_date;
   END calc_nolimit_dd;

--CR5848
   --CR3190 End
   FUNCTION put_dmpp_info (
      p_esn              IN   VARCHAR2,
      p_esn_type         IN   VARCHAR2,
      p_curr_expy_date   IN   DATE,
      p_sourcesystem     IN   VARCHAR2                                --CR3181
   )
      RETURN BOOLEAN
   IS
      CURSOR c_get_group2esn
      IS
         SELECT g2esn.objid, g2esn.x_start_date, g2esn.x_end_date
           FROM TABLE_PART_INST pi,
                TABLE_X_GROUP2ESN g2esn,
                TABLE_X_PROMOTION_MTM MTM,
                TABLE_X_PROMOTION pr
          WHERE pr.objid = MTM.x_promo_mtm2x_promotion
            AND MTM.x_promo_mtm2x_promo_group = g2esn.groupesn2x_promo_group
            AND g2esn.groupesn2part_inst = pi.objid
            AND SYSDATE BETWEEN g2esn.x_start_date AND g2esn.x_end_date
            -- CR16379 Start kacosta 03/12/2012
            --AND pr.x_promo_code || '' = 'RTDBL000'                      --1.18
            AND pr.x_promo_code IN ('RTDBL000','RTX3X000')
            -- CR16379 End kacosta 03/12/2012
            AND pi.part_serial_no = p_esn;

      r_get_group2esn    c_get_group2esn%ROWTYPE;
      l_ap_remain_days   NUMBER                    := 0;
      l_dmpp_due_date    DATE;
      l_result           NUMBER                    := 0;
      l_msg              VARCHAR2 (200);
   BEGIN
      OPEN c_get_group2esn;

      FETCH c_get_group2esn
       INTO r_get_group2esn;

      IF c_get_group2esn%FOUND
      THEN
         IF p_esn_type = 'AC'
         THEN
            l_ap_remain_days := p_curr_expy_date - SYSDATE;
            l_dmpp_due_date :=
               LEAST (r_get_group2esn.x_end_date + l_ap_remain_days,
                      SYSDATE + 730
                     );
         ELSIF p_esn_type IN ('RG', 'AE')
         THEN
            l_dmpp_due_date := LEAST (p_curr_expy_date, SYSDATE + 730);
         ELSE
            l_dmpp_due_date :=
                 LEAST ((r_get_group2esn.x_end_date + 365), (SYSDATE + 730));
         END IF;
      ELSE
         CLOSE c_get_group2esn;

         IF Get_Dblmin_Usage_Fun (p_esn, 'RTDBL000', 0, 'YES') = 0
         THEN
            Sp_Insert_Group2esn (p_esn,
                                 'RTDBL000',
                                 p_sourcesystem,
                                 l_result,
                                 l_msg
                                );                                    --CR3181

            OPEN c_get_group2esn;

            FETCH c_get_group2esn
             INTO r_get_group2esn;

            CLOSE c_get_group2esn;

            IF l_result = 0
            THEN
               IF p_esn_type = 'AC'
               THEN
                  l_ap_remain_days := p_curr_expy_date - SYSDATE;
                  l_dmpp_due_date :=
                     LEAST (r_get_group2esn.x_end_date + l_ap_remain_days,
                            SYSDATE + 730
                           );
               ELSIF p_esn_type IN ('RG', 'AE')
               THEN
                  l_dmpp_due_date := LEAST (p_curr_expy_date, SYSDATE + 730);
               ELSE
                  l_dmpp_due_date :=
                      LEAST (r_get_group2esn.x_end_date + 365, SYSDATE + 730);
               END IF;
            END IF;
         END IF;
         --
         -- CR16379 Start kacosta 03/12/2012
         IF get_dblmin_usage_fun(ip_esn        => p_esn
                                ,ip_promocode  => 'RTX3X000'
                                ,ip_promounits => 0
                                ,ip_chkpromo   => 'YES') = 0 THEN
           --
           sp_insert_group2esn(ip_esn       => p_esn
                              ,ip_promocode => 'RTX3X000'
                              ,ip_source    => p_sourcesystem
                              ,op_result    => l_result
                              ,op_msg       => l_msg);
           --
           OPEN c_get_group2esn;
           FETCH c_get_group2esn
             INTO r_get_group2esn;
           CLOSE c_get_group2esn;
           --
           IF l_result = 0 THEN
             --
             IF p_esn_type = 'AC' THEN
               --
               l_ap_remain_days := p_curr_expy_date - SYSDATE;
               l_dmpp_due_date  := LEAST(r_get_group2esn.x_end_date + l_ap_remain_days
                                        ,SYSDATE + 730);
               --
             ELSIF p_esn_type IN ('RG'
                                 ,'AE') THEN
               --
               l_dmpp_due_date := LEAST(p_curr_expy_date
                                       ,SYSDATE + 730);
               --
             ELSE
               --
               l_dmpp_due_date := LEAST(r_get_group2esn.x_end_date + 365
                                       ,SYSDATE + 730);
               --
             END IF;
             --
           END IF;
           --
         END IF;
         -- CR16379 End kacosta 03/12/2012
         --
      END IF;

      UPDATE TABLE_X_GROUP2ESN
         SET x_end_date = l_dmpp_due_date
       WHERE objid = r_get_group2esn.objid;

      IF c_get_group2esn%ISOPEN
      THEN
         CLOSE c_get_group2esn;
      END IF;

      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN FALSE;
   END put_dmpp_info;

   --
   PROCEDURE get_red_card_info (p_card_rec IN OUT red_card_rec_t)
   IS
      v_card_rec   red_card_rec_t;
   BEGIN
      v_card_rec := p_card_rec;

      SELECT pi.x_red_code,
             pn.x_redeem_units,
             pn.x_redeem_days,
             pn.part_number,
             pn.x_card_type,
             pn.part_type,
             pr.x_promo_code,
             bo.org_id
        INTO p_card_rec
        FROM TABLE_PART_INST pi,
             TABLE_MOD_LEVEL ml,
             TABLE_PART_NUM pn,
             TABLE_X_PROMOTION pr,
             TABLE_BUS_ORG bo
       WHERE pi.x_red_code = p_card_rec.red_code
         AND pi.n_part_inst2part_mod = ml.objid
         AND pi.x_domain = 'REDEMPTION CARDS'
         AND ml.part_info2part_num = pn.objid
         AND bo.OBJID = pn.part_num2bus_org
         AND pn.domain = 'REDEMPTION CARDS'
         AND pn.part_num2x_promotion = pr.objid(+);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_card_rec := v_card_rec;
   END get_red_card_info;

   FUNCTION is_ap_trans_sameday (p_esn IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_trans_date   DATE;
   BEGIN
      SELECT x_transact_date
        INTO l_trans_date
        FROM TABLE_X_CALL_TRANS ct, TABLE_X_RED_CARD rc
       WHERE ct.objid = rc.red_card2call_trans
         AND rc.x_access_days = 365
         AND NOT EXISTS (
                SELECT 1
                  FROM TABLE_X_PROMO_HIST PH, TABLE_X_PROMOTION pr
                 WHERE PH.promo_hist2x_call_trans = ct.objid
                   AND PH.promo_hist2x_promotion = pr.objid
                   -- CR16379 Start kacosta 03/12/2012
                   --AND pr.x_promo_code || '' = 'RTDBL000')              --1.18
                   AND pr.x_promo_code IN ('RTDBL000','RTX3X000'))
                   -- CR16379 End kacosta 03/12/2012
         AND ct.x_service_id = p_esn;

      IF TRUNC (l_trans_date) = TRUNC (SYSDATE)
      THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_ap_trans_sameday;

   FUNCTION is_ae_esn (p_esn IN VARCHAR2)
      RETURN BOOLEAN
   IS
      CURSOR c_esn_promo
      IS
         SELECT pr.x_promo_code
           FROM TABLE_PART_INST pi,
                TABLE_MOD_LEVEL ml,
                TABLE_PART_NUM pn,
                TABLE_X_PROMOTION pr
          WHERE pr.objid = pn.part_num2x_promotion
            AND pn.objid = ml.part_info2part_num
            AND ml.objid = pi.n_part_inst2part_mod
            AND pi.part_serial_no = p_esn
            AND pr.x_allow_stacking = 1;

      r_esn_promo       c_esn_promo%ROWTYPE;

      CURSOR c_get_group2esn (p_promo_code IN VARCHAR2)
      IS
         SELECT g2esn.x_start_date, g2esn.x_end_date
           FROM TABLE_PART_INST pi,
                TABLE_X_GROUP2ESN g2esn,
                TABLE_X_PROMOTION_MTM MTM,
                TABLE_X_PROMOTION pr
          WHERE pr.objid = MTM.x_promo_mtm2x_promotion
            AND MTM.x_promo_mtm2x_promo_group = g2esn.groupesn2x_promo_group
            AND g2esn.groupesn2part_inst = pi.objid
            AND pr.x_promo_code = p_promo_code
            AND pi.part_serial_no = p_esn;

      r_get_group2esn   c_get_group2esn%ROWTYPE;
      l_true            NUMBER;
      l_start_date      DATE;
   BEGIN
      OPEN c_esn_promo;

      FETCH c_esn_promo
       INTO r_esn_promo;

      IF c_esn_promo%NOTFOUND
      THEN
         CLOSE c_esn_promo;

         RETURN FALSE;
      ELSE
         OPEN c_get_group2esn (r_esn_promo.x_promo_code);

         FETCH c_get_group2esn
          INTO r_get_group2esn;

         IF c_get_group2esn%NOTFOUND
         THEN
            CLOSE c_get_group2esn;

            RETURN FALSE;
         ELSE
            IF SYSDATE BETWEEN r_get_group2esn.x_start_date
                           AND r_get_group2esn.x_end_date
            THEN
               RETURN TRUE;
            ELSE
               RETURN FALSE;
            END IF;
         END IF;
      END IF;

      CLOSE c_esn_promo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_ae_esn;

   --
   --CR4184 Starts
   PROCEDURE get_stackdays_multiplier (
      p_esn                IN       VARCHAR2,
      p_days_multiplier    OUT      NUMBER,
      p_stack_multiplier   OUT      NUMBER
   )
   IS
      CURSOR c_get_multiplier
      IS
         SELECT pg.x_multiplier, pg.x_stack_multiplier
           FROM TABLE_X_PROMOTION pr,
                TABLE_X_PROMOTION_MTM MTM,
                TABLE_X_PROMOTION_GROUP pg,
                TABLE_X_GROUP2ESN gesn,
                TABLE_PART_INST pi
          WHERE gesn.groupesn2part_inst = pi.objid
            AND gesn.groupesn2x_promo_group = pg.objid
            AND MTM.x_promo_mtm2x_promo_group = pg.objid
            AND MTM.x_promo_mtm2x_promotion = pr.objid
            AND SYSDATE BETWEEN gesn.x_start_date
                            AND NVL (gesn.x_end_date, SYSDATE + 1)
            AND pi.part_serial_no = p_esn;

      r_get_multiplier        c_get_multiplier%ROWTYPE;

      CURSOR c_get_mult_from_group
      IS
         SELECT pg.x_multiplier, pg.x_stack_multiplier
           FROM TABLE_X_PROMOTION_GROUP pg,
                TABLE_X_GROUP2ESN gesn,
                TABLE_PART_INST pi
          WHERE gesn.groupesn2part_inst = pi.objid
            AND gesn.groupesn2x_promo_group = pg.objid
            AND SYSDATE BETWEEN gesn.x_start_date
                            AND NVL (gesn.x_end_date, SYSDATE + 1)
            AND pi.part_serial_no = p_esn;

      r_get_mult_from_group   c_get_mult_from_group%ROWTYPE;
      l_days_mult_previous    NUMBER                          := 1;
      l_stack_mult_previous   NUMBER                          := 1;
      l_mtm_flag              NUMBER                          := 0;
   BEGIN
      OPEN c_get_multiplier;

      FETCH c_get_multiplier
       INTO r_get_multiplier;

      IF c_get_multiplier%FOUND
      THEN
         l_days_mult_previous := NVL (r_get_multiplier.x_multiplier, 1);
         l_stack_mult_previous :=
                                 NVL (r_get_multiplier.x_stack_multiplier, 1);
         l_mtm_flag := 1;
      ELSE
         l_mtm_flag := 0;

         OPEN c_get_mult_from_group;

         FETCH c_get_mult_from_group
          INTO r_get_mult_from_group;

         IF c_get_mult_from_group%FOUND
         THEN
            l_days_mult_previous :=
                                  NVL (r_get_mult_from_group.x_multiplier, 1);
            l_stack_mult_previous :=
                            NVL (r_get_mult_from_group.x_stack_multiplier, 1);
         ELSE
            l_days_mult_previous := 1;
            l_stack_mult_previous := 1;
         END IF;

         CLOSE c_get_mult_from_group;
      END IF;

      CLOSE c_get_multiplier;

      IF l_mtm_flag = 1
      THEN
         FOR r_get_multiplier IN c_get_multiplier
         LOOP
            IF    NVL (r_get_multiplier.x_multiplier, 1) >
                                                         l_days_mult_previous
               OR NVL (r_get_multiplier.x_stack_multiplier, 1) >
                                                         l_stack_mult_previous
            THEN
               l_days_mult_previous := NVL (r_get_multiplier.x_multiplier, 1);
               l_stack_mult_previous :=
                                 NVL (r_get_multiplier.x_stack_multiplier, 1);
            END IF;
         END LOOP;
      ELSIF l_mtm_flag = 0
      THEN
         FOR r_get_mult_from_group IN c_get_mult_from_group
         LOOP
            IF    NVL (r_get_mult_from_group.x_multiplier, 1) >
                                                         l_days_mult_previous
               OR NVL (r_get_mult_from_group.x_stack_multiplier, 1) >
                                                         l_stack_mult_previous
            THEN
               l_days_mult_previous :=
                                  NVL (r_get_mult_from_group.x_multiplier, 1);
               l_stack_mult_previous :=
                            NVL (r_get_mult_from_group.x_stack_multiplier, 1);
            END IF;
         END LOOP;
      ELSE
         l_days_mult_previous := 1;
         l_stack_mult_previous := 1;
      END IF;

      p_days_multiplier := l_days_mult_previous;
      p_stack_multiplier := l_stack_mult_previous;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_days_multiplier := 1;
         p_stack_multiplier := 1;
   END get_stackdays_multiplier;

   --CR4184 Ends
   --CR4282 Starts
   PROCEDURE get_net10days_multiplier (
      p_esn               IN       VARCHAR2,
      p_units             IN       NUMBER,
      p_days              IN       NUMBER,
      p_days_multiplier   OUT      NUMBER
   )
   IS
      CURSOR c_get_days_mult (ip_group_name IN VARCHAR2)
      IS
         SELECT pg.x_multiplier
           FROM TABLE_X_PROMOTION_GROUP pg,
                TABLE_X_GROUP2ESN gesn,
                TABLE_PART_INST pi
          WHERE gesn.groupesn2part_inst = pi.objid
            AND gesn.groupesn2x_promo_group = pg.objid
            AND group_name || '' = ip_group_name                        --1.18
            AND SYSDATE BETWEEN gesn.x_start_date
                            AND NVL (gesn.x_end_date, SYSDATE + 1)
            AND pi.part_serial_no = p_esn;

      r_get_days_mult     c_get_days_mult%ROWTYPE;

      CURSOR c_get_days_mult_1
      IS
         SELECT pg.x_multiplier
           FROM TABLE_X_PROMOTION_GROUP pg,
                TABLE_X_GROUP2ESN gesn,
                TABLE_PART_INST pi
          WHERE gesn.groupesn2part_inst = pi.objid
            AND gesn.groupesn2x_promo_group = pg.objid
            AND (    group_name LIKE 'NET10%GRP'
                 AND group_name NOT IN ('NET10_300_GRP', 'NET10_600_GRP')
                )
            AND SYSDATE BETWEEN gesn.x_start_date
                            AND NVL (gesn.x_end_date, SYSDATE + 1)
            AND pi.part_serial_no = p_esn;

      r_get_days_mult_1   c_get_days_mult_1%ROWTYPE;
      l_days_mult         NUMBER                      := 1;
   BEGIN
      IF p_units = 300
      THEN
         OPEN c_get_days_mult ('NET10_300_GRP');

         FETCH c_get_days_mult
          INTO r_get_days_mult;

         IF c_get_days_mult%FOUND AND p_days = 30
         THEN
            l_days_mult := NVL (r_get_days_mult.x_multiplier, 1);
         ELSE
            l_days_mult := 1;
         END IF;

         CLOSE c_get_days_mult;
      ELSIF p_units = 600
      THEN
         OPEN c_get_days_mult ('NET10_600_GRP');

         FETCH c_get_days_mult
          INTO r_get_days_mult;

         IF c_get_days_mult%FOUND AND p_days = 60
         THEN
            l_days_mult := NVL (r_get_days_mult.x_multiplier, 1);
         ELSE
            l_days_mult := 1;
         END IF;

         CLOSE c_get_days_mult;
      ELSE
         OPEN c_get_days_mult_1;

         FETCH c_get_days_mult_1
          INTO r_get_days_mult_1;

         IF c_get_days_mult_1%FOUND
         THEN
            l_days_mult := NVL (r_get_days_mult_1.x_multiplier, 1);
         ELSE
            l_days_mult := 1;
         END IF;

         CLOSE c_get_days_mult_1;

         FOR r_get_days_mult_1 IN c_get_days_mult_1
         LOOP
            IF NVL (r_get_days_mult_1.x_multiplier, 1) > l_days_mult
            THEN
               l_days_mult := NVL (r_get_days_mult_1.x_multiplier, 1);
            END IF;
         END LOOP;
      END IF;

      p_days_multiplier := l_days_mult;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_days_multiplier := 1;
   END get_net10days_multiplier;
--CR4282 Ends
END Stack_Duedate_Calc_Pkg;
/
CREATE OR REPLACE PROCEDURE sa."SP_INSERT_GROUP2ESN" (
 ip_esn IN VARCHAR2,
 ip_promocode IN VARCHAR2,
 ip_source IN VARCHAR2, --CR3181
 op_result OUT NUMBER, -- 0=SUCCESS,1=FAILURE
 op_msg OUT VARCHAR2
)
 /*****************************************************************
 Package Name: SA.sp_insert_group2esn
Description: Insert records into table_x_group2esn

Created by: Gerald Pintado
Date: 04/02/2003

History
-------------------------------------------------------------
04/02/03          GP                 Initial Release
04/10/03          SL                 Clarify Upgrade - sequence
08/27/04          VA                 CR3181 - Fix for DMPP Issue
                                      Insert '1' for x_annual_plan for redemptions done through
                                      technology channels (WEB and IVR)
01/06/05          VA                 CR3509 Changes - Double Minute Advantage Card
05/17/05          VA                 CR4000 Changes - Double Minute 3390 Card (PVCS Version 1.4)
11/09/06          VA              CR5759 Changes -  Buy 1 Get 1 free Promo
02/01/07          VA           CR5848 - Tracfone and Net10 Airtime Price Change
                            Allow new double minute enrollment for lifetime
*****************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SP_INSERT_GROUP2ESN.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/04/03 15:13:36 $
  --$ $Log: SP_INSERT_GROUP2ESN.sql,v $
  --$ Revision 1.2  2012/04/03 15:13:36  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
IS
   CURSOR c_get_promo_info
   IS
      SELECT a.objid promoobjid, a.x_revenue_type, a.x_units,
             a.x_access_days, b.x_promo_mtm2x_promo_group promogroupobjid
        FROM table_x_promotion a, table_x_promotion_mtm b
       WHERE a.x_promo_code = ip_promocode
         AND a.objid = b.x_promo_mtm2x_promotion;

   r_get_promo_info   c_get_promo_info%ROWTYPE;

   CURSOR c_get_esn_info
   IS
      SELECT a.objid esnobjid
        FROM table_part_inst a
       WHERE a.part_serial_no = ip_esn;

   CURSOR c_get_group2esn (c_esn_objid IN NUMBER, c_promo_grp_objid IN NUMBER)
   IS
      SELECT 'x'
        FROM table_x_group2esn
       WHERE groupesn2part_inst = c_esn_objid
         AND groupesn2x_promo_group = c_promo_grp_objid
         AND SYSDATE BETWEEN x_start_date AND x_end_date;

   r_get_group2esn    c_get_group2esn%ROWTYPE;
BEGIN
   op_result := 0;                                     -- 0=SUCCESS,1=FAILURE
   op_msg := 'SUCCESSFULLY COMPLETED';

   FOR r_get_esn_info IN c_get_esn_info
   LOOP
      OPEN c_get_promo_info;

      FETCH c_get_promo_info
       INTO r_get_promo_info;

      IF c_get_promo_info%NOTFOUND
      THEN
         CLOSE c_get_promo_info;

         op_result := 1;
         op_msg := 'ERROR - GETTING PROMOTION OBJID';
         RETURN;
      ELSE
         CLOSE c_get_promo_info;
      END IF;

      OPEN c_get_group2esn (r_get_esn_info.esnobjid,
                            r_get_promo_info.promogroupobjid
                           );

      FETCH c_get_group2esn
       INTO r_get_group2esn;

      IF c_get_group2esn%NOTFOUND
      THEN
--CR3181 Changes
         IF ip_source IN ('WEB', 'IVR')
         THEN
--CR5848
--             INSERT INTO table_x_group2esn
--                         (objid, x_annual_plan, groupesn2part_inst,
--                          groupesn2x_promo_group,
--                          groupesn2x_promotion,
--                          x_end_date,
--                          x_start_date
--                         )
--                  VALUES (
--                          --04/10/03 seq_x_group2esn.nextval + POWER (2, 28),
--                          sa.seq ('x_group2esn'), 1, r_get_esn_info.esnobjid,
--                          r_get_promo_info.promogroupobjid,
--                          r_get_promo_info.promoobjid,         --CR3509 Changes
--                          --              SYSDATE + DECODE(r_get_promo_info.x_access_days,0,365,r_get_promo_info.x_access_days),
--                          DECODE (ip_promocode,
--                                  'DBLMNAD000', TO_DATE
--                                                     ('12/31/2035 11:59:59 PM',
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),
--                                  '3390DBLMN', TO_DATE
--                                                     ('12/31/2035 11:59:59 PM',
--
--                                                      --CR4000
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),
--                                  'RTBY1GT000', TO_DATE
--                                                     ('12/31/2007 11:59:59 PM',
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),                --CR5759
--                                  (  SYSDATE
--                                   + DECODE (r_get_promo_info.x_access_days,
--                                             0, 365,
--                                             r_get_promo_info.x_access_days
--                                            )
--                                  )
--                                 ),
--                          --End CR3509 Changes
--                          SYSDATE
--                         );
            INSERT INTO table_x_group2esn
                        (objid, x_annual_plan, groupesn2part_inst,
                         groupesn2x_promo_group,
                         groupesn2x_promotion,
                         x_end_date,
                         x_start_date
                        )
                 VALUES (sa.seq ('x_group2esn'), 1, r_get_esn_info.esnobjid,
                         r_get_promo_info.promogroupobjid,
                         r_get_promo_info.promoobjid,
                         DECODE (ip_promocode,
                                 'RTBY1GT000', TO_DATE
                                                    ('12/31/2007 11:59:59 PM',
                                                     'MM/DD/YYYY HH:MI:SS AM'
                                                    ),
                                 TO_DATE ('12/31/2055 11:59:59 PM',
                                          'MM/DD/YYYY HH:MI:SS AM'
                                         )
                                ),
                         SYSDATE
                        );
--CR5848
         ELSE
--CR5848
-- End CR3181 Changes
--             INSERT INTO table_x_group2esn
--                         (objid, x_annual_plan, groupesn2part_inst,
--                          groupesn2x_promo_group,
--                          groupesn2x_promotion,
--                          x_end_date,
--                          x_start_date
--                         )
--                  VALUES (
--                          --04/10/03 seq_x_group2esn.nextval + POWER (2, 28),
--                          sa.seq ('x_group2esn'), 3, r_get_esn_info.esnobjid,
--                          r_get_promo_info.promogroupobjid,
--                          r_get_promo_info.promoobjid,         --CR3509 Changes
--                          --              SYSDATE + DECODE(r_get_promo_info.x_access_days,0,365,r_get_promo_info.x_access_days),
--                          DECODE (ip_promocode,
--                                  'DBLMNAD000', TO_DATE
--                                                     ('12/31/2035 11:59:59 PM',
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),
--                                  '3390DBLMN', TO_DATE
--                                                     ('12/31/2035 11:59:59 PM',
--
--                                                      --CR4000
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),
--                                  'RTBY1GT000', TO_DATE
--                                                     ('12/31/2007 11:59:59 PM',
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),                --CR5759
--                                  (  SYSDATE
--                                   + DECODE (r_get_promo_info.x_access_days,
--                                             0, 365,
--                                             r_get_promo_info.x_access_days
--                                            )
--                                  )
--                                 ),
--                          --End CR3509 Changes
--                          SYSDATE
--                         );
            INSERT INTO table_x_group2esn
                        (objid, x_annual_plan, groupesn2part_inst,
                         groupesn2x_promo_group,
                         groupesn2x_promotion,
                         x_end_date,
                         x_start_date
                        )
                 VALUES (sa.seq ('x_group2esn'), 1, r_get_esn_info.esnobjid,
                         r_get_promo_info.promogroupobjid,
                         r_get_promo_info.promoobjid,
                         DECODE (ip_promocode,
                                 'RTBY1GT000', TO_DATE
                                                    ('12/31/2007 11:59:59 PM',
                                                     'MM/DD/YYYY HH:MI:SS AM'
                                                    ),
                                 TO_DATE ('12/31/2055 11:59:59 PM',
                                          'MM/DD/YYYY HH:MI:SS AM'
                                         )
                                ),
                         SYSDATE
                        );
--CR5848
         END IF;                                              --CR3181 Changes

         IF SQL%ROWCOUNT > 0
         THEN
--CR5848
--             INSERT INTO table_x_group_hist
--                         (objid, x_start_date,
--                          x_end_date,
--                          x_action_date, x_action_type, x_annual_plan,
--                          grouphist2part_inst,
--                          grouphist2x_promo_group
--                         )
--                  VALUES (
--                          -- 04/10/03 seq_x_group_hist.nextval + power (2,28),
--                          sa.seq ('x_group_hist'), SYSDATE,
--                          --CR3509 Changes
--                          --               SYSDATE + DECODE(r_get_promo_info.x_access_days, 0, 365,
--                          --             r_get_promo_info.x_access_days),
--                          DECODE (ip_promocode,
--                                  'DBLMNAD000', TO_DATE
--                                                     ('12/31/2035 11:59:59 PM',
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),
--                                  '3390DBLMN', TO_DATE
--                                                     ('12/31/2035 11:59:59 PM',
--
--                                                      --CR4000
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),
--                                  'RTBY1GT000', TO_DATE
--                                                     ('12/31/2007 11:59:59 PM',
--                                                      'MM/DD/YYYY HH:MI:SS AM'
--                                                     ),                --CR5759
--                                  (  SYSDATE
--                                   + DECODE (r_get_promo_info.x_access_days,
--                                             0, 365,
--                                             r_get_promo_info.x_access_days
--                                            )
--                                  )
--                                 ),
--                          --End CR3509 Changes
--                          SYSDATE, 'ACTIVATION', 1,
--                          r_get_esn_info.esnobjid,
--                          r_get_promo_info.promogroupobjid
--                         );
            INSERT INTO table_x_group_hist
                        (objid, x_start_date,
                         x_end_date,
                         x_action_date, x_action_type, x_annual_plan,
                         grouphist2part_inst,
                         grouphist2x_promo_group
                        )
                 VALUES (sa.seq ('x_group_hist'), SYSDATE,
                         DECODE (ip_promocode,
                                 'RTBY1GT000', TO_DATE
                                                    ('12/31/2007 11:59:59 PM',
                                                     'MM/DD/YYYY HH:MI:SS AM'
                                                    ),
                                 TO_DATE ('12/31/2055 11:59:59 PM',
                                          'MM/DD/YYYY HH:MI:SS AM'
                                         )
                                ),
                         SYSDATE, 'ACTIVATION', 1,
                         r_get_esn_info.esnobjid,
                         r_get_promo_info.promogroupobjid
                        );
--CR5848
         END IF;
      END IF;
   END LOOP;
   --
   -- CR16379 Start kacosta 03/09/2012
   DECLARE
     --
     l_i_error_code    INTEGER := 0;
     l_v_error_message VARCHAR2(32767) := 'SUCCESS';
     --
   BEGIN
     --
     promotion_pkg.expire_double_if_esn_is_triple(p_esn           => ip_esn
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
      ROLLBACK;
      op_result := 1;
      op_msg := SUBSTR (SQLERRM, 1, 100);
      DBMS_OUTPUT.put_line (SQLERRM);
END sp_insert_group2esn;
/
CREATE OR REPLACE PROCEDURE sa."DENROLL_ESN_FROM_PROMO_PRC" (
   ip_esn         IN       VARCHAR2,
   ip_promocode   IN       VARCHAR2,
   op_result      OUT      NUMBER
)
AS
 /**************************************************************************************
  * Function Name: denroll_esn_from_promo_prc
  * Description :  De-Enroll Esn from promo by setting the end date in table_x_group2esn
  * Return      :  0 - Success, 1 - Failure
  * Created by  : Vani Adapa
  * Date        : 04/15/2004
  *
  * History
  * -------------------------------------------------------------
  * 04/15/04          VA                 Initial Release
  **************************************************************************************/
   CURSOR c_get_promo_info
   IS
      SELECT b.x_promo_mtm2x_promo_group promogroupobjid
        FROM table_x_promotion a, table_x_promotion_mtm b
       WHERE a.x_promo_code = ip_promocode
         AND a.objid = b.x_promo_mtm2x_promotion;


   r_get_promo_info c_get_promo_info%ROWTYPE;


   CURSOR c_get_esn_info
   IS
      SELECT a.objid esnobjid
        FROM table_part_inst a
       WHERE a.part_serial_no = ip_esn;


   r_get_esn_info c_get_esn_info%ROWTYPE;


   CURSOR c_get_group2esn (c_esn_objid IN NUMBER,  c_promo_grp_objid IN NUMBER)
   IS
      SELECT objid, x_end_date
        FROM table_x_group2esn
       WHERE groupesn2part_inst = c_esn_objid
         AND groupesn2x_promo_group = c_promo_grp_objid
         AND SYSDATE BETWEEN x_start_date AND NVL (x_end_date, SYSDATE + 1);


   r_get_group2esn c_get_group2esn%ROWTYPE;


   CURSOR c_promo_enrolldt
   IS
      SELECT b.x_transact_date
        FROM table_x_promo_hist a, table_x_call_trans b, table_x_promotion c,
             (SELECT MAX (service_end_dt) deact_dt
                FROM table_site_part sp1
               WHERE sp1.x_service_id = ip_esn
                 AND x_deact_reason LIKE 'PASTDUE%') d
       WHERE c.x_promo_code = ip_promocode
         AND a.promo_hist2x_promotion + 0 = c.objid
         AND a.promo_hist2x_call_trans = b.objid
         AND b.x_service_id = ip_esn
         AND b.x_transact_date > NVL (d.deact_dt, b.x_transact_date - 1)
         AND b.x_result = 'Completed';


   r_promo_enrolldt c_promo_enrolldt%ROWTYPE;


   CURSOR c_max_reddt
   IS
      SELECT MAX (x_red_date) max_reddt
        FROM table_x_red_card rc, table_x_call_trans ct
       WHERE ct.objid = rc.red_card2call_trans
         AND ct.x_service_id = ip_esn
         AND rc.x_result || '' = 'Completed'
         AND x_red_date >=
                (SELECT b.x_transact_date
                   FROM table_x_promo_hist a,
                        table_x_call_trans b,
                        table_x_promotion c
                  WHERE c.x_promo_code = ip_promocode
                    AND a.promo_hist2x_promotion + 0 = c.objid
                    AND a.promo_hist2x_call_trans = b.objid
                    AND b.x_service_id = ct.x_service_id
                    AND b.x_result = 'Completed');


   r_max_reddt c_max_reddt%ROWTYPE;


   CURSOR c_max_reddt1
   IS
      SELECT MAX (x_red_date) max_reddt1
        FROM table_x_red_card rc, table_x_call_trans ct
       WHERE ct.objid = rc.red_card2call_trans
         AND ct.x_service_id = ip_esn
         AND rc.x_result || '' = 'Completed'
         AND EXISTS(SELECT 1
                      FROM table_x_promo_hist a,
                           table_x_call_trans b,
                           table_x_promotion c
                     WHERE c.x_promo_code = ip_promocode
                       AND a.promo_hist2x_promotion + 0 = c.objid
                       AND a.promo_hist2x_call_trans = b.objid
                       AND b.x_service_id = ct.x_service_id);


   r_max_reddt1 c_max_reddt1%ROWTYPE;

   l_end_date DATE;
   l_objid NUMBER;
BEGIN

   FOR r_get_esn_info IN c_get_esn_info
   LOOP
--Promo Check
      OPEN c_get_promo_info;
      FETCH c_get_promo_info INTO r_get_promo_info;


      IF c_get_promo_info%NOTFOUND
      THEN
         CLOSE c_get_promo_info;
         op_result := 1;
         RETURN;
      ELSE
         CLOSE c_get_promo_info;
      END IF;
--Esn Enrollment Check
      OPEN c_get_group2esn (
         r_get_esn_info.esnobjid,
         r_get_promo_info.promogroupobjid
      );
      FETCH c_get_group2esn INTO r_get_group2esn;


      IF c_get_group2esn%NOTFOUND
      THEN

         CLOSE c_get_group2esn;
         op_result := 1;
         RETURN;
      ELSE

         l_end_date := r_get_group2esn.x_end_date;
         l_objid := r_get_group2esn.objid;
--Last Redemption Check
         OPEN c_promo_enrolldt;
         FETCH c_promo_enrolldt INTO r_promo_enrolldt;


         IF c_promo_enrolldt%NOTFOUND
         THEN
            CLOSE c_promo_enrolldt;
            op_result := 1;
            RETURN;
         ELSE
            OPEN c_max_reddt;
            FETCH c_max_reddt INTO r_max_reddt;


            IF (r_max_reddt.max_reddt IS NULL)
            THEN
               OPEN c_max_reddt1;
               FETCH c_max_reddt1 INTO r_max_reddt1;


               IF r_max_reddt1.max_reddt1 IS NOT NULL
               THEN
                  IF r_max_reddt1.max_reddt1 < r_promo_enrolldt.x_transact_date
                  THEN
                     IF (r_promo_enrolldt.x_transact_date < SYSDATE - 30)
                     THEN

                        UPDATE table_x_group2esn
                           SET x_end_date = SYSDATE - 1
                         WHERE objid = r_get_group2esn.objid;


                        op_result := 1;
                        RETURN;
                     ELSE
                        op_result := 0;
                        RETURN;
                     END IF;
                  END IF;
               ELSE
                  IF (r_promo_enrolldt.x_transact_date < SYSDATE - 30)
                  THEN
                     UPDATE table_x_group2esn
                        SET x_end_date = SYSDATE - 1
                      WHERE objid = r_get_group2esn.objid;


                     op_result := 1;
                     RETURN;
                  ELSE
                     op_result := 0;
                     RETURN;
                  END IF;
               END IF;

               CLOSE c_max_reddt1;
            ELSE
               IF (r_max_reddt.max_reddt < SYSDATE - 30)
               THEN
                  UPDATE table_x_group2esn
                     SET x_end_date = SYSDATE - 1
                   WHERE objid = r_get_group2esn.objid;


                  op_result := 1;
                  RETURN;
               ELSIF (r_max_reddt.max_reddt > r_promo_enrolldt.x_transact_date)
               THEN
                  op_result := 0;
                  RETURN;
               ELSE
                  op_result := 1;
                  RETURN;
               END IF;
            END IF;

            CLOSE c_max_reddt;
         END IF;

         CLOSE c_promo_enrolldt;
      END IF;

      CLOSE c_get_group2esn;
   END LOOP;

EXCEPTION
   WHEN OTHERS
   THEN

      op_result := 1;
      RETURN;
END denroll_esn_from_promo_prc;
/
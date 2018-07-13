CREATE OR REPLACE PROCEDURE sa."SP_PROMO_ENROLLMENT"
 /*****************************************************************
  * Package Name: SP_PROMO_ENROLLMENT
  * Description: The package is called by Clarify global (gValidatePromocode)
  *              to qualify esn for runtime promo.
  *
  * Created by: Gerald Pintado
  * Date:  01/24/2003
  *
  * History
  * -------------------------------------------------------------
  * 01/24/03          GP                 Initial Release
  * 04/10/03          SL                 Clarify Upgrade - sequence
  *****************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SP_PROMO_ENROLLMENT.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/04/03 15:13:37 $
  --$ $Log: SP_PROMO_ENROLLMENT.sql,v $
  --$ Revision 1.2  2012/04/03 15:13:37  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
                                                   (
   ip_esn            IN       VARCHAR2,
   ip_transtype      IN       VARCHAR2,
   ip_promocode      IN       VARCHAR2,
   ip_sourcesystem   IN       VARCHAR2,
   ip_language       IN       VARCHAR2,
   op_result         OUT      NUMBER,   -- 0=SUCCESS,1=FAILURE
   op_msg            OUT      VARCHAR2
)
IS

   CURSOR c_seq_call_trans
   IS
      -- 04/10/03 SELECT seq_x_call_trans.nextval + POWER (2, 28) val
        select seq('x_call_trans') val
        FROM dual;


   r_seq_call_trans c_seq_call_trans%ROWTYPE;


   CURSOR c_get_code_table (c_code_name IN VARCHAR2)
   IS
      SELECT objid, x_code_number, x_code_name
        FROM table_x_code_table
       WHERE x_code_name = c_code_name
         AND x_code_type = 'AT';


   r_get_code_table c_get_code_table%ROWTYPE;


   CURSOR c_get_sourcesystem (c_lang IN VARCHAR2)
   IS
      SELECT objid, x_code_number, x_code_name
        FROM table_x_code_table
       WHERE x_code_name = UPPER (RTRIM (LTRIM (c_lang)))
         AND x_code_type = 'SS';


   r_get_sourcesystem c_get_sourcesystem%ROWTYPE;


   CURSOR c_get_user
   IS
      SELECT objid
        FROM table_user
       WHERE s_login_name = 'SA';


   r_get_user c_get_user%ROWTYPE;


   CURSOR c_get_promo_info
   IS
      SELECT a.objid promoobjid, a.x_revenue_type, a.x_units,
             a.x_access_days,
             b.x_promo_mtm2x_promo_group promogroupobjid
        FROM table_x_promotion a, table_x_promotion_mtm b
       WHERE a.x_promo_code = ip_promocode
         AND a.objid = b.x_promo_mtm2x_promotion;


   r_get_promo_info c_get_promo_info%ROWTYPE;


   CURSOR c_get_esn_info
   IS
      SELECT a.part_serial_no x_esn, a.objid esnobjid,
             a.x_part_inst2site_part sitepartobjid,
             b.part_inst2carrier_mkt carrierobjid,
             b.part_serial_no x_min, e.objid dealerobjid
        FROM table_part_inst a,
             table_part_inst b,
             table_site_part c,
             table_inv_bin d,
             table_site e
       WHERE a.part_serial_no = ip_esn
         AND a.part_inst2inv_bin = d.objid
         AND d.bin_name = e.site_id
         AND a.x_part_inst2site_part = c.objid
         AND c.x_min = b.part_serial_no;


   counter NUMBER := 0;
BEGIN

   op_result := 0;   -- 0=SUCCESS,1=FAILURE
   op_msg := 'SUCCESSFULLY COMPLETED';


   FOR r_get_esn_info IN c_get_esn_info
   LOOP

      counter := counter + 1;
      /***** GETTING USER_ID *****/
      OPEN c_get_user;
      FETCH c_get_user INTO r_get_user;


      IF c_get_user%NOTFOUND
      THEN
         CLOSE c_get_user;
         op_result := 1;
         op_msg := 'ERROR - USER_ID RECORD NOT FOUND';
         RETURN;
      ELSE
         CLOSE c_get_user;
      END IF;

      /***** GETTING STATUS_CODE *****/
      OPEN c_get_code_table (ip_transtype);
      FETCH c_get_code_table INTO r_get_code_table;


      IF c_get_code_table%NOTFOUND
      THEN
         CLOSE c_get_code_table;
         op_result := 1;
         op_msg := 'ERROR - STATUS_CODE RECORD NOT FOUND';
         RETURN;
      ELSE
         CLOSE c_get_code_table;
      END IF;

      /***** GETTING SOURCE SYSTEM ****/
      OPEN c_get_sourcesystem (ip_language);
      FETCH c_get_sourcesystem INTO r_get_sourcesystem;


      IF c_get_sourcesystem%NOTFOUND
      THEN
         CLOSE c_get_sourcesystem;
         op_result := 1;
         op_msg := 'ERROR - SOURCE_SYSTEM RECORD NOT FOUND';
         RETURN;
      ELSE
         CLOSE c_get_sourcesystem;
      END IF;

      /***** GETTING NEW CALL_TRANS OBJID *****/
      OPEN c_seq_call_trans;
      FETCH c_seq_call_trans INTO r_seq_call_trans;


      IF c_seq_call_trans%NOTFOUND
      THEN
         CLOSE c_seq_call_trans;
         op_result := 1;
         op_msg := 'ERROR - GETTING CALL_TRANS OBJID';
         RETURN;
      ELSE
         CLOSE c_seq_call_trans;
      END IF;

      /***** GETTING PROMOTION AND PROMOTION_GROUP OBJID *****/
      OPEN c_get_promo_info;
      FETCH c_get_promo_info INTO r_get_promo_info;


      IF c_get_promo_info%NOTFOUND
      THEN
         CLOSE c_get_promo_info;
         op_result := 1;
         op_msg := 'ERROR - GETTING PROMOTION OBJID';
         RETURN;
      ELSE
         CLOSE c_get_promo_info;
      END IF;


      INSERT INTO table_x_call_trans
                  (
                                 objid,
                                 call_trans2site_part,
                                 x_action_type,
                                 x_call_trans2carrier,
                                 x_call_trans2dealer,
                                 x_call_trans2user,
                                 x_min,
                                 x_service_id,
                                 x_sourcesystem,
                                 x_transact_date,
                                 x_total_units,
                                 x_action_text,
                                 x_reason,
                                 x_result,
                                 x_sub_sourcesystem
                  )
           VALUES(
              r_seq_call_trans.val,
              r_get_esn_info.sitepartobjid,
              r_get_code_table.x_code_number,
              r_get_esn_info.carrierobjid,
              r_get_esn_info.dealerobjid,
              r_get_user.objid,
              r_get_esn_info.x_min,
              r_get_esn_info.x_esn,
              RTRIM (LTRIM (ip_sourcesystem)),
              SYSDATE,
              0,
              r_get_code_table.x_code_name,
              NULL,
              'Completed',
              r_get_sourcesystem.x_code_number
           );


      INSERT INTO table_x_group2esn
                  (
                                 objid,
                                 x_annual_plan,
                                 groupesn2part_inst,
                                 groupesn2x_promo_group,
                                 x_end_date,
                                 x_start_date
                  )
           VALUES(
              -- 04/10/03 seq_x_group2esn.nextval + POWER (2, 28),
              seq('x_group2esn'),
              0,
              r_get_esn_info.esnobjid,
              r_get_promo_info.promogroupobjid,
              NULL,
              SYSDATE
           );

      -- IF PROMOTION HAS UNITS OR ACCESS THEN INSERT INTO PENDING TABLE
      IF    (r_get_promo_info.x_units > 0)
         OR (r_get_promo_info.x_access_days > 0)
      THEN

         INSERT INTO table_x_pending_redemption
                     (
                                    objid,
                                    pend_red2x_promotion,
                                    x_pend_red2site_part,
                                    x_pend_type
                     )
              VALUES(
                 --04/10/03 seq_x_pending_redemption.nextval + POWER (2, 28),
                 seq('x_pending_redemption'),
                 r_get_promo_info.promoobjid,
                 r_get_esn_info.sitepartobjid,
                 r_get_promo_info.x_revenue_type
              );
      ELSE
         INSERT INTO table_x_promo_hist
                     (objid, promo_hist2x_call_trans, promo_hist2x_promotion)
              VALUES(
                 --04/10/03 seq_x_promo_hist.nextval + POWER (2, 28),
                 seq('x_promo_hist'),
                 r_seq_call_trans.val,
                 r_get_promo_info.promoobjid
              );
      END IF;
   END LOOP;


   IF counter = 0
   THEN
      op_result := 1;
      op_msg := 'ERROR - SERVICE RECORD WAS NOT FOUND';
   END IF;
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
END sp_promo_enrollment;
/
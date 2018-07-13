CREATE OR REPLACE PROCEDURE sa.sp_reset_esn_tossutil (
   ip_esn     IN       VARCHAR2,
   ip_trans   IN       VARCHAR2,                               -- 0=new,1=used
   ip_appUser IN       VARCHAR2,  -- CR27254
   op_msg     OUT      VARCHAR2
)
--
-- History:
-- 04/10/03   SL     Clarify Upgrade - sequence
-- 02/28/05   RG     Allow changing Past due phones to Used
-- 06/03/05   GP     CR4109 - OTA Feature Phone Reset
-- 07/12/05   GP     CR3364 - Update ESNs warr_end_dt to equal expire_dt
-- 06/26/06   IC   CR4623 - Update ESNs warr_end_dt, expire_dt,
--                         to sysdate + 60 if they're <= sysdate
-- 07/10/06   VA   CR4623 - Fix
-- 02/20/07   VA   CR5848 - To remove the double minute promo if the esn is reset to NEw
-- 09/18/07      CL/VA CR6731 - Eliminate SIM project
  --
  --********************************************************************************
  --$RCSfile: SP_RESET_ESN_TOSSUTIL.sql,v $
  --$Revision: 1.3 $
  --$Author: oarbab $
  --$Date: 2014/03/25 16:24:38 $
  --$ $Log: SP_RESET_ESN_TOSSUTIL.sql,v $
  --$ Revision 1.3  2014/03/25 16:24:38  oarbab
  --$ CR27254: Only FRAUD DEPARTMENT should be able to reset a phone in Risk Assessment status.
  --$
  --$ Revision 1.2  2012/04/03 15:17:44  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  --********************************************************************************
  --
IS
   CURSOR cur_ph
   IS
      SELECT a.*, b.part_status status, b.x_expire_dt, b.objid spobjid
        FROM table_part_inst a, table_site_part b
       WHERE a.part_serial_no = ip_esn AND x_part_inst2site_part = b.objid(+);

   CURSOR c_user_objid
   IS
      SELECT objid
        FROM table_user
       WHERE s_login_name = 'TOSSUTILITY';

   v_user_objid        NUMBER;
   rec_ph              cur_ph%ROWTYPE;
   r_user_objid        c_user_objid%ROWTYPE;
   v_expire_dt         DATE;

--CR5848 Start
   CURSOR cur_remov_dmucard (ip_esnobjid IN NUMBER)
   IS
      SELECT *
        FROM table_x_group2esn
       WHERE (groupesn2x_promo_group IN (
                 SELECT b.x_promo_mtm2x_promo_group
                   FROM table_x_promotion a, table_x_promotion_mtm b
                  WHERE a.x_promo_code IN
                                      -- CR16379 Start kacosta 03/12/2012
                                      --('DBLMNAD000', '3390DBLMN', 'RTDBL000')
                                      ('DBLMNAD000','3390DBLMN','RTDBL000','RTX3X000')
                                      -- CR16379 End kacosta 03/12/2012
                    AND a.objid = b.x_promo_mtm2x_promotion)
             )
         AND groupesn2part_inst = ip_esnobjid;

   rec_remov_dmucard   cur_remov_dmucard%ROWTYPE;
   v_group_hist_seq    NUMBER;
--CR5848 End
-- CR27254 CURSORS START
    CURSOR cur_user_class
    IS
        SELECT objid
        FROM sa.TABLE_PRIVCLASS
        WHERE S_CLASS_NAME='FRAUD DEPARTMENT';
    rec_user_class cur_user_class%ROWTYPE;

    CURSOR cur_access2privclass (ip_user IN VARCHAR2)
    IS
        SELECT user_access2privclass
        FROM table_user
        WHERE s_login_name = upper (ip_user);

 rec_access2privclass cur_access2privclass%ROWTYPE;
 -- CR27254 CURSORS END

---------------------- MAIN ------------
BEGIN
   OPEN c_user_objid;

   FETCH c_user_objid
    INTO r_user_objid;

   IF c_user_objid%FOUND
   THEN
      CLOSE c_user_objid;

      v_user_objid := r_user_objid.objid;
   ELSE
      CLOSE c_user_objid;

      v_user_objid := NULL;
   END IF;
--- CR27254: FETCH CURSORS START
   OPEN cur_access2privclass (ip_appUser);
    FETCH cur_access2privclass
        INTO rec_access2privclass;

   IF cur_access2privclass%NOTFOUND
   THEN
	op_msg := 'User priviliage not found';
	END IF;
   OPEN cur_user_class;
    FETCH cur_user_class
        INTO rec_user_class;
	IF cur_user_class%NOTFOUND
	THEN
		op_msg := 'User class not found';
	END IF;
--- CR27254: FTECH CURSORS END

  OPEN cur_ph;

   FETCH cur_ph
    INTO rec_ph;

   IF cur_ph%NOTFOUND
   THEN
      op_msg := 'Esn not found';
   ELSIF rec_ph.x_part_inst_status = '50' AND ip_trans = 0
   THEN
      op_msg := 'ESN is already marked as NEW';

--- start of CR27254
   ELSIF     rec_ph.x_part_inst_status = '56'    -- Risk Assessment
           AND  rec_user_class.objid != rec_access2privclass.user_access2privclass
   THEN
      op_msg := 'Phone is in Risk Assessment status. Please contact the FRAUD DEPARTMENT';
-- End of CR27254

   /*
     Commented for CR3494 - Allow reset of digital phones to new
     Elsif rec_ph.x_part_inst_status = '50' and ip_trans = 1 and rec_ph.x_technology <> 'ANALOG' then
     op_msg := 'Cannot reset a Digital phone from NEW to USED';
   */
   ELSIF     rec_ph.x_part_inst_status <> '50'
         AND rec_ph.x_part_inst_status <> '54'
         AND ip_trans = 1
   THEN
      op_msg := 'Phone needs a status of NEW or PASTDUE to be reset to USED';
   /*CR3494 - Ends*/
   ELSIF rec_ph.status = 'Active'
   THEN
      op_msg := 'Esn is Active';

   ELSE
      /* CR4109 - OTA Feature Phone Reset */
      DELETE FROM table_x_ota_features
            WHERE x_ota_features2part_inst = rec_ph.objid;

      /*CR3494 - Allow past due phones to be reset as well. Allow Analog and Digital phones to be reset to used*/
      IF     (   rec_ph.x_part_inst_status = '50'
              OR rec_ph.x_part_inst_status = '54'
             )
         AND ip_trans = 1
      THEN
         v_expire_dt :=
            GREATEST (NVL (rec_ph.warr_end_date, '01-jan-70'),
                      (NVL (rec_ph.x_expire_dt, '01-jan-70')
                      )
                     );

         IF v_expire_dt < '02-jan-70'
         THEN
            v_expire_dt := NULL;
         END IF;

         -- CR4623
         IF v_expire_dt IS NULL OR v_expire_dt < SYSDATE + 1
         THEN
            v_expire_dt := SYSDATE + 60;
         END IF;

         UPDATE table_part_inst
            SET x_part_inst_status = '51',
                status2x_code_table = 987,
                x_reactivation_flag = 0,
                warr_end_date = v_expire_dt
          WHERE x_domain = 'PHONES' AND part_serial_no = ip_esn;

         UPDATE table_site_part
            SET warranty_date = v_expire_dt,
                x_expire_dt = v_expire_dt
          WHERE objid = rec_ph.spobjid;

         op_msg := 'Phone has been reset to USED';
      ELSE
         UPDATE table_part_inst
            SET x_part_inst_status = '50',
                status2x_code_table = 986,
                x_reactivation_flag = 0,
                warr_end_date = NULL,
                x_part_inst2contact = NULL,
                x_iccid = null --CR6731
          WHERE x_domain = 'PHONES' AND part_serial_no = ip_esn;

         op_msg := 'Phone has been reset to NEW';

--CR5848 Start
         FOR rec_remov_dmucard IN cur_remov_dmucard (rec_ph.objid)
         LOOP
            sa.sp_seq ('x_group_hist', v_group_hist_seq);

            INSERT INTO table_x_group_hist
                        (objid, x_start_date,
                         x_end_date, x_action_date, x_action_type,
                         x_annual_plan,
                         grouphist2part_inst,
                         grouphist2x_promo_group
                        )
                 VALUES (v_group_hist_seq, rec_remov_dmucard.x_start_date,
                         rec_remov_dmucard.x_end_date, SYSDATE, 'REMOVE',
                         rec_remov_dmucard.x_annual_plan,
                         rec_remov_dmucard.groupesn2part_inst,
                         rec_remov_dmucard.groupesn2x_promo_group
                        );

            DELETE FROM table_x_group2esn
                  WHERE objid = rec_remov_dmucard.objid;
         END LOOP;
--CR5848 End
      END IF;

      --write to pi_hist table
      INSERT INTO table_x_pi_hist
                  (objid, status_hist2x_code_table, x_change_date,
                   x_change_reason, x_cool_end_date,
                   x_creation_date, x_deactivation_flag,
                   x_domain, x_ext, x_insert_date,
                   x_npa, x_nxx, x_old_ext, x_old_npa, x_old_nxx,
                   x_part_bin, x_part_inst_status,
                   x_part_mod, x_part_serial_no,
                   x_part_status, x_pi_hist2carrier_mkt,
                   x_pi_hist2inv_bin, x_pi_hist2part_inst,
                   x_pi_hist2part_mod,
                   x_pi_hist2user,
                   x_pi_hist2x_new_pers, x_pi_hist2x_pers,
                   x_po_num, x_reactivation_flag,
                   x_red_code, x_sequence,
                   x_warr_end_date, dev,
                   fulfill_hist2demand_dtl, part_to_esn_hist2part_inst,
                   x_bad_res_qty, x_date_in_serv,
                   x_good_res_qty, x_last_cycle_ct,
                   x_last_mod_time, x_last_pi_date,
                   x_last_trans_time, x_next_cycle_ct,
                   x_order_number, x_part_bad_qty,
                   x_part_good_qty, x_pi_tag_no,
                   x_pick_request, x_repair_date,
                   x_transaction_id
                  )
           VALUES (
                   -- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
                   sa.seq ('x_pi_hist'), rec_ph.status2x_code_table, SYSDATE,
                   'RESET FOR NEW CUSTOMER', rec_ph.x_cool_end_date,
                   rec_ph.x_creation_date, rec_ph.x_deactivation_flag,
                   rec_ph.x_domain, rec_ph.x_ext, rec_ph.x_insert_date,
                   rec_ph.x_npa, rec_ph.x_nxx, NULL, NULL, NULL,
                   rec_ph.part_bin, rec_ph.x_part_inst_status,
                   rec_ph.part_mod, rec_ph.part_serial_no,
                   rec_ph.part_status, rec_ph.part_inst2carrier_mkt,
                   rec_ph.part_inst2inv_bin, rec_ph.objid,
                   rec_ph.n_part_inst2part_mod,
                   DECODE (v_user_objid,
                           NULL, rec_ph.created_by2user,
                           v_user_objid
                          ),
                   rec_ph.part_inst2x_new_pers, rec_ph.part_inst2x_pers,
                   rec_ph.x_po_num, rec_ph.x_reactivation_flag,
                   rec_ph.x_red_code, rec_ph.x_sequence,
                   rec_ph.warr_end_date, rec_ph.dev,
                   rec_ph.fulfill2demand_dtl, rec_ph.part_to_esn2part_inst,
                   rec_ph.bad_res_qty, rec_ph.date_in_serv,
                   rec_ph.good_res_qty, rec_ph.last_cycle_ct,
                   rec_ph.last_mod_time, rec_ph.last_pi_date,
                   rec_ph.last_trans_time, rec_ph.next_cycle_ct,
                   rec_ph.x_order_number, rec_ph.part_bad_qty,
                   rec_ph.part_good_qty, rec_ph.pi_tag_no,
                   rec_ph.pick_request, rec_ph.repair_date,
                   rec_ph.transaction_id
                  );

      COMMIT;
   END IF;

   CLOSE cur_ph;
   CLOSE cur_access2privclass;  -- CR27254
   CLOSE cur_user_class;        -- CR27254
END;
/
CREATE OR REPLACE PROCEDURE sa."CTIAWF_MONTHLY_BONUS_PRC" (
   ip_run_date IN DATE,
   ip_enroll_promo_code IN VARCHAR2,
   ip_pend_promo_code IN VARCHAR2
)
AS
/********************************************************************************/
   /*    Copyright   2004 Tracfone  Wireless Inc. All rights reserved              */
   /*                                                                              */
   /* NAME:         CTIAWF_MONTHLY_BONUS_PRC                                       */
   /* PURPOSE:      To issue monthly bonus units for CTIAWF customers              */
   /* FREQUENCY:                                                                   */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                               */
   /*                                                                              */
   /* REVISIONS:                                                                   */
   /* VERSION  DATE        WHO          PURPOSE                                    */
   /* -------  ---------- -----  ---------------------------------------------     */
   /*  1.0     03/31/04   VAdapa Initial  Revision                                 */
   /*  1.1     08/16/04   VAdapa CR3132 - Fix for MT#52765                         */
   /********************************************************************************/
   CURSOR c_ctiawf_qual_recs
   IS
   SELECT sp.objid,
      sp.x_service_id
   FROM table_site_part sp, table_x_call_trans ct, table_x_promo_hist ph,
   table_x_promotion pr
   WHERE pr.objid = ph.promo_hist2x_promotion
   AND ph.promo_hist2x_call_trans = ct.objid
   --         AND ct.call_trans2site_part = sp.objid --CR3132
   AND ct.x_service_id = sp.x_service_id --CR3132
   AND sp.part_status = 'Active'
   AND TRUNC (sp.install_date) < TRUNC (ip_run_date)
   AND NVL (TO_CHAR (sp.cmmtmnt_end_dt, 'MON'), 'ZZZ') <> TO_CHAR (ip_run_date,
   'MON')
   AND pr.x_promo_code = ip_enroll_promo_code;
   CURSOR c_promo_info
   IS
   SELECT objid,
      x_revenue_type
   FROM table_x_promotion
   WHERE x_promo_code = ip_pend_promo_code
   AND SYSDATE BETWEEN x_start_date
   AND x_end_date;
   r_promo_info c_promo_info%ROWTYPE;
   l_recs_processed NUMBER := 0;
   l_serial_num table_part_inst.part_serial_no%TYPE;
   l_procedure_name VARCHAR2 (80) := 'CTIAWF_MONTHLY_BONUS_PRC';
   l_action VARCHAR2 (50) := ' ';
   l_err_text VARCHAR2 (4000);
   l_start_date DATE := SYSDATE;
   no_promo_exp EXCEPTION
;
BEGIN
   l_action := 'Promo Existence Check';
   OPEN c_promo_info;
   FETCH c_promo_info
   INTO r_promo_info;
   IF c_promo_info%NOTFOUND
   THEN
      CLOSE c_promo_info;
      RAISE no_promo_exp;
   ELSE
      FOR r_ctiawf_qual_recs IN c_ctiawf_qual_recs
      LOOP
         BEGIN
            l_serial_num := r_ctiawf_qual_recs.x_service_id;
            l_action := 'Insert into Table_X_Pending_Redemption';
            INSERT
            INTO table_x_pending_redemption(
               objid,
               pend_red2x_promotion,
               x_pend_red2site_part,
               x_pend_type
            )VALUES(
               seq ('x_pending_redemption'),
               r_promo_info.objid,
               r_ctiawf_qual_recs.objid,
               r_promo_info.x_revenue_type
            );
            IF SQL%ROWCOUNT = 1
            THEN
               l_action := 'Update Table_Site_Part';
               UPDATE table_site_part SET cmmtmnt_end_dt = ip_run_date
               WHERE objid = r_ctiawf_qual_recs.objid;
               COMMIT;
               l_recs_processed := l_recs_processed + 1;
            END IF;
            EXCEPTION
            WHEN OTHERS
            THEN
               l_err_text := SQLERRM;
               toss_util_pkg.insert_error_tab_proc (
               'Inner Block Error - When others', l_serial_num,
               l_procedure_name );
         END;
      END LOOP;
      COMMIT;
   END IF;
   CLOSE c_promo_info;
   IF toss_util_pkg.insert_interface_jobs_fun ( l_procedure_name, l_start_date,
   SYSDATE, l_recs_processed, 'SUCCESS', l_procedure_name )
   THEN
      COMMIT;
   END IF;
   EXCEPTION
   WHEN no_promo_exp
   THEN
      toss_util_pkg.insert_error_tab_proc ( l_action, ip_pend_promo_code,
      l_procedure_name, 'Promo Does Not Exist' );
   WHEN OTHERS
   THEN
      l_err_text := SQLERRM;
      toss_util_pkg.insert_error_tab_proc ( l_action, l_serial_num,
      l_procedure_name );
      IF toss_util_pkg.insert_interface_jobs_fun ( l_procedure_name,
      l_start_date, SYSDATE, l_recs_processed, 'FAILED', l_procedure_name )
      THEN
         COMMIT;
      END IF;
END ctiawf_monthly_bonus_prc;
/
CREATE OR REPLACE PACKAGE BODY sa."TOSS_UTIL_PKG"
IS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         TOSS_UTIL_PKG(BODY)                                          */
/* PURPOSE:      This package served  repository of commomly used functions   */
/*               and constants                                                */
/*               for TOSS batch processes and applications.                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/* REVISIONS:                                                                 */
/* VERSION  DATE     WHO         PURPOSE                                      */
/* ------  ----     ------       ---------------------------------------------*/
/* 1.0    12/18/01  Miguel Leon  Initial  Revision                            */
/*                                                                            */
/* 1.1    02/02/01  Miguel Leon   Added new functions and proc                */
/*                                                                            */
/* 1.2    03/17/02  Miguel Leon   Added function part_mod_exis fun. Also chan-*/
/*                                ged update_pricing_fun and insert_pricing_fu*/
/*                                to insert or update null table_x_pricing.   */
/*                                x_end_date to a date in the far future to   */
/*                                accomodate CLARIFY inabity to handle date   */
/*                                ranges with ending NULL dates.              */
/*                                                                            */
/* 1.3   04/18/02  Miguel Leon   Changed REDEMPTION CARD to REDEMPTION CARDS  */
/*                                (plural) within the insert_swp_posa  tab fun*/
/*                                ction. Modified set_pi_status_fun to use    */
/*                                newly added in param ip_domain.             */
/*                                                                            */
/* 1.4   07/15/02 Miguel Leon     Added new phone status codes 54(past_due)   */
/*                                and 51(phone used). site_part_active_fun    */
/*                                also added.                                 */
/*                                                                            */
/* 1.5  09/12/02  Miguel Leon    Added new function part_mod_exist_null_fun.  */
/*                               Modified function Modified update_mod_level  */
/*                               fun.                                         */
/* 1.6                                                                        */
/* 1.7  10/21/02 Vani Adapa      Modified to insert X_MSID value into         */
/*                               TABLE_X_PI_HIST in insert_pi_hist_fun        */
/* 1.8  01/02/03 D. Driscoll     Added new functions:  frequency_exist_fun,   */
/*                               insert_frequency_fun, update_frequency_fun,  */
/*                               insert_part_num2frequency_fun,               */
/*                               update_part_num2frequency_fun                */
/* 1.9  03/17/03 SL              Clarify Upgrade                              */
/*                               Moved all posa related function/store proc   */
/*                               to posa package                              */
/* 1.9  04/10/03 SL              Clarify Upgrade - sequence                   */
/* 2.0  02/16/04 Vani Aadapa     Changes for PSE project                      */
/*                               - Added the following fields in insert_part_ */
/*                                 num function                               */
/*                                      part_num2x_promotion                  */
/*                                      part_num2part_class                   */
/*                                      x_cardless_bundle_in                  */
/*                               - Added the following fields in update_part_ */
/*                                 num function                               */
/*                                      part_num2x_promotion                  */
/*                                      x_cardless_bundle_in                  */
/*                               - Added a new function insert_part_script_fun*/
/*                                 to insert the scripts from the parent      */
/* 2.1  05/17/07 A Barrera       Adding flag in part_num to identify MEID num */
/*1.11 03/02/06    VAdapa      CR4981_4982 - Logic added to add information for DATA phones and CONVERSION rates
/*                             insert_part_num_fun and update_part_num_fun modified
/*1.12 05/17/06      VAdapa      Same version
/*1.13 05/23/06    Gpintado    CR4981 - Added x_ild_type, x_ota_allowed, and x_extd_warranty (PVCS Revision 1.13)
/******************************************************************************/
/* NEW PVCS STRUCTURE
/* 1.0  01/10/2008  NGuada  TMODATA
/* 1.1  12/20/2008  CLinder CR8000
/* 1.2  01/27/2009  CLinder CR8000
/* 1.3/1.4  02/09/2009  CLinder CR8000 removed if stmt sql%rowcount in update_part_num_fun
/* 1.6 08/26/09    NGuada       BRAND_SEP - using table_bus_org to retrieve values instead of the pn record
/* 1.7/1.8   09/02/09                       Latest
/* 1.9   10/01/09    ICanavan   BRAND_SEP added values for x_type in table_x_pricing
/* CVS
/* 1.5   08/02/2013 CLindner CR21541 Family Plans - Cash Solutions Release                 */
/* 1.10   04/04/2013 CLindner CR22451 Simple Mobile System Integration - WEBCSR            */
/* 1.11   07/23/2013 MVadlapally CR23513 TracFone SurePay for Android            */
/* 1.24   08/27/2015 SMeganathan CR35913  Added new channel APP
/****************************************************************************/
   v_package_name   CONSTANT VARCHAR2 (80)                := '.TOSS_UTIL_PKG';

   CURSOR get_class_data_conf_cur (ip_part_class_objid NUMBER)
   IS
      SELECT dc.objid
        FROM table_x_data_config dc
       WHERE dc.x_part_class_objid = ip_part_class_objid
         AND dc.x_parent_id = 6;

   class_data_conf_rec       get_class_data_conf_cur%ROWTYPE;

   CURSOR get_default_data_conf_cur
   IS
      SELECT dc.objid
        FROM table_x_data_config dc
       WHERE dc.x_parent_id = 6 AND x_default = 1;

   default_data_conf_rec     get_default_data_conf_cur%ROWTYPE;

/*****************************************************************************/
/*                                                                           */
/* Name:    lf_get_part_num_vals                                             */
/* Description : gets the all the part class info                            */
/*****************************************************************************/
   PROCEDURE lf_get_part_num_vals (
      f_part_num2part_class            IN       NUMBER,
      f_domain                         IN       VARCHAR2,
      f_restricted_use                 OUT      VARCHAR2,
      f_dll                            OUT      VARCHAR2,
      f_ild_type                       OUT      VARCHAR2,
      f_technology                     OUT      VARCHAR2,
      f_meid_phone                     OUT      VARCHAR2,
      f_manufacturer                   OUT      VARCHAR2,
      f_data_capable                   OUT      VARCHAR2,
      f_initial_motricity_conversion   OUT      VARCHAR2,
      f_ota_allowed                    OUT      VARCHAR2,
      f_extd_warranty                  OUT      VARCHAR2,
      f_preloaded_click_id             OUT      VARCHAR2,
      f_default_click_id               OUT      VARCHAR2,
      f_preloaded_data_config          OUT      VARCHAR2,
      f_frequency_1                    OUT      VARCHAR2,
      f_frequency_2                    OUT      VARCHAR2
   )
   IS
      FUNCTION get_param_by_name_fun (ip_parameter IN VARCHAR2)
         RETURN VARCHAR2
      IS
         CURSOR c1
         IS
            SELECT x_param_value
              FROM table_x_part_class_values v,
                   table_x_part_class_params n,
                   table_part_class pc
             WHERE value2class_param = n.objid
               AND n.x_param_name = ip_parameter
               AND v.value2part_class = pc.objid
               AND pc.objid = f_part_num2part_class;

         r1             c1%ROWTYPE;
         return_value   VARCHAR2 (30);
      BEGIN
         OPEN c1;

         FETCH c1
          INTO r1;

         IF c1%FOUND
         THEN
            return_value := r1.x_param_value;
         ELSE
            IF f_domain IN ('ACC', 'VAS')
            THEN
               NULL;
            ELSE
               return_value := 'NOT FOUND';
            END IF;
         END IF;

         CLOSE c1;

         RETURN return_value;
      END get_param_by_name_fun;
   BEGIN
      f_restricted_use := get_param_by_name_fun ('RESTRICTED_USE');
      f_dll := get_param_by_name_fun ('DLL');
      f_ild_type := get_param_by_name_fun ('ILD_TYPE');
      f_technology := get_param_by_name_fun ('TECHNOLOGY');
      f_meid_phone := get_param_by_name_fun ('MEID_PHONE');
      f_manufacturer := get_param_by_name_fun ('MANUFACTURER');
      f_data_capable := get_param_by_name_fun ('DATA_CAPABLE');
      f_initial_motricity_conversion :=
                       get_param_by_name_fun ('INITIAL_MOTRICITY_CONVERSION');
      f_ota_allowed := get_param_by_name_fun ('OTA_ALLOWED');
      f_extd_warranty := get_param_by_name_fun ('EXTD_WARRANTY');
      f_preloaded_click_id := get_param_by_name_fun ('PRELOADED_CLICK_ID');
      f_default_click_id := get_param_by_name_fun ('DEFAULT_CLICK_ID');
      f_preloaded_data_config :=
                              get_param_by_name_fun ('PRELOADED_DATA_CONFIG');
      f_frequency_1 := get_param_by_name_fun ('FREQUENCY_1');
      f_frequency_2 := get_param_by_name_fun ('FREQUENCY_2');
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_posa_swp_tab_fun                                          */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_posa_swp_tab_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_action           IN   VARCHAR2,
      ip_store_detail     IN   VARCHAR2,
      ip_store_id         IN   VARCHAR2,
      ip_trans_id         IN   VARCHAR2,
      ip_sourcesystem     IN   VARCHAR2,
      ip_trans_date       IN   DATE,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   CONSTANT VARCHAR2 (200)
                            := v_package_name || '.insert_posa_swp_tab_fun()';
      table_part_rec             table_part_num%ROWTYPE;
      table_site_rec             table_site%ROWTYPE;
      table_part_inst_rec        table_part_inst%ROWTYPE;
      table_road_inst_rec        table_x_road_inst%ROWTYPE;
   BEGIN
      IF ip_domain = 'ROADSIDE'
      THEN
         OPEN toss_cursor_pkg.table_part_num_road_cur (ip_part_serial_no);

         FETCH toss_cursor_pkg.table_part_num_road_cur
          INTO table_part_rec;

         CLOSE toss_cursor_pkg.table_part_num_road_cur;

         OPEN toss_cursor_pkg.table_site_road_cur (ip_part_serial_no,
                                                   ip_domain
                                                  );

         FETCH toss_cursor_pkg.table_site_road_cur
          INTO table_site_rec;

         CLOSE toss_cursor_pkg.table_site_road_cur;

         OPEN toss_cursor_pkg.table_road_inst_cur (ip_part_serial_no);

         FETCH toss_cursor_pkg.table_road_inst_cur
         INTO table_road_inst_rec;

         CLOSE toss_cursor_pkg.table_road_inst_cur;
      ELSE
         OPEN toss_cursor_pkg.table_part_num_cur (ip_part_serial_no);

         FETCH toss_cursor_pkg.table_part_num_cur
          INTO table_part_rec;

         CLOSE toss_cursor_pkg.table_part_num_cur;

         OPEN toss_cursor_pkg.table_site_cur (ip_part_serial_no, ip_domain);

         FETCH toss_cursor_pkg.table_site_cur
          INTO table_site_rec;

         CLOSE toss_cursor_pkg.table_site_cur;

         OPEN toss_cursor_pkg.table_part_inst_cur (ip_part_serial_no);

         FETCH toss_cursor_pkg.table_part_inst_cur
          INTO table_part_inst_rec;

         CLOSE toss_cursor_pkg.table_part_inst_cur;
      END IF;

      IF ip_domain = 'REDEMPTION CARDS'
      THEN
         INSERT INTO x_posa_card
                     (tf_part_num_parent, tf_serial_num,
                      toss_att_customer, toss_att_location,
                      toss_posa_code, toss_posa_date, tf_extract_flag,
                      tf_extract_date, toss_site_id, toss_posa_action,
                      --toss_att_id,
                      objid, remote_trans_id, sourcesystem,
                      toss_att_trans_date
                     )
              VALUES (table_part_rec.part_number, ip_part_serial_no,
                      ip_store_id, ip_store_detail,
                      table_part_inst_rec.x_part_inst_status, SYSDATE, 'N',
                      NULL, table_site_rec.site_id, ip_action,
                      seq_x_posa_card.NEXTVAL, ip_trans_id, ip_sourcesystem,
                      ip_trans_date
                     );
      ELSIF ip_domain = 'PHONES'
      THEN
         INSERT INTO x_posa_phone
                     (tf_part_num_parent, tf_serial_num,
                      toss_att_customer, toss_att_location,
                      toss_posa_code, toss_posa_date, tf_extract_flag,
                      tf_extract_date, toss_site_id, toss_posa_action,
                      --toss_att_id,
                      objid, remote_trans_id,
                      sourcesystem, toss_att_trans_date
                     )
              VALUES (table_part_rec.part_number, ip_part_serial_no,
                      ip_store_id, ip_store_detail,
                      table_part_inst_rec.x_part_inst_status, SYSDATE, 'N',
                      NULL, table_site_rec.site_id, ip_action,
                      seq_x_posa_phone.NEXTVAL, ip_trans_id,
                      ip_sourcesystem, ip_trans_date
                     );
      ELSE
         /* DOMAIN is ROADSIDE */
         INSERT INTO x_posa_road
                     (tf_part_num_parent, tf_serial_num,
                      toss_att_customer, toss_att_location,
                      toss_posa_code, toss_posa_date, tf_extract_flag,
                      tf_extract_date, toss_site_id, toss_posa_action,
                      --toss_att_id,
                      objid, remote_trans_id, sourcesystem,
                      toss_att_trans_date
                     )
              VALUES (table_part_rec.part_number, ip_part_serial_no,
                      ip_store_id, ip_store_detail,
                      table_road_inst_rec.x_part_inst_status, SYSDATE, 'N',
                      NULL, table_site_rec.site_id, ip_action,
                      seq_x_posa_road.NEXTVAL, ip_trans_id, ip_sourcesystem,
                      ip_trans_date
                     );
      END IF;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failer inserting swipe',
                                ip_part_serial_no,
                                'TOSS_UTIL_PKG.INSERT_POSA_SWP_TAB_FUN'
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:     insert_error_tab_proc                                           */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   PROCEDURE insert_error_tab_proc (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2,
      ip_error_text     IN   VARCHAR2 DEFAULT NULL
   )
   IS
      sql_code                    NUMBER;
      sql_err                     VARCHAR2 (300);
      v_error_text                VARCHAR2 (1000);
      v_procedure_name   CONSTANT VARCHAR2 (200)
                              := v_package_name || '.insert_error_tab_proc()';
   BEGIN
      sql_code := SQLCODE;
      sql_err := SQLERRM;

      IF ip_error_text IS NULL
      THEN
         v_error_text :=
               'SQL Error Code : '
            || TO_CHAR (sql_code)
            || ' Error Message : '
            || sql_err;
      ELSE
         v_error_text := ip_error_text;
      END IF;

      INSERT INTO error_table
                  (ERROR_TEXT, error_date, action, KEY, program_name
                  )
           VALUES (v_error_text, SYSDATE, ip_action, ip_key, ip_program_name
                  );

      COMMIT;
   END insert_error_tab_proc;

/*****************************************************************************/
/*                                                                           */
/* Name:     insert_error_tab_fun                                            */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_error_tab_fun (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      sql_code                   NUMBER;
      sql_err                    VARCHAR2 (300);
      v_error_text               VARCHAR2 (1000);
      v_function_name   CONSTANT VARCHAR2 (200)
                               := v_package_name || '.insert_error_tab_fun()';
   BEGIN
      sql_code := SQLCODE;
      sql_err := SQLERRM;
      v_error_text :=
            'SQL Error Code : '
         || TO_CHAR (sql_code)
         || ' Error Message : '
         || sql_err;

      INSERT INTO error_table
                  (ERROR_TEXT, error_date, action, KEY, program_name
                  )
           VALUES (v_error_text, SYSDATE, ip_action, ip_key, ip_program_name
                  );

      COMMIT;
      RETURN sql_code;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:     insert_pi_hist_fun                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_pi_hist_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_action           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   CONSTANT VARCHAR2 (200)
                                 := v_package_name || '.insert_pi_hist_fun()';
      table_part_inst_rec        table_part_inst%ROWTYPE;
      v_pi_hist_seq              NUMBER;                          -- 06/09/03
   BEGIN
      OPEN toss_cursor_pkg.table_part_inst_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_part_inst_cur
       INTO table_part_inst_rec;

      CLOSE toss_cursor_pkg.table_part_inst_cur;

      sa.sp_seq ('x_pi_hist', v_pi_hist_seq);                     -- 06/09/03

      INSERT INTO table_x_pi_hist
                  (objid, status_hist2x_code_table,
                   x_change_date, x_change_reason, x_cool_end_date,
                   x_creation_date,
                   x_deactivation_flag,
                   x_domain, x_ext,
                   x_insert_date,
                   x_npa, x_nxx,
                   x_old_ext, x_old_npa, x_old_nxx, x_part_bin,
                   x_part_inst_status,
                   x_part_mod,
                   x_part_serial_no,
                   x_part_status,
                   x_pi_hist2carrier_mkt,
                   x_pi_hist2inv_bin,
                   x_pi_hist2part_inst,
                   x_pi_hist2part_mod,
                   x_pi_hist2user,
                   x_pi_hist2x_new_pers,
                   x_pi_hist2x_pers,
                   x_po_num,
                   x_reactivation_flag,
                   x_red_code,
                   x_sequence,
                   x_warr_end_date,
                   dev,
                   fulfill_hist2demand_dtl,
                   part_to_esn_hist2part_inst,
                   x_bad_res_qty,
                   x_date_in_serv,
                   x_good_res_qty,
                   x_last_cycle_ct,
                   x_last_mod_time,
                   x_last_pi_date,
                   x_last_trans_time,
                   x_next_cycle_ct,
                   x_order_number,
                   x_part_bad_qty,
                   x_part_good_qty,
                   x_pi_tag_no,
                   x_pick_request,
                   x_repair_date,
                   x_transaction_id,
                   x_msid
                  )
           VALUES (
                   -- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power (2, 28),
                   -- seq('x_pi_hist'),
                   v_pi_hist_seq, table_part_inst_rec.status2x_code_table,
                   SYSDATE, ip_action, table_part_inst_rec.x_cool_end_date,
                   table_part_inst_rec.x_creation_date,
                   table_part_inst_rec.x_deactivation_flag,
                   table_part_inst_rec.x_domain, table_part_inst_rec.x_ext,
                   table_part_inst_rec.x_insert_date,
                   table_part_inst_rec.x_npa, table_part_inst_rec.x_nxx,
                   NULL, NULL, NULL, table_part_inst_rec.part_bin,
                   table_part_inst_rec.x_part_inst_status,
                   table_part_inst_rec.part_mod,
                   table_part_inst_rec.part_serial_no,
                   table_part_inst_rec.part_status,
                   table_part_inst_rec.part_inst2carrier_mkt,
                   table_part_inst_rec.part_inst2inv_bin,
                   table_part_inst_rec.objid,
                   table_part_inst_rec.n_part_inst2part_mod,
                   table_part_inst_rec.created_by2user,
                   table_part_inst_rec.part_inst2x_new_pers,
                   table_part_inst_rec.part_inst2x_pers,
                   table_part_inst_rec.x_po_num,
                   table_part_inst_rec.x_reactivation_flag,
                   table_part_inst_rec.x_red_code,
                   table_part_inst_rec.x_sequence,
                   table_part_inst_rec.warr_end_date,
                   table_part_inst_rec.dev,
                   table_part_inst_rec.fulfill2demand_dtl,
                   table_part_inst_rec.part_to_esn2part_inst,
                   table_part_inst_rec.bad_res_qty,
                   table_part_inst_rec.date_in_serv,
                   table_part_inst_rec.good_res_qty,
                   table_part_inst_rec.last_cycle_ct,
                   table_part_inst_rec.last_mod_time,
                   table_part_inst_rec.last_pi_date,
                   table_part_inst_rec.last_trans_time,
                   table_part_inst_rec.next_cycle_ct,
                   table_part_inst_rec.x_order_number,
                   table_part_inst_rec.part_bad_qty,
                   table_part_inst_rec.part_good_qty,
                   table_part_inst_rec.pi_tag_no,
                   table_part_inst_rec.pick_request,
                   table_part_inst_rec.repair_date,
                   table_part_inst_rec.transaction_id,
                   table_part_inst_rec.x_msid
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failer inserting swipe',
                                ip_part_serial_no,
                                'TOSS_UTIL_PKG.INSERT_PI_HIST_FUN'
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:     insert_ri_hist_fun                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_ri_hist_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_action           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      table_road_inst_rec        table_x_road_inst%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                 := v_package_name || '.insert_ri_hist_fun()';
      v_ri_hist_seq              NUMBER;                          -- 06/09/03
   BEGIN
      OPEN toss_cursor_pkg.table_road_inst_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_road_inst_cur
       INTO table_road_inst_rec;

      CLOSE toss_cursor_pkg.table_road_inst_cur;

      sa.sp_seq ('x_ri_hist', v_ri_hist_seq);                     -- 06/09/03

      INSERT INTO table_x_road_hist
                  (objid,
                   road_hist2x_code_table, x_change_date,
                   x_change_reason, x_creation_date,
                   x_domain,
                   x_insert_date,
                   x_part_bin,
                   x_part_inst_status,
                   x_part_mod,
                   x_part_serial_no,
                   x_part_status,
                   x_road_hist2inv_bin,
                   x_road_hist2road_inst,
                   x_road_hist2part_mod,
                   x_road_hist2user,
                   x_po_num,
                   x_warr_end_date,
                   x_order_number,
--                                  X_PICK_REQUEST,
                   x_repair_date,
                   x_transaction_id
                  )
           VALUES (
                   -- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power (2, 28),
                   -- seq('x_pi_hist'),
                   v_ri_hist_seq,
                   table_road_inst_rec.rd_status2x_code_table, SYSDATE,
                   ip_action, table_road_inst_rec.x_creation_date,
                   table_road_inst_rec.x_domain,
                   table_road_inst_rec.x_insert_date,
                   table_road_inst_rec.part_bin,
                   table_road_inst_rec.x_part_inst_status,
                   table_road_inst_rec.part_mod,
                   table_road_inst_rec.part_serial_no,
                   table_road_inst_rec.part_status,
                   table_road_inst_rec.road_inst2inv_bin,
                   table_road_inst_rec.objid,
                   table_road_inst_rec.n_road_inst2part_mod,
                   table_road_inst_rec.rd_create2user,
                   table_road_inst_rec.x_po_num,
                   table_road_inst_rec.warr_end_date,
                   table_road_inst_rec.x_order_number,
                   table_road_inst_rec.repair_date,
                   table_road_inst_rec.transaction_id
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting swipe in Road Inst Hist',
                                ip_part_serial_no,
                                'TOSS_UTIL_PKG.INSERT_RI_HIST_FUN'
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:        insert_posa_exception_fun                                    */
/* Description : Available in the specification part of package              */
/*               03/17/03 Removed                                            */
/*****************************************************************************/

   /*****************************************************************************/
/*                                                                           */
/* Name:  is_posa_vendor_fun                                                 */
/* Description : Available in the specification part of package              */
/* 03/07/03  Removed                                                         */
/*   FUNCTION is_posa_vendor_fun (ip_site_id IN VARCHAR2,                    */
/*                                ip_prog_caller IN VARCHAR2)                */
/*****************************************************************************/

   /*****************************************************************************/
/*                                                                           */
/* Name:    is_in_part_inst_fun                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION is_in_part_inst_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      return_value               BOOLEAN                   := FALSE;
      table_part_inst_rec        table_part_inst%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                := v_package_name || '.is_in_part_inst_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_part_inst_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_part_inst_cur
       INTO table_part_inst_rec;

      IF toss_cursor_pkg.table_part_inst_cur%FOUND
      THEN
         --RETURN TRUE;
         return_value := TRUE;
      ELSE
         --RETURN FALSE;
         return_value := FALSE;
      END IF;

      CLOSE toss_cursor_pkg.table_part_inst_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_part_inst_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_part_inst_cur;
         END IF;

         insert_error_tab_proc
                             ('Failed retrieving record from table_part_inst',
                              ip_part_serial_no,
                              ip_prog_caller || v_function_name
                             );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:      get_pi_status_fun                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_pi_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      return_value               VARCHAR2 (80)             := '0';
      table_part_inst_rec        table_part_inst%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                  := v_package_name || '.get_pi_status_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_part_inst_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_part_inst_cur
       INTO table_part_inst_rec;

      IF toss_cursor_pkg.table_part_inst_cur%FOUND
      THEN
         --RETURN table_part_inst_rec.x_part_inst_status;
         return_value := table_part_inst_rec.x_part_inst_status;
      ELSE
         --RETURN NULL;
         --RETURN '0'; -- meaning not found
         return_value := '0';
      END IF;

      CLOSE toss_cursor_pkg.table_part_inst_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_part_inst_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_part_inst_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving phone status',
                                ip_part_serial_no,
                                'TOSS_UTIL_PKG.get_phone_status_fun'
                               );
         --RETURN NULL;
         RETURN TO_CHAR
                      (insert_error_tab_fun ('Failed retrieving phone status',
                                             ip_part_serial_no,
                                             ip_prog_caller || v_function_name
                                            )
                      );
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:      get_ri_status_fun                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_ri_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      return_value               VARCHAR2 (80)               := '0';
      table_road_inst_rec        table_x_road_inst%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                  := v_package_name || '.get_ri_status_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_road_inst_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_road_inst_cur
       INTO table_road_inst_rec;

      IF toss_cursor_pkg.table_road_inst_cur%FOUND
      THEN
         return_value := table_road_inst_rec.x_part_inst_status;
      ELSE
         return_value := '0';
      END IF;

      CLOSE toss_cursor_pkg.table_road_inst_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_road_inst_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_road_inst_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving ri status',
                                ip_part_serial_no,
                                'TOSS_UTIL_PKG.get_ri_status_fun'
                               );
         --RETURN NULL;
         RETURN TO_CHAR (insert_error_tab_fun ('Failed retrieving ri status',
                                               ip_part_serial_no,
                                                  ip_prog_caller
                                               || v_function_name
                                              )
                        );
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:      insert_phone_pi_fun                                            */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_phone_pi_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_upc_code         IN   VARCHAR2,
      ip_login_name       IN   VARCHAR2,
      ip_bin_name         IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      table_part_rec             table_part_num%ROWTYPE;
      table_mod_rec              table_mod_level%ROWTYPE;
      table_inv_rec              table_inv_bin%ROWTYPE;
      table_user_rec             table_user%ROWTYPE;
      table_x_code_rec           table_x_code_table%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                := v_package_name || '.insert_phone_pi_fun()';
      v_pi_phone_seq             NUMBER;                          -- 06/09/03
   BEGIN
      OPEN toss_cursor_pkg.table_part_num_upc_cur (ip_upc_code);

      FETCH toss_cursor_pkg.table_part_num_upc_cur
       INTO table_part_rec;

      CLOSE toss_cursor_pkg.table_part_num_upc_cur;

      OPEN toss_cursor_pkg.table_mod_level_cur (table_part_rec.objid);

      FETCH toss_cursor_pkg.table_mod_level_cur
       INTO table_mod_rec;

      CLOSE toss_cursor_pkg.table_mod_level_cur;

      OPEN toss_cursor_pkg.table_user_cur (ip_login_name);

      FETCH toss_cursor_pkg.table_user_cur
       INTO table_user_rec;

      CLOSE toss_cursor_pkg.table_user_cur;

      OPEN toss_cursor_pkg.table_inv_bin_cur (ip_bin_name);

      FETCH toss_cursor_pkg.table_inv_bin_cur
       INTO table_inv_rec;

      CLOSE toss_cursor_pkg.table_inv_bin_cur;

      OPEN toss_cursor_pkg.table_x_code_cur ('50');

      FETCH toss_cursor_pkg.table_x_code_cur
       INTO table_x_code_rec;

      CLOSE toss_cursor_pkg.table_x_code_cur;

      sa.sp_seq ('x_pi_phone', v_pi_phone_seq);                   -- 06/09/03

      INSERT INTO table_part_inst
                  (objid, part_serial_no, x_part_inst_status, x_sequence,
                   x_po_num, x_red_code, x_order_number, x_creation_date,
                   created_by2user, x_domain, n_part_inst2part_mod,
                   part_inst2inv_bin, part_status, x_insert_date,
                   status2x_code_table,
                   last_pi_date,
                   last_cycle_ct,
                   next_cycle_ct,
                   last_mod_time,
                   last_trans_time,
                   date_in_serv,
                   repair_date
                  )
           VALUES (
                   -- 04/10/03 ( seq_part_inst.nextval + (power (2, 28))),
                   -- seq('part_inst'), 06/09/03
                   v_pi_phone_seq, ip_part_serial_no, '50', 0,
                   'Manual POSA', NULL, NULL, SYSDATE,
                   table_user_rec.objid, 'PHONES', table_mod_rec.objid,
                   table_inv_rec.objid, 'Active', SYSDATE,
                   table_x_code_rec.objid,
                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                   TO_DATE ('01-01-1753', 'DD-MM-YYYY')
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc
                             ('Failed inserting record into table_part_inst',
                              ip_part_serial_no,
                              ip_prog_caller || v_function_name
                             );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:       set_pi_status_fun                                             */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION set_pi_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_status           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      table_x_code_rec           table_x_code_table%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                  := v_package_name || '.set_pi_status_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_x_code_cur (ip_status);

      FETCH toss_cursor_pkg.table_x_code_cur
       INTO table_x_code_rec;

      CLOSE toss_cursor_pkg.table_x_code_cur;

      UPDATE table_part_inst
         SET x_part_inst_status = ip_status,
            status2x_code_table = table_x_code_rec.objid
       WHERE part_serial_no = ip_part_serial_no AND x_domain = ip_domain;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed updating record on table_part_inst',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:       set_ri_status_fun                                             */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION set_ri_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_status           IN   VARCHAR2,
      ip_hist_trg_flag    IN   NUMBER,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      table_x_code_rec           table_x_code_table%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                  := v_package_name || '.set_ri_status_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_x_code_cur (ip_status);

      FETCH toss_cursor_pkg.table_x_code_cur
       INTO table_x_code_rec;

      CLOSE toss_cursor_pkg.table_x_code_cur;

      UPDATE table_x_road_inst
         SET x_part_inst_status = ip_status,
             rd_status2x_code_table = table_x_code_rec.objid
       WHERE part_serial_no = ip_part_serial_no;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc
                              ('Failed updating record on table_x_road_inst',
                               ip_part_serial_no,
                               ip_prog_caller || v_function_name
                              );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:        set_vendor_fun                                               */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION set_vendor_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_vendor           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      table_inv_rec              table_inv_bin%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                     := v_package_name || '.set_vendor_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_inv_bin_cur (ip_vendor);

      FETCH toss_cursor_pkg.table_inv_bin_cur
       INTO table_inv_rec;

      CLOSE toss_cursor_pkg.table_inv_bin_cur;

      UPDATE table_part_inst
         SET part_inst2inv_bin = table_inv_rec.objid
       WHERE part_serial_no = ip_part_serial_no;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed updating vendor on table_part_inst',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:      get_vendor_fun                                                 */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_vendor_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
     ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      table_site_rec             table_site%ROWTYPE;
      return_value               VARCHAR2 (80)        := NULL;
      v_function_name   CONSTANT VARCHAR2 (200)
                                     := v_package_name || '.get_vendor_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_site_cur (ip_part_serial_no, ip_domain);

      FETCH toss_cursor_pkg.table_site_cur
       INTO table_site_rec;

      IF toss_cursor_pkg.table_site_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_site_rec.site_id;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_site_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_site_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_site_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving phone vendor id',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_upc_code                                                     */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_upc_code (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      table_part_rec             table_part_num%ROWTYPE;
      return_value               VARCHAR2 (80)            := NULL;
      v_function_name   CONSTANT VARCHAR2 (200)
                                       := v_package_name || '.get_upc_code()';
   BEGIN
      OPEN toss_cursor_pkg.table_part_num_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_part_num_cur
       INTO table_part_rec;

      IF toss_cursor_pkg.table_part_num_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_part_rec.x_upc;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_part_num_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_part_num_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_part_num_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving upc code',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_rs_upc_code                                                  */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_rs_upc_code (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      table_part_rec             table_part_num%ROWTYPE;
      table_road_inst_rec        table_x_road_inst%ROWTYPE;
      table_mod_level_rec        table_mod_level%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                    := v_package_name || '.get_rs_upc_code()';
      return_value               VARCHAR2 (80)               := NULL;
   BEGIN
      OPEN toss_cursor_pkg.table_road_inst_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_road_inst_cur
       INTO table_road_inst_rec;

      CLOSE toss_cursor_pkg.table_road_inst_cur;

      OPEN toss_cursor_pkg.table_mod_objid_cur
                                    (table_road_inst_rec.n_road_inst2part_mod);

      FETCH toss_cursor_pkg.table_mod_objid_cur
       INTO table_mod_level_rec;

      CLOSE toss_cursor_pkg.table_mod_objid_cur;

      OPEN toss_cursor_pkg.table_part_number_cur
                                      (table_mod_level_rec.part_info2part_num);

      FETCH toss_cursor_pkg.table_part_number_cur
       INTO table_part_rec;

      IF toss_cursor_pkg.table_part_number_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_part_rec.x_upc;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_part_number_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_part_number_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_part_number_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving upc code',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:       set_upc_code_fun                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION set_upc_code_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_upc_code         IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      table_part_rec             table_part_num%ROWTYPE;
      table_mod_rec              table_mod_level%ROWTYPE;
      v_function_name   CONSTANT VARCHAR2 (200)
                                   := v_package_name || '.set_upc_code_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_part_num_upc_cur (ip_upc_code);

      FETCH toss_cursor_pkg.table_part_num_upc_cur
       INTO table_part_rec;

      CLOSE toss_cursor_pkg.table_part_num_upc_cur;

      OPEN toss_cursor_pkg.table_mod_level_cur (table_part_rec.objid);

      FETCH toss_cursor_pkg.table_mod_level_cur
       INTO table_mod_rec;

      CLOSE toss_cursor_pkg.table_mod_level_cur;

      UPDATE table_part_inst
         SET n_part_inst2part_mod = table_mod_rec.objid
       WHERE part_serial_no = ip_part_serial_no;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc
                              ('Failed updating upc code on table_part_inst',
                               ip_part_serial_no,
                               ip_prog_caller || v_function_name
                              );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:       get_redeem_units                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_redeem_units (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      table_part_rec             table_part_num%ROWTYPE;
      return_value               VARCHAR2 (80)            := NULL;
      v_function_name   CONSTANT VARCHAR2 (200)
                                   := v_package_name || '.get_redeem_units()';
   BEGIN
      OPEN toss_cursor_pkg.table_part_num_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_part_num_cur
       INTO table_part_rec;

      IF toss_cursor_pkg.table_part_num_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_part_rec.x_redeem_units;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_part_num_cur;

      RETURN return_value;
  EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_part_num_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_part_num_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving redeem units',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:        get_part_number                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_part_number (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      table_part_rec             table_part_num%ROWTYPE;
      return_value               VARCHAR2 (30)            := NULL;
      v_function_name   CONSTANT VARCHAR2 (200)
                                    := v_package_name || '.get_part_number()';
   BEGIN
      OPEN toss_cursor_pkg.table_part_num_cur (ip_part_serial_no);

      FETCH toss_cursor_pkg.table_part_num_cur
       INTO table_part_rec;

      IF toss_cursor_pkg.table_part_num_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_part_rec.part_number;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_part_num_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_part_num_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_part_num_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving part_number',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:       get_x_code_objid                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_x_code_objid (
      ip_code_number   IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      table_x_code_rec           table_x_code_table%ROWTYPE;
      return_value               NUMBER                       := NULL;
      v_function_name   CONSTANT VARCHAR2 (200)
                                   := v_package_name || '.get_x_code_objid()';
   BEGIN
      OPEN toss_cursor_pkg.table_x_code_cur (ip_code_number);

      FETCH toss_cursor_pkg.table_x_code_cur
       INTO table_x_code_rec;

      IF toss_cursor_pkg.table_x_code_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_x_code_rec.objid;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_x_code_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_x_code_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_x_code_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving x_code objid',
                                ip_code_number,
                                ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:   get_site_type_fun                                                 */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_site_type_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      table_site_rec             table_site%ROWTYPE;
      return_value               VARCHAR2 (80)        := NULL;
      v_function_name   CONSTANT VARCHAR2 (200)
                                  := v_package_name || '.get_site_type_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_site_cur (ip_part_serial_no, ip_domain);

      FETCH toss_cursor_pkg.table_site_cur
       INTO table_site_rec;

      IF toss_cursor_pkg.table_site_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_site_rec.site_type;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_site_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_site_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_site_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving site type',
                                ip_part_serial_no,
                                ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:   part_num_exist_fun                                                */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION part_num_exist_fun (
      ip_part_number   IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name      VARCHAR2 (100)
                                 := v_package_name || '.part_num_exist_fun()';
      return_value         BOOLEAN                  := FALSE;
      table_part_num_rec   table_part_num%ROWTYPE;
   BEGIN
      OPEN toss_cursor_pkg.table_pn_part_cur (ip_part_number);

     FETCH toss_cursor_pkg.table_pn_part_cur
       INTO table_part_num_rec;

      IF toss_cursor_pkg.table_pn_part_cur%FOUND
      THEN
         --RETURN TRUE;
         return_value := TRUE;
      ELSE
         --RETURN FALSE;
         return_value := FALSE;
      END IF;

      CLOSE toss_cursor_pkg.table_pn_part_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_pn_part_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_pn_part_cur;
         END IF;

         insert_error_tab_proc
                              ('Failed retrieving record from table_part_num',
                               ip_part_number,
                               ip_prog_caller || v_function_name
                              );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:   part_mod_exist_fun                                                */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION part_mod_exist_fun (
      ip_ml_level      IN   VARCHAR2,
      ip_ml_pi2pn      IN   NUMBER,
      ip_active        IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name       VARCHAR2 (100)
                                 := v_package_name || '.part_mod_exist_fun()';
      return_value          BOOLEAN                   := FALSE;
      table_mod_level_rec   table_mod_level%ROWTYPE;
   BEGIN
      OPEN toss_cursor_pkg.table_mod_unique_cur (ip_ml_level,
                                                 ip_ml_pi2pn,
                                                 ip_active
                                                );

      FETCH toss_cursor_pkg.table_mod_unique_cur
       INTO table_mod_level_rec;

      IF toss_cursor_pkg.table_mod_unique_cur%FOUND
      THEN
         --RETURN TRUE;
         return_value := TRUE;
      ELSE
         --RETURN FALSE;
         return_value := FALSE;
      END IF;

      CLOSE toss_cursor_pkg.table_mod_unique_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_mod_unique_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_mod_unique_cur;
         END IF;

         insert_error_tab_proc
                             ('Failed retrieving record from table_mod_level',
                              ip_ml_level,
                              ip_prog_caller || v_function_name
                             );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    part_mod_exist_null_fun                                          */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION part_mod_exist_null_fun (
      ip_ml_pi2pn      IN   NUMBER,
      ip_active        IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name       VARCHAR2 (100)
                           := v_package_name || '.part_mod_exists_null_fun()';
      return_value          BOOLEAN                   := FALSE;
      table_mod_level_rec   table_mod_level%ROWTYPE;
   BEGIN
      OPEN toss_cursor_pkg.table_ml_null_cur (ip_ml_pi2pn, ip_active);

      FETCH toss_cursor_pkg.table_ml_null_cur
       INTO table_mod_level_rec;

      IF toss_cursor_pkg.table_ml_null_cur%FOUND
      THEN
         return_value := TRUE;
      ELSE
         return_value := FALSE;
      END IF;

      CLOSE toss_cursor_pkg.table_ml_null_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_ml_null_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_ml_null_cur;
         END IF;

         insert_error_tab_proc
                             ('Failed retrieving record from table_mod_level',
                              ip_ml_pi2pn,
                              ip_prog_caller || v_function_name
                             );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:   x_price_exist_fun                                                 */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION x_price_exist_fun (
      ip_part_num_objid   IN   NUMBER,
      ip_priceline_id     IN   NUMBER,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name       VARCHAR2 (100)
                                  := v_package_name || '.x_price_exist_fun()';
      return_value          BOOLEAN                   := FALSE;
      table_x_pricing_rec   table_x_pricing%ROWTYPE;
   BEGIN
      OPEN toss_cursor_pkg.table_pricing_cur (ip_part_num_objid,
                                              ip_priceline_id
                                             );

      FETCH toss_cursor_pkg.table_pricing_cur
       INTO table_x_pricing_rec;

      IF toss_cursor_pkg.table_pricing_cur%FOUND
      THEN
         --RETURN TRUE;
         return_value := TRUE;
      ELSE
         --RETURN FALSE;
         return_value := FALSE;
      END IF;

      CLOSE toss_cursor_pkg.table_pricing_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_pricing_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_pricing_cur;
         END IF;

         insert_error_tab_proc
                             ('Failed retrieving record from table_x_pricing',
                              ip_part_num_objid,
                              ip_prog_caller || v_function_name
                             );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:   frequency_exist_fun                                               */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION frequency_exist_fun (
      ip_frequency     IN   NUMBER,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name         VARCHAR2 (100)
                                := v_package_name || '.frequency_exist_fun()';
      return_value            BOOLEAN                     := FALSE;
      table_x_frequency_rec   table_x_frequency%ROWTYPE;
   BEGIN
      OPEN toss_cursor_pkg.table_x_frequency_cur (ip_frequency);

      FETCH toss_cursor_pkg.table_x_frequency_cur
       INTO table_x_frequency_rec;

      IF toss_cursor_pkg.table_x_frequency_cur%FOUND
      THEN
         --RETURN TRUE;
         return_value := TRUE;
      ELSE
         --RETURN FALSE;
         return_value := FALSE;
      END IF;

      CLOSE toss_cursor_pkg.table_x_frequency_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_x_frequency_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_x_frequency_cur;
         END IF;

         insert_error_tab_proc
                           ('Failed retrieving record from table_x_frequency',
                            ip_frequency,
                            ip_prog_caller || v_function_name
                           );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:insert_part_num_fun                                                  */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_part_num_fun (
--    OBJID_in                 IN   SA.TABLE_PART_NUM.OBJID%TYPE,
      description_in                IN   sa.table_part_num.description%TYPE,
      s_description_in              IN   sa.table_part_num.s_description%TYPE,
      domain_in                     IN   sa.table_part_num.domain%TYPE,
      s_domain_in                   IN   sa.table_part_num.s_domain%TYPE,
      part_number_in                IN   sa.table_part_num.part_number%TYPE,
      s_part_number_in              IN   sa.table_part_num.s_part_number%TYPE,
      active_in                     IN   sa.table_part_num.active%TYPE,
      part_type_in                  IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in            IN   sa.table_part_num.part_num2domain%TYPE,
      x_dll_in                      IN   sa.table_part_num.x_dll%TYPE,
      x_manufacturer_in             IN   sa.table_part_num.x_manufacturer%TYPE,
      x_redeem_days_in              IN   sa.table_part_num.x_redeem_days%TYPE,
      x_redeem_units_in             IN   sa.table_part_num.x_redeem_units%TYPE,
      x_programmable_flag_in        IN   sa.table_part_num.x_programmable_flag%TYPE,
      x_technology_in               IN   sa.table_part_num.x_technology%TYPE,
      x_upc_in                      IN   sa.table_part_num.x_upc%TYPE,
      part_num2default_preload_in   IN   sa.table_part_num.part_num2default_preload%TYPE,
      x_product_code_in             IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in             IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in     IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_part_num2part_class_in      IN   sa.table_part_num.part_num2part_class%TYPE,
      x_cardless_bundle_in          IN   sa.table_part_num.x_cardless_bundle%TYPE,
      x_data_capable_in             IN   sa.table_part_num.x_data_capable%TYPE,
      --CR4981_4982
      x_conversion_in               IN   sa.table_part_num.x_conversion%TYPE,
      --CR4981_4982
      x_ild_type_in                 IN   sa.table_part_num.x_ild_type%TYPE,
      --CR4981_4982
      x_ota_allowed_in              IN   sa.table_part_num.x_ota_allowed%TYPE,
      --CR4981_4982
      extd_warranty_in              IN   sa.table_part_num.x_extd_warranty%TYPE,
      --CR4981_4982
      ip_prog_caller                IN   VARCHAR2,
      unit_measure_in               IN   sa.table_part_num.unit_measure%TYPE,    --CR21541
      x_card_type_in				in	sa.table_part_num.x_card_type%type,  --CR26500
      device_lock_state_in             IN   sa.table_part_num.device_lock_state%TYPE,   ---CR33844
      rcs_capable_in                IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
               )
      RETURN BOOLEAN
   IS
      v_function_name         VARCHAR2 (100)
                                := v_package_name || '.insert_part_num_fun()';
      v_part_num_seq          NUMBER;                             -- 06/09/03
      --TMODATA START
      v_data_conf_objid       NUMBER;

      CURSOR get_class_data_conf_cur (ip_part_class_objid NUMBER)
      IS
         SELECT dc.objid
           FROM table_x_data_config dc
          WHERE dc.x_part_class_objid = ip_part_class_objid
            AND dc.x_parent_id = 6;

      class_data_conf_rec     get_class_data_conf_cur%ROWTYPE;

      CURSOR get_default_data_conf_cur
      IS
         SELECT dc.objid
           FROM table_x_data_config dc
          WHERE dc.x_parent_id = 6 AND x_default = 1;

      default_data_conf_rec   get_default_data_conf_cur%ROWTYPE;

      --TMODATA END

      --CR11245
      --BRAND_SEP
      CURSOR bus_org_cur
      IS
         SELECT *
           FROM table_bus_org
          WHERE loc_type = NVL (x_product_code_in, 'NA');          --OFS brand

      bus_org_rec             bus_org_cur%ROWTYPE;
--BRAND_SEP
   BEGIN
      OPEN bus_org_cur;

      FETCH bus_org_cur
       INTO bus_org_rec;

      CLOSE bus_org_cur;

      --TMODATA START
      v_data_conf_objid := NULL;

      IF x_data_capable_in = 1
      THEN
         OPEN get_class_data_conf_cur (x_part_num2part_class_in);

         FETCH get_class_data_conf_cur
          INTO class_data_conf_rec;

         IF get_class_data_conf_cur%FOUND
         THEN
            v_data_conf_objid := class_data_conf_rec.objid;
         ELSE
            OPEN get_default_data_conf_cur;

            FETCH get_default_data_conf_cur
             INTO default_data_conf_rec;

            IF get_default_data_conf_cur%FOUND
            THEN
               v_data_conf_objid := default_data_conf_rec.objid;
            END IF;

            CLOSE get_default_data_conf_cur;
         END IF;

         CLOSE get_class_data_conf_cur;
      END IF;

      --TMODATA END
      sa.sp_seq ('part_num', v_part_num_seq);                      -- 06/09/03

      INSERT INTO sa.table_part_num
                  (objid, description, s_description,
                   domain, s_domain, part_number, s_part_number,
                   active, part_type, part_num2domain, x_dll,
                   x_manufacturer, x_redeem_days, x_redeem_units,
                   x_programmable_flag, x_technology, x_upc,
                   part_num2default_preload, x_product_code,
                   x_sourcesystem, x_restricted_use,
                   part_num2x_promotion, part_num2part_class,
                   x_cardless_bundle, x_data_capable,            --CR4981_4982
                                                     x_conversion,
                   --CR4981_4982
                   x_ild_type,                                   --CR4981_4982
                              x_ota_allowed,                     --CR4981_4982
                                            x_extd_warranty,     --CR4981_4982
                   x_meid_phone,                                      --CR6254
                   part_num2x_data_config,                           --TMODATA
--cwl 7/30/12
                   x_card_type,
--cwl 7/30/12
                   part_num2bus_org,                      --CR11245 --BRAND_SEP
                   unit_measure,
                   device_lock_state,   --CR33844
                   rcs_capable
                  )
           VALUES (
--            OBJID_in,
              -- 04/10/03 seq_part_num.nextval + (power (2,28)),
              -- seq('part_num'), 06/09/03
                   v_part_num_seq, description_in, s_description_in,
--cwl 7/30/12
                   decode(domain_in,'BUNDLE',x_sourcesystem_in,domain_in),     -- CR56282 New Part Number Inbound Change
                   decode(s_domain_in,'BUNDLE',x_sourcesystem_in,s_domain_in), -- CR56282 New Part Number Inbound Change
--cwl 7/30/12
                   part_number_in, s_part_number_in,
                   active_in, part_type_in, part_num2domain_in, x_dll_in,
                   x_manufacturer_in, x_redeem_days_in, x_redeem_units_in,
                   x_programmable_flag_in, x_technology_in, x_upc_in,
                   part_num2default_preload_in, x_product_code_in,
                   x_sourcesystem_in, bus_org_rec.status,
                   x_part_num2x_promotion_in, x_part_num2part_class_in,
                   x_cardless_bundle_in, x_data_capable_in,      --CR4981_4982
                                                           x_conversion_in,
                   --CR4981_4982
                   x_ild_type_in,                                --CR4981_4982
                                 x_ota_allowed_in,               --CR4981_4982
                                                  extd_warranty_in,
                   --CR4981_4982
                   DECODE (UPPER (x_sourcesystem_in), 'MEID', 1, 0),  --CR6254
                   v_data_conf_objid,                                --TMODATA
--cwl 7/30/12
                 --  decode(domain_in,'BUNDLE','BUNDLE CARDS',null),                                                                ------- COMMENTED AND ADDED CASE STMT FOR SUREPAY
--cwl 7/30/12
-- MVadlapally CR23513 TracFone SurePay for Android
                     x_card_type_in, --CR26500
-- MVadlapally CR23513 TracFone SurePay for Android
                   bus_org_rec.objid,                              --BRAND_SEP
                   unit_measure_in ,
                   device_lock_state_in,                          --CR33844
                   rcs_capable_in                                 -- CR53920_RCS_Flag_clfy_DDL
                   );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting part number',
                                part_number_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

       /* TABLE_PART_NUM_INS */
/*****************************************************************************/
/*                                                                           */
/* Name:insert_part_num_fun_ph                                                  */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_part_num_fun_ph (
      description_in              IN   sa.table_part_num.description%TYPE,
      s_description_in            IN   sa.table_part_num.s_description%TYPE,
      domain_in                   IN   sa.table_part_num.domain%TYPE,
      s_domain_in                 IN   sa.table_part_num.s_domain%TYPE,
      part_number_in              IN   sa.table_part_num.part_number%TYPE,
      s_part_number_in            IN   sa.table_part_num.s_part_number%TYPE,
      active_in                   IN   sa.table_part_num.active%TYPE,
      part_type_in                IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in          IN   sa.table_part_num.part_num2domain%TYPE,
      x_redeem_days_in            IN   sa.table_part_num.x_redeem_days%TYPE,
      x_redeem_units_in           IN   sa.table_part_num.x_redeem_units%TYPE,
      x_programmable_flag_in      IN   sa.table_part_num.x_programmable_flag%TYPE,
      x_upc_in                    IN   sa.table_part_num.x_upc%TYPE,
      x_product_code_in           IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in           IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in   IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_part_num2part_class_in    IN   sa.table_part_num.part_num2part_class%TYPE,
      x_cardless_bundle_in        IN   sa.table_part_num.x_cardless_bundle%TYPE,
      ip_prog_caller              IN   VARCHAR2,
      x_card_plan_in              IN   sa.table_part_num.x_card_plan%TYPE,       -- CR27270
      device_lock_state_in           IN   sa.table_part_num.device_lock_state%TYPE,   ---CR33844
      rcs_capable_in              IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
   )
      RETURN BOOLEAN
   IS
      v_function_name                  VARCHAR2 (100)
                                := v_package_name || '.insert_part_num_fun()';
      v_part_num_seq                   NUMBER;                    -- 06/09/03
      v_data_conf_objid                NUMBER;
      l_dll                            VARCHAR2 (200);
      l_ild_type                       VARCHAR2 (200);
      l_technology                     VARCHAR2 (200);
      l_meid_phone                     VARCHAR2 (200);
      l_manufacturer                   VARCHAR2 (200);
      l_data_capable                   VARCHAR2 (200);
      l_initial_motricity_conversion   VARCHAR2 (200);
      l_ota_allowed                    VARCHAR2 (200);
      l_extd_warranty                  VARCHAR2 (200);
      l_preloaded_click_id             VARCHAR2 (200);
      l_default_click_id               VARCHAR2 (200);
      l_preloaded_data_config          VARCHAR2 (200);
      l_frequency_1                    VARCHAR2 (200);
      l_frequency_2                    VARCHAR2 (200);
      l_restricted_use                 VARCHAR2 (200);

      --CR11245
      --BRAND_SEP
      CURSOR bus_org_cur
      IS
         SELECT *
           FROM table_bus_org
          WHERE loc_type = NVL (x_product_code_in, 'NA');         --OFS brand

      bus_org_rec                      bus_org_cur%ROWTYPE;

--BRAND_SEP

   BEGIN
      OPEN bus_org_cur;

      FETCH bus_org_cur
       INTO bus_org_rec;

      CLOSE bus_org_cur;

      DBMS_OUTPUT.put_line ('inside insert_part_num_fun_ph');
      lf_get_part_num_vals (x_part_num2part_class_in,
                            domain_in,
                            l_restricted_use,
                            l_dll,
                            l_ild_type,
                            l_technology,
                            l_meid_phone,
                            l_manufacturer,
                            l_data_capable,
                            l_initial_motricity_conversion,
                            l_ota_allowed,
                            l_extd_warranty,
                            l_preloaded_click_id,
                            l_default_click_id,
                            l_preloaded_data_config,
                            l_frequency_1,
                            l_frequency_2
                           );



      DBMS_OUTPUT.put_line ('inside insert_part_num_fun_ph 0');
      v_data_conf_objid := NULL;
      DBMS_OUTPUT.put_line ('l_data_capable:' || l_data_capable);

      IF l_data_capable = '1'
      THEN
         OPEN get_class_data_conf_cur (x_part_num2part_class_in);

         FETCH get_class_data_conf_cur
          INTO class_data_conf_rec;

         IF get_class_data_conf_cur%FOUND
         THEN
            v_data_conf_objid := class_data_conf_rec.objid;
         ELSE
            OPEN get_default_data_conf_cur;

            FETCH get_default_data_conf_cur
             INTO default_data_conf_rec;

            IF get_default_data_conf_cur%FOUND
            THEN
               v_data_conf_objid := default_data_conf_rec.objid;
            END IF;

            CLOSE get_default_data_conf_cur;
         END IF;

        CLOSE get_class_data_conf_cur;
      END IF;

      DBMS_OUTPUT.put_line ('inside insert_part_num_fun_ph 1');
      sa.sp_seq ('part_num', v_part_num_seq);                      -- 06/09/03
      DBMS_OUTPUT.put_line ('inside insert_part_num_fun_ph 2');

      INSERT INTO sa.table_part_num
                  (objid, description, s_description,
                   domain, s_domain, part_number, s_part_number,
                   active, part_type, part_num2domain, x_dll,
                   x_manufacturer, x_redeem_days, x_redeem_units,
                   x_programmable_flag, x_technology, x_upc,
                   part_num2default_preload, x_product_code,
                   x_sourcesystem, x_restricted_use,
                   part_num2x_promotion, part_num2part_class,
                   x_cardless_bundle, x_data_capable,            --CR4981_4982
                   x_conversion,                                 --CR4981_4982
                                x_ild_type,                      --CR4981_4982
                                           x_ota_allowed,        --CR4981_4982
                   x_extd_warranty,                              --CR4981_4982
                                   x_meid_phone,                      --CR6254
                                                part_num2x_data_config,
                   --TMODATA
                   part_num2bus_org,                                --BRAND_SEP
                   x_card_plan,                              -- CR27270
                   device_lock_state,
                   rcs_capable                               -- CR53920_RCS_Flag_clfy_DDL
                  )
           VALUES (v_part_num_seq, description_in, s_description_in,
                   domain_in, s_domain_in, part_number_in, s_part_number_in,
                   active_in, part_type_in, part_num2domain_in, l_dll,
                   l_manufacturer, x_redeem_days_in, x_redeem_units_in,
                   x_programmable_flag_in, l_technology, x_upc_in,
                   null, x_product_code_in,
                   x_sourcesystem_in, bus_org_rec.status,
                   x_part_num2x_promotion_in, x_part_num2part_class_in,
                   x_cardless_bundle_in, l_data_capable,         --CR4981_4982
                   l_initial_motricity_conversion,               --CR4981_4982
                                                  l_ild_type,    --CR4981_4982
                                                             l_ota_allowed,
                   --CR4981_4982
                   l_extd_warranty,                              --CR4981_4982
                                   l_meid_phone,                      --CR6254
                                                v_data_conf_objid,   --TMODATA
                   bus_org_rec.objid,                               --BRAND_SEP
                   x_card_plan_in ,                          -- CR27270
                   device_lock_state_in,                         --CR33844
                   rcs_capable_in                            -- CR53920_RCS_Flag_clfy_DDL
                  );

      DBMS_OUTPUT.put_line ('inside insert_part_num_fun_ph 3');

      IF LTRIM (l_frequency_1) IS NOT NULL
      THEN
         -- CR10046 SWITCH OBJIDS IN MTM
         -- insert into SA.MTM_PART_NUM14_X_FREQUENCY0(PART_NUM2X_FREQUENCY, X_FREQUENCY2PART_NUM)
         INSERT INTO sa.mtm_part_num14_x_frequency0
                     (x_frequency2part_num,
                      part_num2x_frequency
                     )
              VALUES ((SELECT objid
                         FROM table_x_frequency
                        WHERE x_frequency = TO_NUMBER (l_frequency_1)),
                      v_part_num_seq
                     );
      END IF;

      DBMS_OUTPUT.put_line ('inside insert_part_num_fun_ph 4');

      IF LTRIM (l_frequency_2) IS NOT NULL
      THEN
         -- CR10046 SWITCH OBJIDS IN MTM
         -- insert into SA.MTM_PART_NUM14_X_FREQUENCY0(PART_NUM2X_FREQUENCY, X_FREQUENCY2PART_NUM)
         INSERT INTO sa.mtm_part_num14_x_frequency0
                     (x_frequency2part_num,
                      part_num2x_frequency
                     )
              VALUES ((SELECT objid
                         FROM table_x_frequency
                        WHERE x_frequency = TO_NUMBER (l_frequency_2)),
                      v_part_num_seq
                     );
      END IF;

      DBMS_OUTPUT.put_line ('inside insert_part_num_fun_ph 5');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting part number',
                                part_number_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/* TABLE_PART_NUM_INS */

   /*****************************************************************************/
/*                                                                           */
/* Name:    update_part_num_fun                                              */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION update_part_num_fun (
      domain_in                   IN   sa.table_part_num.domain%TYPE,
      part_number_in              IN   sa.table_part_num.part_number%TYPE,
      s_domain_in                 IN   sa.table_part_num.s_domain%TYPE,
      part_type_in                IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in          IN   sa.table_part_num.part_num2domain%TYPE,
      x_manufacturer_in           IN   sa.table_part_num.x_manufacturer%TYPE,
      x_technology_in             IN   sa.table_part_num.x_technology%TYPE,
      x_upc_in                    IN   sa.table_part_num.x_upc%TYPE,
      x_product_code_in           IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in           IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in   IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_cardless_bundle_in        IN   sa.table_part_num.x_cardless_bundle%TYPE,
      x_data_capable_in           IN   sa.table_part_num.x_data_capable%TYPE,
      --CR4981_4982
      x_conversion_in             IN   sa.table_part_num.x_conversion%TYPE,
      --CR4981_4982
      x_ild_type_in               IN   sa.table_part_num.x_ild_type%TYPE,
      --CR4981_4982
      x_ota_allowed_in            IN   sa.table_part_num.x_ota_allowed%TYPE,
      --CR4981_4982
      x_extd_warranty_in          IN   sa.table_part_num.x_extd_warranty%TYPE,
      --CR4981_4982
      ip_prog_caller              IN   VARCHAR2,
      x_part_num2part_class_in    IN   NUMBER,
      unit_measure_in             IN   sa.table_part_num.unit_measure%TYPE,
	    x_card_type_in			        IN   sa.table_part_num.x_card_type%TYPE,  --CR26500
      x_card_plan_in              IN   sa.table_part_num.x_card_plan%TYPE,       -- CR27270
      description_in              IN   sa.table_part_num.description%TYPE,       -- CR30292
      s_description_in            IN   sa.table_part_num.s_description%TYPE,       -- CR30292
      x_redeem_days_in            IN   sa.table_part_num.x_redeem_days%TYPE,       -- CR30292
      x_redeem_units_in           IN   sa.table_part_num.x_redeem_units%TYPE,       -- CR30292
      x_programmable_flag_in      IN   sa.table_part_num.x_programmable_flag%TYPE,       -- CR30292
      device_lock_state_in         IN   sa.table_part_num.device_lock_state%TYPE,    ---CR33844
      rcs_capable_in              IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
   )
      RETURN BOOLEAN
   IS
      CURSOR find_cur_part_num_curs
      IS
         SELECT objid
           FROM table_part_num
          WHERE domain = domain_in AND part_number = part_number_in;

      find_cur_part_num_rec            find_cur_part_num_curs%ROWTYPE;
      v_function_name                  VARCHAR2 (100)
                                := v_package_name || '.update_part_num_fun()';
      v_data_conf_objid                NUMBER                         := NULL;
      l_restricted_use                 VARCHAR2 (200);
      l_dll                            VARCHAR2 (200);
      l_ild_type                       VARCHAR2 (200);
      l_technology                     VARCHAR2 (200);
      l_meid_phone                     VARCHAR2 (200);
      l_manufacturer                   VARCHAR2 (200);
      l_data_capable                   VARCHAR2 (200);
      l_initial_motricity_conversion   VARCHAR2 (200);
      l_ota_allowed                    VARCHAR2 (200);
      l_extd_warranty                  VARCHAR2 (200);
      l_preloaded_click_id             VARCHAR2 (200);
      l_default_click_id               VARCHAR2 (200);
      l_preloaded_data_config          VARCHAR2 (200);
      l_frequency_1                    VARCHAR2 (200);
      l_frequency_2                    VARCHAR2 (200);

      --CR11245
      --BRAND_SEP
      CURSOR bus_org_cur
      IS
         SELECT *
           FROM table_bus_org
          WHERE loc_type = NVL (x_product_code_in, 'NA');         --OFS brand

      bus_org_rec                      bus_org_cur%ROWTYPE;
   --BRAND_SEP
   BEGIN
      OPEN bus_org_cur;

      FETCH bus_org_cur
       INTO bus_org_rec;

      CLOSE bus_org_cur;
dbms_output.put_line('part_num2domain_in:'||part_num2domain_in);
        UPDATE sa.table_part_num
           SET --cwl 7/30/12
               domain            =
                   NVL (DECODE (domain_in, 'BUNDLE', x_sourcesystem_in, domain_in), domain),  -- CR49104_Part_Number_Inbound_Change
               s_domain          =
                   NVL (DECODE (s_domain_in, 'BUNDLE', x_sourcesystem_in, domain_in), s_domain), -- CR49104_Part_Number_Inbound_Change
               --    x_card_type = decode(s_domain_in,'BUNDLE','BUNDLE CARDS',null),                                                                ------- COMMENTED AND ADDED CASE STMT FOR SUREPAY
               --cwl 7/30/12
               -- MVadlapally CR23513 TracFone SurePay for Android
               x_card_type       = x_card_type_in,                                                 --CR26500
               -- MVadlapally CR23513 TracFone SurePay for Android

               part_type         = NVL (part_type_in, part_type),
               --             part_num2domain = NVL (part_num2domain_in, part_num2domain),
               part_num2domain   = part_num2domain_in,
               part_num2part_class = NVL (x_part_num2part_class_in, part_num2part_class),
               x_manufacturer    = NVL (x_manufacturer_in, x_manufacturer),
               x_technology      = NVL (x_technology_in, x_technology),
               x_upc             = NVL (x_upc_in, x_upc),
               x_product_code    = NVL (x_product_code_in, x_product_code),
               x_sourcesystem    = NVL (x_sourcesystem_in, x_sourcesystem),
               part_num2x_promotion = DECODE (x_part_num2x_promotion_in,
                                       '-1', '',
                                       NULL, part_num2x_promotion,
                                       x_part_num2x_promotion_in),
               x_cardless_bundle = NVL (x_cardless_bundle_in, x_cardless_bundle),
               x_data_capable    = NVL (x_data_capable_in, x_data_capable),
               x_conversion      = NVL (x_conversion_in, x_conversion),
               x_ild_type        = NVL (x_ild_type_in, x_ild_type),
               x_ota_allowed     = NVL (x_ota_allowed_in, x_ota_allowed),
               x_extd_warranty   = NVL (x_extd_warranty_in, x_extd_warranty),
               x_meid_phone      = DECODE (UPPER (NVL (x_sourcesystem_in, x_sourcesystem)), 'MEID', 1, 0), --CR6254
               x_restricted_use  = bus_org_rec.status,
               part_num2bus_org  = bus_org_rec.objid,                                            --BRAND_SEP
               unit_measure      = unit_measure_in,
               --x_card_plan       = NVL (x_card_plan_in, x_card_plan),                              -- CR27270
               x_card_plan       = x_card_plan_in,                              -- Modified for CR44408 issue 2 to delete existing card plan
         --cwl 8/16/2012
               description        = NVL(description_in,description),
               s_description      = NVL(s_description_in,s_description),
               x_redeem_days      = NVL(x_redeem_days_in,x_redeem_days),
               x_redeem_units     = NVL(x_redeem_units_in,x_redeem_units),
               x_programmable_flag = NVL(x_programmable_flag_in,x_programmable_flag),
               device_lock_state   = NVL(device_lock_state_in,device_lock_state),
               rcs_capable         = NVL(rcs_capable_in,rcs_capable)      --CR53920_RCS_Flag_clfy_DDL
         WHERE 1 = 1                                                                    --domain = domain_in
           AND part_number = part_number_in;

      IF domain_in IN ('ACC', 'PHONES', 'VAS')
      THEN
         OPEN find_cur_part_num_curs;

         FETCH find_cur_part_num_curs
          INTO find_cur_part_num_rec;

         CLOSE find_cur_part_num_curs;

         lf_get_part_num_vals (x_part_num2part_class_in,
                               domain_in,
                               l_restricted_use,
                               l_dll,
                               l_ild_type,
                               l_technology,
                               l_meid_phone,
                               l_manufacturer,
                               l_data_capable,
                               l_initial_motricity_conversion,
                               l_ota_allowed,
                               l_extd_warranty,
                               l_preloaded_click_id,
                               l_default_click_id,
                               l_preloaded_data_config,
                               l_frequency_1,
                               l_frequency_2
                              );
         DBMS_OUTPUT.put_line ('update inside insert_part_num_fun_ph 0');
         DBMS_OUTPUT.put_line ('l_data_capable:' || l_data_capable);

         IF l_data_capable = 1
         THEN
            OPEN get_class_data_conf_cur (x_part_num2part_class_in);

            FETCH get_class_data_conf_cur
             INTO class_data_conf_rec;

            IF get_class_data_conf_cur%FOUND
            THEN
               v_data_conf_objid := class_data_conf_rec.objid;
            ELSE
               OPEN get_default_data_conf_cur;

               FETCH get_default_data_conf_cur
                INTO default_data_conf_rec;

               IF get_default_data_conf_cur%FOUND
               THEN
                  v_data_conf_objid := default_data_conf_rec.objid;
               END IF;

               CLOSE get_default_data_conf_cur;
            END IF;

            CLOSE get_class_data_conf_cur;
         END IF;

         DBMS_OUTPUT.put_line ('inside update_part_num_fun_ph 2');

         UPDATE sa.table_part_num
            SET x_dll = l_dll,
                x_manufacturer = l_manufacturer,
                x_technology = l_technology,
                x_restricted_use = bus_org_rec.status,
                x_data_capable = l_data_capable,
                x_conversion = l_initial_motricity_conversion,
                x_ild_type = l_ild_type,
                x_ota_allowed = l_ota_allowed,
                x_extd_warranty = l_extd_warranty,
                x_meid_phone = l_meid_phone,
                part_num2x_data_config = v_data_conf_objid,
                part_num2part_class = x_part_num2part_class_in,
                part_num2bus_org = bus_org_rec.objid,               --BRAND_SEP
                device_lock_state= device_lock_state_in,         --CR33844
                rcs_capable = rcs_capable_in                     -- CR53920_RCS_Flag_clfy_DDL
          WHERE domain = domain_in AND part_number = part_number_in;

         DBMS_OUTPUT.put_line ('inside update_part_num_fun_ph 3');

         DELETE FROM sa.mtm_part_num14_x_frequency0
               WHERE part_num2x_frequency = find_cur_part_num_rec.objid;

         -- CR10046 SWITCH OBJIDS IN MTM
         -- where X_FREQUENCY2PART_NUM = find_cur_part_num_rec.objid;
         IF LTRIM (l_frequency_1) IS NOT NULL
         THEN
            -- CR10046 SWITCH OBJIDS IN MTM
            -- insert into SA.MTM_PART_NUM14_X_FREQUENCY0(PART_NUM2X_FREQUENCY, X_FREQUENCY2PART_NUM)
            INSERT INTO sa.mtm_part_num14_x_frequency0
                        (x_frequency2part_num,
                         part_num2x_frequency
                        )
                 VALUES ((SELECT objid
                            FROM table_x_frequency
                           WHERE x_frequency = TO_NUMBER (l_frequency_1)),
                         find_cur_part_num_rec.objid
                        );
         END IF;

         DBMS_OUTPUT.put_line ('inside update_part_num_fun_ph 4');

         IF LTRIM (l_frequency_2) IS NOT NULL
         THEN
            INSERT INTO sa.mtm_part_num14_x_frequency0
                        (x_frequency2part_num,
                         part_num2x_frequency
                        )
                 -- CR10046 SWITCH OBJIDS IN MTM
                 -- insert into SA.MTM_PART_NUM14_X_FREQUENCY0(PART_NUM2X_FREQUENCY, X_FREQUENCY2PART_NUM)
            VALUES      ((SELECT objid
                            FROM table_x_frequency
                           WHERE x_frequency = TO_NUMBER (l_frequency_2)),
                         find_cur_part_num_rec.objid
                        );
         END IF;

         DBMS_OUTPUT.put_line ('inside update_part_num_fun_ph 5');
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed updating part number',
                                part_number_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;
/*****************************************************************************/
/*                                                                           */
/* Name:    update_part_num_fun                                              */
/* Description : Wrapper for original update.. Created as TAS team can not change signature now  */
/*****************************************************************************/
  FUNCTION update_part_num_fun (
      domain_in                   IN   sa.table_part_num.domain%TYPE,
      part_number_in              IN   sa.table_part_num.part_number%TYPE,
      s_domain_in                 IN   sa.table_part_num.s_domain%TYPE,
      part_type_in                IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in          IN   sa.table_part_num.part_num2domain%TYPE,
      x_manufacturer_in           IN   sa.table_part_num.x_manufacturer%TYPE,
      x_technology_in             IN   sa.table_part_num.x_technology%TYPE,
      x_upc_in                    IN   sa.table_part_num.x_upc%TYPE,
      x_product_code_in           IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in           IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in   IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_cardless_bundle_in        IN   sa.table_part_num.x_cardless_bundle%TYPE,
      x_data_capable_in           IN   sa.table_part_num.x_data_capable%TYPE, --CR4981_4982
      x_conversion_in             IN   sa.table_part_num.x_conversion%TYPE,   --CR4981_4982
      x_ild_type_in               IN   sa.table_part_num.x_ild_type%TYPE,     --CR4981_4982
      x_ota_allowed_in            IN   sa.table_part_num.x_ota_allowed%TYPE,  --CR4981_4982
      x_extd_warranty_in          IN   sa.table_part_num.x_extd_warranty%TYPE,--CR4981_4982
      ip_prog_caller              IN   VARCHAR2,
      x_part_num2part_class_in    in   number,
      unit_measure_in             IN   sa.table_part_num.unit_measure%TYPE,
      x_card_type_in              IN   sa.table_part_num.x_card_type%TYPE,  --CR26500
      x_card_plan_in              IN   sa.table_part_num.x_card_plan%TYPE,       -- CR27270
      device_lock_state_in           IN   sa.table_part_num.device_lock_state%TYPE,   ---CR33844
      rcs_capable_in              IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
   )
      RETURN BOOLEAN
   IS
      v_output BOOLEAN;
   BEGIN

   v_output := TOSS_UTIL_PKG.update_part_num_fun (
			  domain_in 						--domain_in                   IN   sa.table_part_num.domain%TYPE,
			  ,part_number_in					--part_number_in              IN   sa.table_part_num.part_number%TYPE,
			  ,s_domain_in						--s_domain_in                 IN   sa.table_part_num.s_domain%TYPE,
			  ,part_type_in						--part_type_in                IN   sa.table_part_num.part_type%TYPE,
			  ,part_num2domain_in				--part_num2domain_in          IN   sa.table_part_num.part_num2domain%TYPE,
			  ,x_manufacturer_in				--x_manufacturer_in           IN   sa.table_part_num.x_manufacturer%TYPE,
			  ,x_technology_in					--x_technology_in             IN   sa.table_part_num.x_technology%TYPE,
			  ,x_upc_in							--x_upc_in                    IN   sa.table_part_num.x_upc%TYPE,
			  ,x_product_code_in				--x_product_code_in           IN   sa.table_part_num.x_product_code%TYPE,
			  ,x_sourcesystem_in				--x_sourcesystem_in           IN   sa.table_part_num.x_sourcesystem%TYPE,
			  ,x_part_num2x_promotion_in		--x_part_num2x_promotion_in   IN   sa.table_part_num.part_num2x_promotion%TYPE,
			  ,x_cardless_bundle_in				--x_cardless_bundle_in        IN   sa.table_part_num.x_cardless_bundle%TYPE,
			  ,x_data_capable_in				--x_data_capable_in           IN   sa.table_part_num.x_data_capable%TYPE,
			  ,x_conversion_in					--x_conversion_in             IN   sa.table_part_num.x_conversion%TYPE,
			  ,x_ild_type_in					--x_ild_type_in               IN   sa.table_part_num.x_ild_type%TYPE,
			  ,x_ota_allowed_in					--x_ota_allowed_in            IN   sa.table_part_num.x_ota_allowed%TYPE,
			  ,x_extd_warranty_in				--x_extd_warranty_in          IN   sa.table_part_num.x_extd_warranty%TYPE,
			  ,ip_prog_caller					--ip_prog_caller              IN   VARCHAR2,
			  ,x_part_num2part_class_in			--x_part_num2part_class_in    IN   NUMBER,
			  ,unit_measure_in					--unit_measure_in             IN   sa.table_part_num.unit_measure%TYPE,
			  ,x_card_type_in					--x_card_type_in			        IN   sa.table_part_num.x_card_type%TYPE,  --CR26500
			  ,x_card_plan_in					--x_card_plan_in              IN   sa.table_part_num.x_card_plan%TYPE,       -- CR27270
			  ,NULL								--description_in              IN   sa.table_part_num.description%TYPE,       -- CR30292
			  ,NULL								--s_description_in            IN   sa.table_part_num.s_description%TYPE,       -- CR30292
			  ,NULL								--x_redeem_days_in            IN   sa.table_part_num.x_redeem_days%TYPE,       -- CR30292
			  ,NULL								--x_redeem_units_in           IN   sa.table_part_num.x_redeem_units%TYPE,       -- CR30292
			  ,NULL								--x_programmable_flag_in      IN   sa.table_part_num.x_programmable_flag%TYPE       -- CR30292
        ,device_lock_state_in --device_lock_state_in           IN   sa.table_part_num.device_lock_state%TYPE    ---CR33844
        ,rcs_capable_in       --rcs_capable_in                 IN   sa.table_part_num.rcs_capable%TYPE          -- CR53920_RCS_Flag_clfy_DDL
   );
    RETURN v_output;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;
/*****************************************************************************/
/*                                                                           */
/* Name:    insert_mod_level_fun                                             */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_mod_level_fun (
--    OBJID_in                IN   SA.TABLE_MOD_LEVEL.OBJID%TYPE,
      mod_level_in            IN   sa.table_mod_level.mod_level%TYPE,
      s_mod_level_in          IN   sa.table_mod_level.s_mod_level%TYPE,
      active_in               IN   sa.table_mod_level.active%TYPE,
      eff_date_in             IN   sa.table_mod_level.eff_date%TYPE,
      part_info2part_num_in   IN   sa.table_mod_level.part_info2part_num%TYPE,
      x_timetank_in           IN   sa.table_mod_level.x_timetank%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                                := v_package_name || 'insert_mod_level_fun()';
      v_mod_level_seq   NUMBER;                                   -- 06/09/03
   BEGIN
      sa.sp_seq ('mod_level', v_mod_level_seq);                   -- 06/09/03

      INSERT INTO sa.table_mod_level
                  (objid, mod_level, s_mod_level, active,
                   eff_date, part_info2part_num, x_timetank
                  )
           VALUES (
              -- 04/10/03   seq_mod_level.nextval + (power (2,28)),
              -- seq('mod_level'),
--            OBJID_in,
                   v_mod_level_seq, mod_level_in, s_mod_level_in, active_in,
                   eff_date_in, part_info2part_num_in, x_timetank_in
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting mod level',
                                   mod_level_in
                                || '-'
                                || TO_CHAR (part_info2part_num_in),
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_mod_level_fun                                             */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION update_mod_level_fun (
      -- OBJID_in                IN   SA.TABLE_MOD_LEVEL.OBJID%TYPE,
      update_for_null_in      IN   BOOLEAN,
      mod_level_in            IN   sa.table_mod_level.mod_level%TYPE,
      s_mod_level_in          IN   sa.table_mod_level.s_mod_level%TYPE,
      active_in               IN   sa.table_mod_level.active%TYPE,
      eff_date_in             IN   sa.table_mod_level.eff_date%TYPE,
      part_info2part_num_in   IN   sa.table_mod_level.part_info2part_num%TYPE,
      x_timetank_in           IN   sa.table_mod_level.x_timetank%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name     VARCHAR2 (100)
                                := v_package_name || 'update_mod_level_fun()';
      table_ml_null_rec   table_mod_level%ROWTYPE;
   BEGIN
      IF NOT (update_for_null_in)
      THEN
         UPDATE sa.table_mod_level
            SET mod_level = NVL (mod_level_in, mod_level),
                s_mod_level = NVL (s_mod_level_in, s_mod_level),
                active = NVL (active_in, active),
                eff_date = NVL (eff_date_in, eff_date),
                x_timetank = NVL (x_timetank_in, x_timetank)
          WHERE part_info2part_num = part_info2part_num_in
            AND active = active_in
			;
      ELSE
         OPEN toss_cursor_pkg.table_ml_null_cur (part_info2part_num_in,
                                                 active_in
                                                );

         FETCH toss_cursor_pkg.table_ml_null_cur
          INTO table_ml_null_rec;

         IF toss_cursor_pkg.table_ml_null_cur%FOUND
         THEN
            UPDATE sa.table_mod_level
               SET mod_level = NVL (mod_level_in, mod_level),
                   s_mod_level = NVL (s_mod_level_in, s_mod_level),
                   active = NVL (active_in, active),
                   eff_date = NVL (eff_date_in, eff_date),
                   x_timetank = NVL (x_timetank_in, x_timetank)
             WHERE objid = table_ml_null_rec.objid;
         END IF;

         CLOSE toss_cursor_pkg.table_ml_null_cur;
      END IF;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_ml_null_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_ml_null_cur;
         END IF;

         insert_error_tab_proc ('Failed updating mod level',
                                   mod_level_in
                                || '-'
                                || TO_CHAR (part_info2part_num_in),
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_interface_jobs_fun                                        */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_interface_jobs_fun (
      program_name_in     IN   sa.x_toss_interface_jobs.program_name%TYPE,
      start_date_in       IN   sa.x_toss_interface_jobs.start_date%TYPE,
      end_date_in         IN   sa.x_toss_interface_jobs.end_date%TYPE,
      rows_processed_in   IN   sa.x_toss_interface_jobs.rows_processed%TYPE,
      status_in           IN   sa.x_toss_interface_jobs.status%TYPE,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                           := v_package_name || 'insert_interface_jobs_fun()';
   BEGIN
      INSERT INTO sa.x_toss_interface_jobs
                  (objid, program_name,
                   start_date, end_date, rows_processed, status
                  )
           VALUES (sa.seq_x_interface_jobs.NEXTVAL, program_name_in,
                   start_date_in, end_date_in, rows_processed_in, status_in
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting interface_jobs',
                                program_name_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_interface_jobs_fun                                        */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION update_interface_jobs_fun (
      program_name_in     IN   sa.x_toss_interface_jobs.program_name%TYPE,
      start_date_in       IN   sa.x_toss_interface_jobs.start_date%TYPE,
      end_date_in         IN   sa.x_toss_interface_jobs.end_date%TYPE,
      rows_processed_in   IN   sa.x_toss_interface_jobs.rows_processed%TYPE,
      status_in           IN   sa.x_toss_interface_jobs.status%TYPE,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                           := v_package_name || 'update_interface_jobs_fun()';
   BEGIN
      UPDATE sa.x_toss_interface_jobs
         SET program_name = NVL (program_name_in, program_name),
             start_date = NVL (start_date_in, start_date),
             end_date = NVL (end_date_in, end_date),
             rows_processed = NVL (rows_processed_in, rows_processed),
             status = NVL (status_in, status)
       WHERE program_name = program_name_in;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed updating interface_jobs',
                                program_name_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/* Name:    insert_pricing_fun                                               */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_pricing_fun (
      x_start_date_in         IN   sa.table_x_pricing.x_start_date%TYPE,
      x_end_date_in           IN   sa.table_x_pricing.x_end_date%TYPE,
      x_web_link_in           IN   sa.table_x_pricing.x_web_link%TYPE,
      x_web_description_in    IN   sa.table_x_pricing.x_web_description%TYPE,
      x_retail_price_in       IN   sa.table_x_pricing.x_retail_price%TYPE,
      x_channel_in            IN   sa.table_x_pricing.x_channel%TYPE,
                                                                --   BRAND_SEP
      x_pricing2part_num_in   IN   sa.table_x_pricing.x_pricing2part_num%TYPE,
      x_fin_priceline_id_in   IN   sa.table_x_pricing.x_fin_priceline_id%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN
  IS
      v_function_name   VARCHAR2 (100)
                                  := v_package_name || 'insert_pricing_fun()';
      v_pricing_seq     NUMBER;

      --BRAND_SEP
      CURSOR brand_cur
      IS
         SELECT org_id
           FROM table_bus_org bo, table_part_num pn
          WHERE bo.objid = pn.part_num2bus_org
            AND pn.objid = x_pricing2part_num_in;

      brand_rec         brand_cur%ROWTYPE;
      v_brand_name      VARCHAR2 (30);
      v_x_type          VARCHAR2 (30)       DEFAULT NULL;
   BEGIN
      OPEN brand_cur;

      FETCH brand_cur
       INTO brand_rec;

      IF brand_cur%FOUND
      THEN
         v_brand_name := brand_rec.org_id;
      ELSE
         v_brand_name := 'GENERIC';
      END IF;

      CLOSE brand_cur;

      --  BRAND_SEP X_CHANNEL X_BRAND_NAME X_TYPE
      IF x_channel_in IN
            ('AUTOPAY',
             'BILLING',
             'BUYNOW',
             'CLIENT',
             'ILDWEB',
             'LIFELINE',
             'ROADSIDE',
             'RSACLIENT',
             'APP' -- CR35913
            )
      THEN
         v_x_type := x_channel_in;
      END IF;

      IF x_channel_in = 'IVR' AND v_brand_name = 'NET10'
      THEN
         v_x_type := 'NETIVR';
      END IF;

      IF x_channel_in = 'IVR' AND v_brand_name = 'TRACFONE'
      THEN
         v_x_type := 'IVR';
      END IF;

      IF x_channel_in = 'WEB' AND v_brand_name = 'GENERIC'
      THEN
         v_x_type := 'WEB';
      END IF;

      IF x_channel_in = 'WEB' AND v_brand_name = 'NET10'
      THEN
         v_x_type := 'NETWEB';
      END IF;

      IF x_channel_in = 'WEB' AND v_brand_name = 'TRACFONE'
      THEN
         v_x_type := 'WEB';
      END IF;

      IF x_channel_in in ('TAS', 'WEBCSR') AND v_brand_name = 'NET10'  --CR22451
      THEN
         v_x_type := 'NETCSR';
      END IF;

      IF x_channel_in in ('TAS', 'WEBCSR') AND v_brand_name = 'TRACFONE' --CR22451
      THEN
         v_x_type := 'WEBCSR';
      END IF;

      --BRAND_SEP
      sa.sp_seq ('x_pricing', v_pricing_seq);                      -- 06/09/03

      INSERT INTO sa.table_x_pricing
                  (objid, x_start_date,
                   x_end_date,
                   x_web_link, x_web_description, x_retail_price,
                   x_type, x_pricing2part_num, x_fin_priceline_id,
                   x_channel, x_brand_name                         --BRAND_SEP
                  )
           VALUES (
                   -- 04/10/03 seq_x_pricing.nextval + (power (2, 28)),
                   -- seq('x_pricing'), 06/09/03
                   v_pricing_seq, x_start_date_in,
                   NVL (x_end_date_in,
                        TO_DATE ('10-AUG-2055 23:59:59',
                                 'DD-MON-YYYY HH24:MI:SS'
                                )
                       ),
                   x_web_link_in, x_web_description_in, x_retail_price_in,
                   v_x_type,                                      -- BRAND_SEP
                            x_pricing2part_num_in, x_fin_priceline_id_in,
                   x_channel_in, v_brand_name                      --BRAND_SEP
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting pricing',
                                x_web_description_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_pricing_fun                                               */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION update_pricing_fun (
--      OBJID_in                IN   SA.TABLE_X_PRICING.OBJID%TYPE,
      x_start_date_in         IN   sa.table_x_pricing.x_start_date%TYPE,
      x_end_date_in           IN   sa.table_x_pricing.x_end_date%TYPE,
      x_web_link_in           IN   sa.table_x_pricing.x_web_link%TYPE,
      x_web_description_in    IN   sa.table_x_pricing.x_web_description%TYPE,
      x_retail_price_in       IN   sa.table_x_pricing.x_retail_price%TYPE,
      x_channel_in            IN   sa.table_x_pricing.x_channel%TYPE,
                                                                   --BRAND_SEP
      x_pricing2part_num_in   IN   sa.table_x_pricing.x_pricing2part_num%TYPE,
      x_fin_priceline_id_in   IN   sa.table_x_pricing.x_fin_priceline_id%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                                  := v_package_name || 'update_pricing_fun()';

--BRAND_SEP
      CURSOR brand_cur
      IS
         SELECT org_id
           FROM table_bus_org bo, table_part_num pn
          WHERE bo.objid = pn.part_num2bus_org
            AND pn.objid = x_pricing2part_num_in;

      brand_rec         brand_cur%ROWTYPE;
      v_brand_name      VARCHAR2 (30);
--BRAND_SEP
   BEGIN
--BRAND_SEP
      OPEN brand_cur;

      FETCH brand_cur
       INTO brand_rec;

      IF brand_cur%FOUND
      THEN
         v_brand_name := brand_rec.org_id;
      ELSE
         v_brand_name := 'GENERIC';
      END IF;

      CLOSE brand_cur;

      --BRAND_SEP
      UPDATE sa.table_x_pricing
         SET x_start_date = NVL (x_start_date_in, x_start_date),
             -- X_END_DATE = NVL (X_END_DATE_in, X_END_DATE),
             x_end_date =
                NVL (x_end_date_in,
                     TO_DATE ('10-AUG-2055 23:59:59',
                              'DD-MON-YYYY HH24:MI:SS')
                    ),
             x_web_link = NVL (x_web_link_in, x_web_link),
             x_web_description = NVL (x_web_description_in, x_web_description),
             x_retail_price = NVL (x_retail_price_in, x_retail_price),
             x_channel = NVL (x_channel_in, x_channel),            --BRAND_SEP
--           X_PRICING2PART_NUM = NVL (X_PRICING2PART_NUM_in, X_PRICING2PART_NUM)
             x_brand_name = v_brand_name                           --BRAND_SEP
       WHERE x_pricing2part_num = x_pricing2part_num_in
         AND x_fin_priceline_id = x_fin_priceline_id_in;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed updating pricing',
                                x_web_description_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:insert_frequency_fun                                                 */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_frequency_fun (
      x_frequency_in   IN   sa.table_x_frequency.x_frequency%TYPE,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                               := v_package_name || '.insert_frequency_fun()';
      v_x_freq_seq      NUMBER;                                   -- 06/09/03
   BEGIN
      sa.sp_seq ('x_frequency', v_x_freq_seq);                    -- 06/09/03

      INSERT INTO sa.table_x_frequency
                  (objid, x_frequency
                  )
           VALUES (         -- 04/10/03 seq_part_num.nextval + (power (2,28)),
                   --seq('part_num'),
                   v_x_freq_seq, x_frequency_in
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting frequency',
                                x_frequency_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

       /* TABLE_FREQUENCY_INS */
/*****************************************************************************/
/*                                                                           */
/* Name:    update_frequency_fun                                             */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION update_frequency_fun (
      x_frequency_in   IN   sa.table_x_frequency.x_frequency%TYPE,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                               := v_package_name || '.update_frequency_fun()';
   BEGIN
      UPDATE sa.table_x_frequency
         SET x_frequency = NVL (x_frequency_in, x_frequency)
       WHERE x_frequency = x_frequency_in;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed updating frequency',
                                x_frequency_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name: insert_part_num2frequency_fun                                       */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_part_num2frequency_fun (
      part_num2x_frequency_in   IN   sa.mtm_part_num14_x_frequency0.part_num2x_frequency%TYPE,
      x_frequency2part_num_in   IN   sa.mtm_part_num14_x_frequency0.x_frequency2part_num%TYPE,
      ip_prog_caller            IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                      := v_package_name || '.insert_part_num2frequency_fun()';
   BEGIN
      -- CR10046 SWITCH OBJIDS IN MTM
      -- INSERT INTO sa.mtm_part_num14_x_frequency0(part_num2x_frequency, x_frequency2part_num )
      INSERT INTO sa.mtm_part_num14_x_frequency0
                  (x_frequency2part_num, part_num2x_frequency
                  )
           VALUES (part_num2x_frequency_in, x_frequency2part_num_in
                  );

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting part_num2x_frequency',
                                part_num2x_frequency_in,
                                ip_prog_caller || v_function_name
                               );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_part_num2frequency_fun                                    */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION update_part_num2frequency_fun (
      part_num2x_frequency_in   IN   sa.mtm_part_num14_x_frequency0.part_num2x_frequency%TYPE,
      x_frequency2part_num_in   IN   sa.mtm_part_num14_x_frequency0.x_frequency2part_num%TYPE,
      ip_prog_caller            IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name   VARCHAR2 (100)
                      := v_package_name || '.update_part_num2frequency_fun()';
   BEGIN
      UPDATE sa.mtm_part_num14_x_frequency0
         SET part_num2x_frequency = part_num2x_frequency_in,
             x_frequency2part_num = x_frequency2part_num_in
       WHERE part_num2x_frequency = part_num2x_frequency_in
         AND x_frequency2part_num = x_frequency2part_num_in;

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc
                              ('Failed updating mtm_part_num14_x_frequency0',
                               part_num2x_frequency_in,
                               ip_prog_caller || v_function_name
                              );
         RETURN FALSE;
   END;

/*****************************************************************************/
/*                                                                           */
/* Name:      get_prt_dom_objid_fun                                          */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION get_prt_dom_objid_fun (
      ip_domain        IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      table_prt_domain_rec   table_prt_domain%ROWTYPE;
      return_value           NUMBER                     := NULL;
      v_function_name        VARCHAR2 (100)
                               := v_package_name || 'get_prt_dom_objid_fun()';
   BEGIN
      OPEN toss_cursor_pkg.table_prt_domain_cur (ip_domain);

      FETCH toss_cursor_pkg.table_prt_domain_cur
       INTO table_prt_domain_rec;

      IF toss_cursor_pkg.table_prt_domain_cur%FOUND
      THEN
         --RETURN table_site_rec.site_id;
         return_value := table_prt_domain_rec.objid;
      ELSE
         --RETURN NULL;
         return_value := NULL;
      END IF;

      CLOSE toss_cursor_pkg.table_prt_domain_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_prt_domain_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_prt_domain_cur;
         END IF;

         insert_error_tab_proc ('Failed retrieving prt_domain objid',
                                ip_domain,
                               ip_prog_caller || v_function_name
                               );
         RETURN NULL;
   END;

/*****************************************************************************/
   /*                                                                           */
   /* Name:            site_part_active_fun                                     */
/* Description : Available in the specification part of package               */
/******************************************************************************/
   FUNCTION active_site_part_fun (
      ip_x_service_id   IN   VARCHAR2,
      ip_prog_caller    IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_function_name       VARCHAR2 (100)
                               := v_package_name || '.active_site_part_fun()';
      return_value          BOOLEAN                   := FALSE;
      table_site_part_rec   table_site_part%ROWTYPE;
      v_part_status         VARCHAR2 (20)             := 'Active';
   BEGIN
      OPEN toss_cursor_pkg.table_site_part_cur (ip_x_service_id,
                                                v_part_status
                                               );

      FETCH toss_cursor_pkg.table_site_part_cur
       INTO table_site_part_rec;

      IF toss_cursor_pkg.table_site_part_cur%FOUND
      THEN
         return_value := TRUE;
      ELSE
         return_value := FALSE;
      END IF;

      CLOSE toss_cursor_pkg.table_site_part_cur;

      RETURN return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF toss_cursor_pkg.table_site_part_cur%ISOPEN
         THEN
            CLOSE toss_cursor_pkg.table_site_part_cur;
         END IF;

         insert_error_tab_proc
                             ('Failed retrieving record from table_site_part',
                              ip_x_service_id,
                              ip_prog_caller || v_function_name
                             );
         RETURN FALSE;
   END;

--PSE
/*****************************************************************************/
/*                                                                           */
/* Name:     INSERT_PART_SCRIPT_FUN                                          */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   FUNCTION insert_part_script_fun (
      ip_part_number         IN   VARCHAR2,
      ip_source_part_objid   IN   NUMBER,
      ip_target_part_objid   IN   NUMBER,
      ip_prog_caller         IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      /* Cursor to get script info for the part number */
      CURSOR part_script_cur
      IS
         SELECT x_type, x_sequence, x_script_text, x_language
           FROM table_x_part_script
          WHERE part_script2part_num = ip_source_part_objid;

      v_function_name   CONSTANT VARCHAR2 (200)
                             := v_package_name || '.insert_part_script_fun()';
      v_pi_hist_seq              NUMBER;                          -- 06/09/03
   BEGIN
      FOR part_script_rec IN part_script_cur
      LOOP
         sa.sp_seq ('x_part_script', v_pi_hist_seq);

         INSERT INTO table_x_part_script
                     (objid, part_script2part_num,
                      x_script_text,
                      x_sequence, x_type,
                      x_language
                     )
              VALUES (v_pi_hist_seq, ip_target_part_objid,
                      part_script_rec.x_script_text,
                      part_script_rec.x_sequence, part_script_rec.x_type,
                      part_script_rec.x_language
                     );
      END LOOP;                              /* end of part_script_rec loop */

      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ('Failed inserting script',
                                ip_part_number,
                                'TOSS_UTIL_PKG.INSERT_PART_SCRIPT_FUN'
                               );
         RETURN FALSE;
   END;
--End PSE
/******************************************************************************/


--------------------------------------------------------------------------------
   function delete_pending_red_fun (ip_esn in varchar2,
                                    ip_user in varchar2)
   return string
   is
     msg varchar2(100);
     act_id number;
     log_rslt_msg varchar2(100);
   begin

    delete table_x_pending_redemption
    where x_pend_red2site_part in (select a.x_part_inst2site_part
                                   from   table_part_inst a
                                   where  a.x_domain = 'PHONES'
                                   and    a.part_serial_no = ip_esn);

      msg := sql%rowcount || ' Pending Code(s) Deleted';

    commit;

    select "Action_Id"
    into   act_id
    from   toppapp.x_tu_actions
    where  "Description" = 'Delete Pending Units';

    toppapp.sp_tu_log (
        ip_agent => ip_user,
        ip_action => act_id,
        ip_esn => ip_esn,
        ip_min => '',
        ip_smp => '',
        ip_reason => msg,
        ip_storeid  => '',
        op_result => log_rslt_msg,
        op_msg => log_rslt_msg
    );

    return msg;

   End;
--------------------------------------------------------------------------------
   function time_tank_verify_fun (ip_esn in varchar2,
                                  ip_code in number,
                                  ip_seq in number)
   return string
   is
      --------------------------------------------------------------------------
      v_tech        number;
      v_counter     pls_integer;
      odacc         varchar2(20);
      debsn         varchar2(20);
      v_dll         varchar2(20);
      v_dllcode     varchar2(20);
      gcode_return  varchar2(200);
      error_num     number;

      stresn        pls_integer;
      stresnhex     varchar2(30);
      strhex        varchar2(30);
      hex1          varchar2(30);
      hex2          pls_integer;
      --------------------------------------------------------------------------
      function dec2hex (n in number)
      return varchar2
      is
        hexval varchar2(64);
        n2     number := n;
        digit  number;
        hexdigit  char;
      begin
        while ( n2 > 0 ) loop
           digit := mod(n2, 16);
           if digit > 9 then
             hexdigit := chr(ascii('A') + digit - 10);
           else
             hexdigit := to_char(digit);
           end if;
           hexval := hexdigit || hexval;
           n2 := trunc( n2 / 16 );
        end loop;
        return hexval;
      end dec2hex;
      --------------------------------------------------------------------------
      function hex2dec (hexval in char)
      return number
      is
        i                 number;
        digits            number;
        result            number := 0;
        current_digit     char(1);
        current_digit_dec number;
      begin
        digits := length(hexval);
        for i in 1..digits loop
           current_digit := substr(hexval, i, 1);
           if current_digit in ('A','B','C','D','E','F') then
              current_digit_dec := ascii(current_digit) - ascii('A') + 10;
           else
              current_digit_dec := to_number(current_digit);
           end if;
           result := (result * 16) + current_digit_dec;
        end loop;
        return result;
      end hex2dec;
      --------------------------------------------------------------------------
   begin

      --------------------------------------------------------------------------
      -- COMPUTE DEBSN
      --------------------------------------------------------------------------
       stresn    :=  to_number(substr(ip_esn,4,8));
       strESNHex :=  dec2hex(strESN);
       if length(stresnhex) < 8 then
         stresnhex := lpad(stresnhex,8,'0');
       end if;
       strHex    :=  substr(strESNHex,(length(strESNHex)-3),3);
       debsn     :=  hex2dec(strhex);
      --------------------------------------------------------------------------
      -- COMPUTE ODACC
      --------------------------------------------------------------------------
       strESN    :=  to_number(substr(ip_esn,4,8));
       strESNHex :=  dec2hex(strESN);
       if length(stresnhex) < 8 then
         stresnhex := lpad(stresnhex,8,'0');
       end if;
       strHex    :=  substr(strESNHex,(length(strESNHex)-1),2);
       odacc := bitand(hex2dec(strhex),hex2dec('7F'));
      --------------------------------------------------------------------------
      -- COLLECT DLL AND TECH
      --------------------------------------------------------------------------
      begin
        select c.x_dll,
               decode(c.x_technology,
                      'TDMA',1,
                      'CDMA',2,
                      'GSM',3,
                      0) as x_tech
         into  v_dll,
               v_tech
         from  table_part_inst a,
               table_mod_level b,
               table_part_num c
        where  x_domain = 'PHONES'
        and    part_serial_no = ip_esn
        and    n_part_inst2part_mod = b.objid
        and    b.part_info2part_num = c.objid;

      exception
        when others then
          return 'ERROR TIME TANK VERIFY : ESN information not found '|| ip_esn;
      end;

      v_counter := ip_seq+1;

      if v_dll >= 22 then
         v_dllcode := 300;
      else
         v_dllcode := 100;
      end if;

      sp_codegen (command_flag => '3',
                  roam_flag => '0',
                  rhours => '1',
                  counter => v_counter,
                  odacc => odacc,
                  debsn => debsn,
                  gommand => ip_code,
                  intdlltouse => v_dll,
                  esn => ip_esn,
                  sequence => ip_seq,
                  phone_technology => v_tech,
                  dllcode => v_dllcode,
                  data1 =>  ip_code,
                  data2 => 0,
                  data3 => 0,
                  data4 => 0,
                  data5 => 0,
                  data6 => 0,
                  data7 => 0,
                  data8 => 0,
                  data9 => '0',
                  data10 => 0,
                  data11 => '0',
                  gcode_return => gcode_return,
                  error_num => error_num);

      if error_num = 0 then
           return 'TIME TANK VERIFY : Number of units left on phone: ' || gcode_return;
      else
           return 'ERROR TIME TANK VERIFY : Number of units left on phone: ' || error_num;
      end if;

    exception
      when others then
        return 'ERROR TIME TANK VERIFY : '||sqlerrm;
    end;
--------------------------------------------------------------------------------
   function plus3_transfer_fun (ip_old_esn in varchar2,
                                ip_new_esn in varchar2,
                                ip_reason in varchar2,
                                ip_user in varchar2)
   return string
   is
     op_rslt    number;
     op_msg    varchar2(200);
   begin
     ---------------------------------------------------------------------------
     -- UPDATES TABLE_X_GROUP2ESN RECORD FROM OLD_ESN TO NEW_ESN AND
     -- INSERTS INTO TABLE_X_GROUP_HIST TABLE AS 'Transfer'
     ---------------------------------------------------------------------------
     toppapp.sp_plus3_transfer (ip_oldesn=>ip_old_esn,
                                ip_newesn=>ip_new_esn,
                                op_msg=>op_msg,
                                op_result=>op_rslt);

     if op_rslt = 0 then

       toppapp.sp_tu_log (ip_agent => ip_user,
                          ip_action => 310,
                          ip_esn => ip_new_esn,
                          ip_min => '',
                          ip_smp => '',
                          ip_reason => ip_reason,
                          ip_storeid  => '',
                          op_result => op_rslt,
                          op_msg => op_msg);

       return 'PLUS 3 TRANSFER: '||op_msg;

     else
       return 'ERROR - While transferring Plus3 Plan: ('||op_rslt||') '||op_msg;
     end if;
   end;
--------------------------------------------------------------------------------
   function reset_posa_phone_fun (ip_esn in varchar2,
                                  ip_reason in varchar2,
                                  ip_user in varchar2)
   return string
   is
     op_result number;
     op_msg    varchar2(200);
   begin

     if nvl(ip_reason,' ') = ' ' then
       return 'ERROR - RESET POSA: Action cannot be performed due to No Reason was entered';
     end if;

     ---------------------------------------------------------------------------
     -- USER SA, PACKAGE POSA PROCEDURE MAKE_PHONE_ACTIVE
     -- CHANGE THE PHONE STATUS OF AN INACTIVE (59) PHONE TO ACTIVE (50)
     ---------------------------------------------------------------------------
      sa.posa.make_phone_active (ip_esn_num => ip_esn,
                                 ip_upc_code => '',
                                 ip_date => '',
                                 ip_time => '',
                                 ip_trans_id => '',
                                 ip_trans_type => '',
                                 ip_merchant_id => '',
                                 ip_store_detail => '',
                                 op_result => op_result,
                                 ip_sourcesystem => 'TOSSUTILITY');

      if op_result = 0 then
        toppapp.sp_tu_log (ip_agent => ip_user,
                           ip_action => 340,
                           ip_esn => ip_esn,
                           ip_min => '',
                           ip_smp => '',
                           ip_reason => ip_reason,
                           ip_storeid  => '',
                           op_result => op_result,
                           op_msg => op_msg);

        return 'RESET POSA : ESN Update Complete';
      else
        return 'ERROR RESET POSA: Error occurred while updating esn ('||op_result||')';
      end if;

   end;
--------------------------------------------------------------------------------
   function update_expiration_date_fun (ip_esn in varchar2,
                                        ip_user in varchar2,
                                        ip_reason in varchar2,
                                        ip_exp_date in varchar2)
   return string
   is
     msg varchar2(1000);
     log_rslt_msg varchar2(100);

     act_id number;
     e_objid number;
     sp_objid number;
     pi_cnt number := 0;
     sp_cnt number := 0;
     old_exp_date date;
     new_exp_date date := to_date(ip_exp_date,'MM/DD/YYYY');
     v_status varchar2(20);
   Begin

    begin
      select objid,
             x_part_inst2site_part,
             warr_end_date,
             x_part_inst_status
      into   e_objid,
             sp_objid,
             old_exp_date,
             v_status
      from   table_part_inst
      where  x_domain = 'PHONES'
      and    part_serial_no = ip_esn;
    exception
      when others then
        return 'ERROR obtaining esn ('||ip_esn||') info';
    end;

    if to_number(v_status) != '52' then
      return 'ERROR esn must be Active to proceed.';
    end if;

    select "Action_Id"
    into   act_id
    from   toppapp.x_tu_actions
    where  "Description" = 'Update ESN DueDate';

    update table_part_inst
    set    warr_end_date = new_exp_date
    where  objid = e_objid;
    pi_cnt := sql%rowcount;
    msg := 'Updated Expiration Date pi('||pi_cnt||') ';

    update table_site_part
    set    x_expire_dt   = new_exp_date,
           warranty_date = new_exp_date
    where  objid = sp_objid;
    sp_cnt := sql%rowcount;

    msg := msg||'and sp('||sp_cnt||') tables';

    commit;

    if (pi_cnt+sp_cnt) = 0 then
      msg := 'ERROR - UPDATING EXPDATE: PI/SP objids not found '||ip_esn;
    else
      msg := 'CHANGED DATE FROM:'||to_char(old_exp_date,'DD-MON-YYYY')||' TO: '||new_exp_date||' '|| chr(10);
    end if;

    toppapp.sp_tu_log (
        ip_agent => ip_user,
        ip_action => act_id,
        ip_esn => ip_esn,
        ip_min => '',
        ip_smp => '',
        ip_reason => msg||ip_reason,
        ip_storeid  => '',
        op_result => log_rslt_msg,
        op_msg => log_rslt_msg
    );

    return msg;

   end;
--------------------------------------------------------------------------------
   function click_plan_update_fun (ip_esn in varchar2,
                                   ip_click_plan in varchar2,
                                   ip_reason in varchar2,
                                   ip_user in varchar2)
   return string
   is
    op_result number;
    op_msg    varchar2(200);
    n_plan    number := 0; -- "Default Plan"
   begin

     if nvl(ip_esn,' ') = ' ' or
        nvl(ip_click_plan ,' ') = ' '
     then
       return 'ERROR - CLICK PLAN CHANGE: ESN and plan must be specified '||ip_esn||'-'||ip_click_plan;
     end if;

     if ip_click_plan = 'Clicks Plan' then
       n_plan := 1;
       dbms_output.put_line('n_plan:'||n_plan);
     end if;

     -- Updates an ESN to have either a default click plan or a "1 click" click plan
     sa.sp_click_plan_change (ip_esn=>ip_esn,
                              ip_user=>ip_user,
                              ip_plantype=>n_plan,
                              op_errmsg=>op_msg,
                              op_error=>op_result);

     -- IF ALL WENT WELL AND THE PLAN WAS CHANGED THE OUT MSG'S ARE NULL
     dbms_output.put_line('op_msg:'||op_msg);
     dbms_output.put_line('op_result:'||op_result);

     if op_result is null then
       return 'CLICK PLAN CHANGE: ESN is now flagged for: '||ip_click_plan||', ESN: '||ip_esn;
     else
       return 'ERROR - CLICK PLAN CHANGE: '||op_msg||', ESN: '||ip_esn;
     end if;

   end;

--------------------------------------------------------------------------------
END;
/
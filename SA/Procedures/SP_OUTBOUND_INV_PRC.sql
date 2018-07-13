CREATE OR REPLACE PROCEDURE sa."SP_OUTBOUND_INV_PRC"
AS
/*******************************************************************************************/
   /* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved                             */
   /*                                                                                         */
   /* Name        :   sp_outbound_inv_prc.sql                                                 */
   /* Purpose     :   To update new active PHONES status as TABLE_SITE_PART  into             */
   /*                 TF_TOSS_INTERFACE_TABLE in Oracle Financials                            */
   /* Parameters  :   NONE                                                                    */
   /* Platforms   :   Oracle 8.0.6 AND newer versions                                         */
   /* Author      :   VS                                                                      */
   /* Date        :   08/15/01                                                                */
   /* Revisions   :   Version  Date      Who       Purpose                                    */
   /*                 -------  --------  -------   ----------------------------------         */
   /*                  1.0                         Initial revision                           */
   /*                  1.1     10/22/01  VAdapa    Included TOSS_EXTRACT_FLAG check           */
   /*                  1.2     10/30/01  Miguel    Changed commit points to tack place        */
   /*                                    Leon      after each pass of the loop.               */
   /*                  1.3     04/30/03  Gpintado  Pass back dealer info once active          */
   /*                                              if it exists in x_alt_esn table            */
   /*                  1.3     09/30/03  Gpintado  Pass back act_date no matter if it         */
   /*                                              was already passed before. This is         */
   /*                                              mainly for refurbished phones              */
   /*                  1.3     03/08/05  VAdapa    CR3606 - Update sp_outbound_inv_prc        */
   /*                                              in Clarify                                 */
   /*               1.5/1.6    04/14/06  VAdapa    Modified for CR5183                        */
   /*               1.4/1.13   08/15/06  ICanavan  CR5183 read merchant_id return customer_id */
   /*                         Added to_char, type=3 /                */
   /*            1.14                     Missing alias
   /*                  1.15     05/02/07  TZhou     CR5704 - Activation Date                   */
   /*                                              Modify main cursor to handle NULL bin_objid*/
   /*          1.16     09/05/07   VAdapa CR6629 - Remove the update of retailer info to table_part_inst and  toss_interface_table
   /*			1.17	 09/05/07	VAdapa CR6629 - Changed the database link from OFSUAT to OFSPRD
   /*new_llsql STRUCTURE*/
   /*       1.6         11/21/07        CLindner - WEBCSR Fix
   /*******************************************************************************************/
   CURSOR c_serial
   IS
   --WCSR_FIX
   /*  SELECT a.ROWID, a.serial_no, a.install_date, b.x_action_type
        FROM table_site_part a, table_x_call_trans b
       WHERE part_status = 'Active'
         --AND bin_objid = 0                --CR5704
         AND NVL (bin_objid, 0) = 0                                   --CR5704
         AND a.objid = b.call_trans2site_part
         AND b.x_action_type IN ('1', '3', '10');*/
   SELECT a.ROW_ID,
      a.serial_no,
      a.install_date,
      b.x_action_type
   FROM table_x_call_trans b, (
      SELECT /*+ FULL(a) PARALLEL(a,5) */
      DISTINCT a.ROWID row_id,
         a.serial_no,
         a.install_date,
         a.objid
      FROM table_site_part a
      WHERE a.part_status = 'Active'
      AND NVL(a.bin_objid, 0) = 0
      AND ROWNUM < 3000000000) a
   WHERE 1 = 1
   AND b.call_trans2site_part = a.objid
   AND b.x_action_type IN ('1', '3', '10') ;
--WCSR_FIX
   -- Gets activations,reactivations, and activation-ac-chg
   -- FROM table_site ts, tf.tf_customers_v@ofsdev2
   CURSOR c_alt_esn_dealer(
      c_esn IN VARCHAR2
   )
   IS
   SELECT d.customer_name,
      ts.site_type,
      ts.x_fin_cust_id,
      ts.site_id
   FROM table_site ts, tf.tf_customers_v@ofsprd d
   WHERE ts.x_fin_cust_id = TO_CHAR (d.customer_id)
   AND ts.site_id IN (
   SELECT b.bin_name
   FROM table_part_inst a, table_inv_bin b
   WHERE a.part_serial_no = c_esn
   AND a.part_inst2inv_bin = b.objid)
   AND EXISTS (
   SELECT 'x'
   FROM table_x_alt_esn
   WHERE x_replacement_esn = c_esn);
   --CR5183 Start
   CURSOR posa_esn_cur(
      c_esn IN VARCHAR2
   )
   IS
   SELECT a.toss_att_customer
   FROM x_posa_phone a
   WHERE a.tf_serial_num = c_esn
   ORDER BY toss_posa_date DESC;
   posa_esn_rec posa_esn_cur%ROWTYPE;
   -- FROM table_inv_bin ib, table_site ts, tf.tf_customers_v@ofsdev2 b
   CURSOR toss_site_cur(
      c_merchant_id IN VARCHAR2
   )
   IS
   SELECT ib.objid ib_objid,
      b.customer_id,
      b.customer_name
   FROM table_inv_bin ib, table_site ts, tf.tf_customers_v@ofsprd b
   WHERE TO_CHAR (b.customer_id) = ts.x_fin_cust_id
   AND ts.site_id = ib.bin_name
   AND b.merchant_id = c_merchant_id
   AND b.account_type <> 'REDEMPTION CARDS'
   AND ts.TYPE = 3;
   toss_site_rec toss_site_cur%ROWTYPE;
   --CR5183 END
   v_error VARCHAR2 (4000);
   v_ret_code VARCHAR2 (100);
   v_ret_name VARCHAR2 (100);
   v_ff_code VARCHAR2 (100);
   v_ff_name VARCHAR2 (100);
   v_manuf_code VARCHAR2 (100);
   v_manuf_name VARCHAR2 (100);
   v_loc_flag VARCHAR2 (100);
   --WCSR_FIX
   v_recs_processed NUMBER := 0;
   v_start_date DATE := SYSDATE;
   --WCSR_FIX

BEGIN
   FOR c_serial1 IN c_serial
   LOOP
      BEGIN
         IF c_serial1.x_action_type IN ('3', '10')
         THEN

            -- If "Reactivation" or "Activation-AC/CHG" only update site_part
            -- to show that record was already scanned.
            UPDATE table_site_part SET bin_objid = c_serial1.x_action_type
            WHERE ROWID = c_serial1.ROW_ID;--WCSR_FIX
         ELSIF c_serial1.x_action_type = '1'
         THEN

            -- If "New Activation" update site_part as well as
            -- oracle financial interface table.
            UPDATE table_site_part SET bin_objid = c_serial1.x_action_type
            WHERE ROWID = c_serial1.ROW_ID;--WCSR_FIX
            /* If the Phone activated in CLARIFY, get the activated
            date and update the interface table in FINANCIALS. */
            IF (c_serial1.install_date
            IS
            NOT NULL)
            THEN
               v_ret_code := NULL;
               v_ret_name := NULL;
               v_ff_code := NULL;
               v_ff_name := NULL;
               v_manuf_code := NULL;
               v_manuf_name := NULL;
               v_loc_flag := NULL;
               FOR r_alt_esn_dealer IN c_alt_esn_dealer (c_serial1.serial_no)
               LOOP
                  IF r_alt_esn_dealer.site_type = 'RSEL'
                  THEN
                     v_ret_code := LTRIM (RTRIM (r_alt_esn_dealer.x_fin_cust_id
                     ));
                     v_ret_name := LTRIM (RTRIM (r_alt_esn_dealer.customer_name
                     ));
                     v_loc_flag := 'CLFY_RSEL';
                  ELSIF r_alt_esn_dealer.site_type = 'MANF'
                  THEN
                     v_manuf_code := LTRIM (RTRIM (r_alt_esn_dealer.x_fin_cust_id
                     ));
                     v_manuf_name := LTRIM (RTRIM (r_alt_esn_dealer.customer_name
                     ));
                     v_loc_flag := 'CLFY_MANF';
                  ELSIF r_alt_esn_dealer.site_type = 'DIST'
                  THEN
                     v_ff_code := LTRIM (RTRIM (r_alt_esn_dealer.x_fin_cust_id)
                     );
                     v_ff_name := LTRIM (RTRIM (r_alt_esn_dealer.customer_name)
                     );
                     v_loc_flag := 'CLFY_DIST';
                  END IF;
               END LOOP;
               --CR5183 start
               IF v_ret_code
               IS
               NULL
               THEN
                  OPEN posa_esn_cur (c_serial1.serial_no);
                  FETCH posa_esn_cur
                  INTO posa_esn_rec;
                  IF posa_esn_cur%FOUND
                  THEN
                     OPEN toss_site_cur (posa_esn_rec.toss_att_customer);
                     FETCH toss_site_cur
                     INTO toss_site_rec;
                     IF toss_site_cur%FOUND
                     THEN
                        v_ret_code := LTRIM (RTRIM (toss_site_rec.customer_id))
                        ;
                        v_ret_name := LTRIM (RTRIM (toss_site_rec.customer_name
                        ));
                        v_loc_flag := 'CLFY_RSEL';
--CR6629
                     --                         UPDATE table_part_inst
                     --                            SET part_inst2inv_bin = toss_site_rec.ib_objid
                     --                          WHERE part_serial_no = c_serial1.serial_no;
                     --CR6629
                     END IF;
                     CLOSE toss_site_cur;
                  END IF;
                  CLOSE posa_esn_cur;
               END IF;
               --CR5183 end
               IF (v_ret_code
               IS
               NULL)
               AND (v_manuf_code
               IS
               NULL)
               AND (v_ff_code
               IS
               NULL)
               THEN

                  /*   UPDATE TF.tf_toss_interface_table@OFSPCH SET */
                  /*   UPDATE TF.tf_toss_interface_table@OFSDEV2    */
                  UPDATE tf.tf_toss_interface_table@ofsprd SET
                  toss_phone_activation_date = TRUNC (c_serial1.install_date),
                  last_update_date = SYSDATE, --CR3606
                  last_updated_by = 'SP_OUTBOUND_INV_PRC'
                  WHERE tf_serial_num = c_serial1.serial_no
                  AND tf_part_type = 'PHONE';
               ELSE

                  /* UPDATE TF.tf_toss_interface_table@OFSPCH SET */
                  /* UPDATE TF.tf_toss_interface_table@OFSDEV2    */
                  UPDATE tf.tf_toss_interface_table@ofsprd SET
                  toss_phone_activation_date = TRUNC (c_serial1.install_date),
                  --CR6629
                  --                          tf_manuf_location_code =
                  --                                     NVL (v_manuf_code, tf_manuf_location_code),
                  --                          tf_manuf_location_name =
                  --                                     NVL (v_manuf_name, tf_manuf_location_name),
                  --                          tf_ff_location_code =
                  --                                     NVL (v_ff_code, tf_ff_location_code),
                  --                          tf_ff_location_name =
                  --                                     NVL (v_ff_name, tf_ff_location_name),
                  --                          tf_ret_location_code =
                  --                                     NVL (v_ret_code, tf_ret_location_code),
                  --                          tf_ret_location_name =
                  --                                     NVL (v_ret_name, tf_ret_location_name),
                  --                          toss_location_update_flag = v_loc_flag,
                  --                          toss_location_update_date = SYSDATE,
                  --CR6629
                  last_update_date = SYSDATE, --CR3606
                  last_updated_by = 'SP_OUTBOUND_INV_PRC'
                  WHERE tf_serial_num = c_serial1.serial_no
                  AND tf_part_type = 'PHONE';
               END IF;
               COMMIT;
            END IF;
         END IF;
         EXCEPTION
         WHEN OTHERS
         THEN
            v_error := SQLERRM;
            /* If ESN not found in financials interface table then */
            /* insert those serial numbers into the error table.   */
            INSERT
            INTO error_table(
               ERROR_TEXT,
               error_date,
               action,
               KEY,
               program_name
            )            VALUES(
               v_error,
               SYSDATE,
               'ESN not found in TF_TOSS_INTERFACE_TABLE table',
               c_serial1.serial_no,
               'SP_OUTBOUND_INV_PRC'
            );
            COMMIT;
      END;
      COMMIT;
      v_recs_processed := v_recs_processed + 1;  --WCSR_FIX
   END LOOP;
   /* now update interface jobs */
   --WCSR_FIX
   IF toss_util_pkg.insert_interface_jobs_fun ('SP_OUTBOUND_INV_PRC',
   v_start_date, SYSDATE, v_recs_processed, 'SUCCESS', 'SP_OUTBOUND_INV_PRC')
   THEN
      COMMIT;
   END IF;
   --WCSR_FIX
   EXCEPTION
   WHEN OTHERS
   THEN
      v_error := SQLERRM;
      /* If ESN not found in financials interface table then insert those
      serial numbers into the error table. */
      INSERT
      INTO error_table(
         ERROR_TEXT,
         error_date,
         action,
         KEY,
         program_name
      )      VALUES(
         v_error,
         SYSDATE,
         'There is an error, exiting from the loop',
         NULL,
         'SP_OUTBOUND_INV_PRC'
      );
      COMMIT;
      --WCSR_FIX
      IF toss_util_pkg.insert_interface_jobs_fun ('SP_OUTBOUND_INV_PRC',
      v_start_date, SYSDATE, v_recs_processed, 'FAILED', 'SP_OUTBOUND_INV_PRC')
      THEN
         COMMIT;
      END IF;
      --WCSR_FIX
END;
/
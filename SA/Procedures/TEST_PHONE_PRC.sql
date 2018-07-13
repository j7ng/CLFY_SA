CREATE OR REPLACE PROCEDURE sa."TEST_PHONE_PRC"
AS
/*************************************************************************************/
/* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved                       */
/*                                                                                   */
/* Name         :   sp_outbound_inv_prc.sql                                          */
/* Purpose      :   To update new active PHONES status as TABLE_SITE_PART  into      */
/*                  TF_TOSS_INTERFACE_TABLE in Oracle Financials                     */
/* Parameters   :   NONE                                                             */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                  */
/* Author      :   VS                                                                */
/* Date         :   08/15/01                                                         */
/* Revisions   :   Version  Date      Who       Purpose                              */
/*                  -------  --------  -------   ------------------------------      */
/*                   1.0                         Initial revision                    */
/*                   1.1     10/22/01  VAdapa    Included TOSS_EXTRACT_FLAG check    */
/*                   1.2     10/30/01  Miguel    Changed commit points to tack place */
/*                                      Leon     after each pass of the loop.        */
/*                   1.3     04/30/03  Gpintado  Pass back dealer info once active   */
/*                                               if it exists in x_alt_esn table     */
/*************************************************************************************/
   CURSOR c_serial
   IS
      SELECT serial_no, install_date
        FROM table_site_part a,
             table_x_call_trans b
       WHERE part_status = 'Active'
         AND install_date >= (sysdate - 90)
         AND a.objid = b.call_trans2site_part
         AND b.x_action_type = '1'
	AND a.x_service_id in ('21805167823','21814092274','21805153722','21804999514','21805152873',--'21805152873','21805153722',
'21814128275','21813966597','21814147902','21814120874','21805091764','21805093363','21805000921',
'21812238230','21804993555','21805168859','21805144415','21813967094','21813965874','21805166941',
'21814134790','21814100108','21814069865','21805168116','21805144895','21805079139','21805045462');  -- only gets first time activations per Muhammad's request.


   CURSOR c_alt_esn_dealer (c_esn in varchar2)
   IS
      SELECT d.customer_name, c.site_type, c.x_fin_cust_id
        FROM table_part_inst a,
             table_inv_bin b,
             table_site c,
             tf.tf_customers_v@OFSPRD d
       WHERE a.part_serial_no = c_esn
         AND a.part_inst2inv_bin = b.objid
         AND b.bin_name = c.site_id
         AND c.x_fin_cust_id = d.customer_id
         AND EXISTS (SELECT 'x' FROM table_x_alt_esn
                     WHERE x_replacement_esn = c_esn);


   v_error      VARCHAR2(4000);
   v_ret_code   VARCHAR2(100);
   v_ret_name   VARCHAR2(100);
   v_ff_code    VARCHAR2(100);
   v_ff_name    VARCHAR2(100);
   v_manuf_code VARCHAR2(100);
   v_manuf_name VARCHAR2(100);
   v_loc_flag   VARCHAR2(100);


BEGIN

   FOR c_serial1 IN c_serial
   LOOP

      BEGIN
         /* If the Phone activated in CLARIFY, get the activated
       date and update the interface table in FINANCIALS. */
         IF (c_serial1.install_date IS NOT NULL) THEN

                 v_ret_code   := null;
                 v_ret_name   := null;
                 v_ff_code    := null;
                 v_ff_name    := null;
                 v_manuf_code := null;
                 v_manuf_name := null;
                 v_loc_flag   := null;

                FOR  r_alt_esn_dealer IN c_alt_esn_dealer (c_serial1.serial_no) LOOP

                     IF r_alt_esn_dealer.site_type = 'RSEL' THEN
                        v_ret_code := ltrim(rtrim(r_alt_esn_dealer.x_fin_cust_id));
                        v_ret_name := ltrim(rtrim(r_alt_esn_dealer.customer_name));
                        v_loc_flag := 'CLFY_RSEL';

                     ELSIF r_alt_esn_dealer.site_type = 'MANF' THEN
                        v_manuf_code := ltrim(rtrim(r_alt_esn_dealer.x_fin_cust_id));
                        v_manuf_name := ltrim(rtrim(r_alt_esn_dealer.customer_name));
                        v_loc_flag := 'CLFY_MANF';

                     ELSIF r_alt_esn_dealer.site_type = 'DIST' THEN
                        v_ff_code :=  ltrim(rtrim(r_alt_esn_dealer.x_fin_cust_id));
                        v_ff_name :=  ltrim(rtrim(r_alt_esn_dealer.customer_name));
                        v_loc_flag := 'CLFY_DIST';

                     END IF;

                END LOOP;


            IF (v_ret_code is null) AND (v_manuf_code is null) AND (v_ff_code is null) THEN

               UPDATE TF.tf_toss_interface_table@OFSPRD
                  SET toss_phone_activation_date = trunc (c_serial1.install_date)
                WHERE tf_serial_num = c_serial1.serial_no
                  AND tf_part_type = 'PHONE';
                  -- AND toss_phone_activation_date IS NULL
                  -- AND toss_extract_flag = 'YES';

            ELSE

               UPDATE TF.tf_toss_interface_table@OFSPRD
                  SET toss_phone_activation_date = trunc (c_serial1.install_date),
                      tf_manuf_location_code     = nvl(v_manuf_code,tf_manuf_location_code),
                      tf_manuf_location_name     = nvl(v_manuf_name,tf_manuf_location_name),
                      tf_ff_location_code        = nvl(v_ff_code,tf_ff_location_code),
                      tf_ff_location_name        = nvl(v_ff_name,tf_ff_location_name),
                      tf_ret_location_code       = nvl(v_ret_code,tf_ret_location_code),
                      tf_ret_location_name       = nvl(v_ret_name,tf_ret_location_name),
                      toss_location_update_flag  = v_loc_flag,
                      toss_location_update_date  = SYSDATE
                WHERE tf_serial_num = c_serial1.serial_no
                  AND tf_part_type = 'PHONE';
                  -- AND toss_phone_activation_date IS NULL
                  -- AND toss_extract_flag = 'YES';

            END IF;

            COMMIT;


         END IF;

      EXCEPTION

         WHEN OTHERS THEN

            v_error := sqlerrm;

            /* If ESN not found in financials interface table  then insert those serial numbers into the error table. */
            INSERT INTO error_table
                        (error_text, error_date, action, key, program_name)
                 VALUES(
                    v_error,
                    sysdate,
                    'ESN not found in TF_TOSS_INTERFACE_TABLE table',
                    c_serial1.serial_no,
                    'SP_OUTBOUND_INV_PRC'
                 );

            COMMIT;
      END;



   END LOOP;

EXCEPTION

   WHEN OTHERS THEN

      v_error := sqlerrm;

      /* If ESN not found in financials interface table  then insert those serial numbers into the error table.
        */
      INSERT INTO error_table
                  (error_text, error_date, action, key, program_name)
           VALUES(
              v_error,
              sysdate,
              'There is an error, exiting from the loop',
              null,
              'SP_OUTBOUND_INV_PRC'
           );

      COMMIT;
END;
/
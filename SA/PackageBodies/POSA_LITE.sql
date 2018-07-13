CREATE OR REPLACE PACKAGE BODY sa."POSA_LITE"
AS
/******************************************************************************/
   /*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
   /*                                                                            */
   /* NAME:         posa_package_spec.sql                                        */
   /* PURPOSE:                                                                   */
   /* FREQUENCY:                                                                 */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
   /* REVISIONS:    VERSION  DATE        WHO               PURPOSE               */
   /*               -------  ----------  ---------------   -------------------   */
   /*               1.0                                    Initial Revision      */
   /*               1.1      7/16/2001   Vani Shimoga      IP_STORE_DETAIL is    */
   /*                                                      added.                */
   /*                                                                            */
   /*               1.2      7/27/2001   Vani Shimoga      Toppoci.topp_oci_     */
   /*                                                      redeem_interface table*/
   /*                                                      is not valid anymore. */
   /*                                                      Instead               */
   /*                                                      Phoenix project is    */
   /*                                                      using sa.posa_swp_loc_*/
   /*                                                      act_card table        */
   /*                                                                            */
   /*               1.3      8/15/2001   Vani Shimoga      GET_CARD_STATUS has   */
   /*                                                      been modified to get  */
   /*                                                      the UPC code from     */
   /*                                                      table_part_num        */
   /*                                                      instead of mtl_system_*/
   /*                                                      items. Procedure assum*/
   /*                                                      es that it gets the   */
   /*                                                      part_num exists in TOS*/
   /*                                                      Insertintopartinst pro*/
   /*                                                      cedure is not required*/
   /*                                                      any more, because all */
   /*                                                      the parts exists in   */
   /*                                                      TOSS.                 */
   /*                                                                            */
   /*               1.4   09/15/2001     Miguel Leon       Inserted debug state- */
   /*                                                      ments and commented   */
   /*                                                      out some useless logic*/
   /*                                                      related to inserting  */
   /*                                                      into part_inst        */
   /*                                                                            */
   /*               1.5  10/11/2001      Miguel Leon       Accomodated suggested */
   /*                                                      changes recommnended  */
   /*                                                      by Lee Manuel.Also    */
   /*                                                      changed when others re*/
   /*                                                      urn code to be sqlerro*/
   /*                                                      and include insertion */
   /*                                                      into the error_table  */
   /*                                                                            */
   /*              1.6  12/18/01      Miguel Leon          Modified all the code */
   /*                                                      to use toss_util_pkg  */
   /*                                                      Also Added new POSA   */
   /*                                                      phones functionalities*/
   /*                                                      (get_phone_status. mak*/
   /*                                                      phone_active/inactive/*/
   /*                                                      returned).This new por*/
   /*                                                      currently will only   */
   /*                                                      work with walmart posa*/
   /*                                                      phones as agreed.     */
   /*                                                                            */
   /*             1.7  01/18/02     Miguel Leon           Added insertion into   */
   /*                                                     x_posa_esn_exception   */
   /*                                                     when make_phone_returne*/
   /*                                                                            */
   /*             1.8  01/23/02    Miguel Leon            Removed logic to check */
   /*                                                     if Vendor is RSEL and  */
   /*                                                     also removed insertion */
   /*                                                     on exception esn table */
   /*                                                     when activating phone  */
   /*                                                     linked to a Distributor*/
   /*                                                                            */
   /*            1.9 02/01/02     Miguel Leon             Added new posa Roadside*/
   /*                                                     cards procedures:      */
   /*                                                     GET_RS_CARD_STATUS()   */
   /*                                                     MAKE_RS_REDEEMABLE()   */
   /*                                                     MAKE_RS_UNREDEEMABLE() */
   /*                                                                            */
   /*            1.10 04/18/02     Miguel Leon       Changed REDEMPTION CARD to  */
   /*                                                REDEMPTION CARDS (plural)   */
   /*                                                within the MAKE_CARD_REDEEM */
   /*                                                ABLE AND MAKE_CARD_UNREDEEM */
   /*                                                ABLE procs                  */
   /*                                                Added IN Parameter SOURCESYS*/
   /*                                                with default value 'POSA' on*/
   /*                                                all the make procs          */
   /*                                                                            */
   /* 1.11  07/27/02   Miguel Leon   Modified MAKE_PHONE_RETURNED to allowed     */
   /*                                PAST_DUE(54), USED(51) and in the event that*/
   /*                                the esn is active, the phone is deactivated */
   /*                                and RESET/REFURB to '59'" ( posa inactive). */
   /*                                MAKE_PHONE_RETUNED will always NOW set the  */
   /*                                status to INACTIVE POSA PHONE (59) upon     */
   /*                                successful completion.                      */
   /*                                Also "hard wired" GET_PHONE_STATUS procedure*/
   /*                                to return '52' (PHONE_ACTIVE) when a phone  */
   /*                                is found with a status of '54' (past_due) or*/
   /*                                '51'(USED). This temporary fix was applied  */
   /*                                to avoid any changes/additions of any return*/
   /*                                codes to the C++ aspects of the posa system.*/
   /*                                                                            */
   /* 1.12 08/09/02  Miguel Leon    Added detail error logging capabilities to   */
   /*                               the following procedures: GET_CARD_STATUS()  */
   /*                               GET_PHONES_STATUS() and GET_RS_STATUS().     */
   /*                                                                            */
   /* 1.13 10/10/09 Miguel Leon     Modified MAKE_CARD_REDEEMABLE, MAKE_CARD_UNRE*/
   /*                               EEMABLE, MAKE_PHONE_ACTIVE, MAKE_PHONE_INACTI*/
   /*                               VE, MAKE_PHONE_RETURNED, MAKE_RS_REDEEMABLE, */
   /*                               MAKE_RS_UNREDEEMABLE to convert the varchar  */
   /*                               ip_time and ip_date to a date and insert it  */
   /*                              into the table x_posa_card, x_posa_phone or   */
   /*                              x_posa_road on a newly added field call toss_ */
   /*                              att_trans_date. Ip_date and ip_time is the    */
   /*                              actual transaction date sent to Tracfone by   */
   /*                              Air Time.                                     */
   /* 1.14 03/17/03 SL     Clarify Upgrade                                       */
   /*                              Replace all procedures call to toss_util_pkg  */
   /*                              Modified all posa redemption card related     */
   /*                              logic to reflect new data model               */
   /*                              Only posa ready card will be inserted inot    */
   /*                              table_part_inst                               */
   /*                                                                            */
   /* 1.15 04/10/03 SL             Clarify Upgrade - sequence                    */
   /*                                                                            */
   /* 1.16 02/05/04 GP             IVR/WEBCSR POSA                               */
   /*                                                                            */
   /* 1.17 09/14/04 VA             CR3176 - Make Phone Inactive for '55' status  */
   /*                                       esns                                 */
   /* 1.18 10/18/04 VA             CR2970 - Insert queued-in transaction data    */
   /*                              in X_POSA_LOG table                           */
   /******************************************************************************/
   /* 1.2/1.6  02/13/2012 CLindner  CR15722 Blackhawk Network (BHN) (Master)     */
   /*                               new procedure  posa_transaction_controller   */
   /* 1.7   09/21/2012 CLindner  MT441078                                        */
   /* 1.8   12/10/2012 ICanavan  CR22828                                          */
   /******************************************************************************/
   --   v_package_name CONSTANT VARCHAR2 (80) := '.POSA_PKG';
   v_package_name CONSTANT VARCHAR2 (80) := '.POSA_LITE_PKG';
   g_posa_card_inv_rec table_x_posa_card_inv%ROWTYPE;
   g_part_inst_rec table_part_inst%ROWTYPE;
   g_part_num_rec table_part_num%ROWTYPE;
   /*****************************************************************************/
   CURSOR table_x_code_cur(
      ip_code_number IN VARCHAR2
   )
   RETURN table_x_code_table%ROWTYPE
   IS
   SELECT xc.*
   FROM table_x_code_table xc
   WHERE x_code_number = ip_code_number;
   /*****************************************************************************/
   CURSOR table_part_num_road_cur(
      ip_part_serial_no VARCHAR2
   )
   RETURN table_part_num%ROWTYPE
   IS
   SELECT pn.*
   FROM table_part_num pn, table_x_road_inst ri, table_mod_level ml
   WHERE ri.n_road_inst2part_mod = ml.objid
   AND ml.part_info2part_num = pn.objid
   AND ri.part_serial_no = ip_part_serial_no;
   /*****************************************************************************/
   CURSOR table_site_road_cur(
      ip_part_serial_no VARCHAR2,
      ip_domain VARCHAR2
   )
   RETURN table_site%ROWTYPE
   IS
   SELECT ts.*
   FROM table_site ts, table_inv_bin ib, table_x_road_inst ri
   WHERE ri.part_serial_no = ip_part_serial_no
   AND ri.x_domain = ip_domain
   AND ri.road_inst2inv_bin = ib.objid
   AND ib.bin_name = ts.site_id;
   /*****************************************************************************/
   CURSOR table_road_inst_cur(
      ip_part_serial_no VARCHAR2
   )
   RETURN table_x_road_inst%ROWTYPE
   IS
   SELECT *
   FROM table_x_road_inst
   WHERE part_serial_no = ip_part_serial_no;
   /*****************************************************************************/
   CURSOR table_part_num_cur(
      ip_part_serial_no VARCHAR2
   )
   RETURN table_part_num%ROWTYPE
   IS
   SELECT pn.*
   FROM table_part_num pn, table_part_inst pi, table_mod_level ml
   WHERE pi.n_part_inst2part_mod = ml.objid
   AND ml.part_info2part_num = pn.objid
   AND pi.part_serial_no = ip_part_serial_no
   ORDER BY
   CASE WHEN upper(pn.part_number) = 'LINES' THEN 9999 -- Added Order By Clause Per CR57395
   ELSE 1
   END;
   /*****************************************************************************/
   CURSOR table_site_cur(
      ip_part_serial_no VARCHAR2,
      ip_domain VARCHAR2
   )
   RETURN table_site%ROWTYPE
   IS
   SELECT ts.*
   FROM table_site ts, table_inv_bin ib, table_part_inst pi
   WHERE pi.part_serial_no = ip_part_serial_no
   AND pi.x_domain = ip_domain
   AND pi.part_inst2inv_bin = ib.objid
   AND ib.bin_name = ts.site_id;
   /*****************************************************************************/
   CURSOR table_part_inst_cur(
      ip_part_serial_no VARCHAR2
   )
   RETURN table_part_inst%ROWTYPE
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = ip_part_serial_no;
   /******************************************************************************/
   CURSOR table_mod_objid_cur(
      ip_ml_objid NUMBER
   )
   RETURN table_mod_level%ROWTYPE
   IS
   SELECT *
   FROM table_mod_level
   WHERE objid = ip_ml_objid;
   /*****************************************************************************/
   CURSOR table_part_number_cur(
      ip_objid NUMBER
   )
   RETURN table_part_num%ROWTYPE
   IS
   SELECT *
   FROM table_part_num
   WHERE objid = ip_objid;
   /*****************  Get Card Status (Proc 1)  *****************/
   /*                                                            */
   /* Objective  : To obtain the status of a card based on SMP   */
   /*                                                            */
   /* Returns:                                                   */
   /*              OP_STATUS =  0  if card not found             */
   /*                          40  if card is Reserved           */
   /*                          41  if card is Redeemed           */
   /*                          42  if card is Active/redeemable  */
   /*                          43  if card is Void               */
   /*                          44  if card is Suspended          */
   /*                          45  if card is Inactive           */
   /*                                                            */
   /*              OP_NUM_UNITS = # units associated w/card      */
   /*                             0  if OP_STATUS = 0 or 45      */
   /*                                                            */
   /*              OP_UPC_CODE = the UPC code associated w/card  */
   /*                           10 units = 7633 4611 3918        */
   /*                           30 units = 7633 4611 3925        */
   /*                          120 units = 7633 4611 3932        */
   /*                          300 units = 7633 4611 3946        */
   /*                                                            */
   /**************************************************************/
   PROCEDURE get_card_status(
      ip_smp_num IN VARCHAR2,
      op_status OUT NUMBER,
      op_num_units OUT NUMBER,
      op_upc_code OUT VARCHAR2
   )
   IS
      v_part_number table_part_num.part_number%TYPE := NULL;
      v_redeemed_units table_part_num.x_redeem_units%TYPE := NULL;
      v_upc_code table_part_num.x_upc%TYPE := NULL;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.GET_CARD_STATUS()';
      -- 1.14
      CURSOR c_part_inst(
         c_smp VARCHAR2
      )
      IS
      SELECT *
      FROM table_part_inst
      WHERE part_serial_no = c_smp
        AND x_domain = 'REDEMPTION CARDS';  -- CR55993 BHN POSA Fix SNP vs MIN;
      c_part_inst_rec c_part_inst%ROWTYPE;
      CURSOR c_posa_inv(
         c_smp VARCHAR2
      )
      IS
      SELECT *
      FROM table_x_posa_card_inv inv
      WHERE inv.x_part_serial_no = c_smp;
      c_posa_inv_rec c_posa_inv%ROWTYPE;
      CURSOR c_red_card(
         c_smp VARCHAR2
      )
      IS
      SELECT *
      FROM table_x_red_card
      WHERE x_smp = c_smp;
      c_red_card_rec c_red_card%ROWTYPE;
      CURSOR c_part_num(
         c_mod_level_objid NUMBER
      )
      IS
      SELECT pn.*
      FROM table_part_num pn, table_mod_level ml
      WHERE ml.part_info2part_num = pn.objid
      AND ml.objid = c_mod_level_objid;
      c_part_num_rec c_part_num%ROWTYPE;
      v_part_mod_objid NUMBER;
      -- end 1.14
      V_LOG_RESULT NUMBER;
   BEGIN

      --OP_NUM_UNITS := '0';
      op_num_units := 0;
      op_upc_code := NULL;
      op_status := 0;
      /* Get the card status from pi table */
      -- 1.14
      --
      --op_status := TO_NUMBER (TOSS_UTIL_PKG.GET_PI_STATUS_FUN(IP_SMP_NUM,v_procedure_name));
      -- check part inst first
      OPEN c_part_inst (ip_smp_num);
      FETCH c_part_inst
      INTO g_part_inst_rec;
      IF c_part_inst%NOTFOUND
      THEN

         --check posa inventory table
         OPEN c_posa_inv (ip_smp_num);
         FETCH c_posa_inv
         INTO g_posa_card_inv_rec;
         IF c_posa_inv%NOTFOUND
         THEN

            --  not in posa inventory
            --  check x_red_card table
            CLOSE c_posa_inv;
            OPEN c_red_card (ip_smp_num);
            FETCH c_red_card
            INTO c_red_card_rec;
            IF c_red_card%NOTFOUND
            THEN
               CLOSE c_red_card;
               op_status := 0;
               --CR2970
               insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', NULL, NULL
               , NULL, NULL, 'POSA', TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(
               SYSDATE, 'HH24MISS'), 'FIND SMP STATUS', 'NOT FOUND',
               v_procedure_name, V_LOG_RESULT,null ) ; --CR15722
               IF V_LOG_RESULT = 0
               THEN
                  COMMIT;
               END IF;
               --
               RETURN;
            ELSE
               CLOSE c_red_card;
               v_part_mod_objid := c_red_card_rec.x_red_card2part_mod;
               op_status := '41';
            END IF;
         ELSE

            --
            -- In posa inventory
            --
            CLOSE c_posa_inv;
            v_part_mod_objid := g_posa_card_inv_rec.x_posa_inv2part_mod;
            op_status := g_posa_card_inv_rec.x_posa_inv_status;
         END IF;
      ELSE
         v_part_mod_objid := g_part_inst_rec.n_part_inst2part_mod;
         op_status := g_part_inst_rec.x_part_inst_status;
      END IF;
      --
      -- retrieve part number record
      OPEN c_part_num (v_part_mod_objid);
      FETCH c_part_num
      INTO c_part_num_rec;
      IF c_part_num%NOTFOUND
      THEN
         CLOSE c_part_num;
         RETURN;
      ELSE
         CLOSE c_part_num;
         DBMS_OUTPUT.put_line ('Part Number: ' || c_part_num_rec.part_number);
         v_part_number := c_part_num_rec.part_number;
         op_upc_code := c_part_num_rec.x_upc;
         IF v_part_number = 'DB0104'
         THEN
            op_num_units := 100;
         ELSIF v_part_number = 'DB0260'
         THEN
            op_num_units := 260;
         ELSE
            op_num_units := c_part_num_rec.x_redeem_units;
         END IF;
      END IF;
      --end 1.14
      EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ( 'Exception caught by WHEN OTHERS', ip_smp_num,
         v_procedure_name );
   END get_card_status;
   /***************  Make Card Redeemable (Proc 2)  ******************/
   /*                                                                */
   /* Objective  : To change the status of an Inactive (45) card     */
   /*               to Active/redeemable (42)                        */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 45 (Inactive)    */
   /*                          2  if TABLE_PART_INST update failed   */
   /*                          3  if X_POSA_card insert failed       */
   /*                          4  if Insert into the PI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*              OP_NUM_UNITS = # units associated with card, if   */
   /*                                      OP_STATUS = 0             */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_card_redeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_num_units OUT NUMBER,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   )
   IS
      v_part_number table_part_num.part_number%TYPE := NULL;
      v_redeemed_units table_part_num.x_redeem_units%TYPE := NULL;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_CARD_REDEEMABLE()';
      --1.4
      v_card_status NUMBER;
      v_card_units VARCHAR2 (30);
      v_card_upc VARCHAR2 (30);
      --end 1.4
      V_LOG_RESULT NUMBER;
      --CR53057 Multidenom
      v_mod_level_md                NUMBER;

   BEGIN
dbms_output.put_line('ip_sourcesystem:'||ip_sourcesystem);
      --1.4
      --IF TOSS_UTIL_PKG.GET_PI_STATUS_FUN(IP_SMP_NUM,v_procedure_name) = TOSS_UTIL_PKG.CARD_INACTIVE THEN
      --IF ( ip_sourcesystem <> 'POSA'
      --AND ip_sourcesystem <> 'TOSSUTILITY')
      IF ip_sourcesystem not in ('POSA','TOSSUTILITY','BHN') THEN
         IF LTRIM (RTRIM (NVL (ip_upc, '99'))) <> LTRIM (RTRIM (NVL (v_card_upc
         , '88')))
         THEN
            RAISE invalid_upc_code;
         END IF;
      END IF;
      get_card_status (ip_smp_num, v_card_status, v_card_units, v_card_upc);
      dbms_output.put_line('v_card_status:'||v_card_status);
      dbms_output.put_line('card_inactive:'||card_inactive);
      IF v_card_status = card_inactive
      THEN
        v_mod_level_md := get_mod_level_md ( i_curr_mod_level => g_posa_card_inv_rec.x_posa_inv2part_mod,
                                             i_pn_upc         => ip_upc,
                                             i_action         => 'A',
                                             i_smp            => ip_smp_num);
        IF (v_mod_level_md !=  g_posa_card_inv_rec.x_posa_inv2part_mod) AND v_mod_level_md = -99
        THEN
          RAISE invalid_md_upc;
        END IF;

         --end 1.4
         --1.4 IF TOSS_UTIL_PKG.SET_PI_STATUS_FUN(IP_SMP_NUM, 'REDEMPTION CARDS',TOSS_UTIL_PKG.CARD_READY,v_procedure_name) THEN
         --set posa card status
         BEGIN
            INSERT
            INTO table_part_inst(
               objid,
               part_serial_no,
               x_domain,
               x_red_code,
               x_part_inst_status,
               x_insert_date,
               x_creation_date,
               x_po_num,
               x_order_number,
               created_by2user,
               status2x_code_table,
               n_part_inst2part_mod,
               part_inst2inv_bin,
               last_trans_time,
--cwl 7/30/12 --MT441078
                  x_parent_part_serial_no
--cwl 7/30/12 --MT441078
            )VALUES(
               -- 04/10/03 seq_part_inst.nextval + power(2,28)                ,
               seq ('part_inst'),
               g_posa_card_inv_rec.x_part_serial_no,
               g_posa_card_inv_rec.x_domain,
               g_posa_card_inv_rec.x_red_code,
               card_ready,
               g_posa_card_inv_rec.x_inv_insert_date,
               g_posa_card_inv_rec.x_last_ship_date,
               g_posa_card_inv_rec.x_tf_po_number,
               g_posa_card_inv_rec.x_tf_order_number,
               g_posa_card_inv_rec.x_created_by2user,
               984,
               nvl(v_mod_level_md,g_posa_card_inv_rec.x_posa_inv2part_mod), --CR53057
               g_posa_card_inv_rec.x_posa_inv2inv_bin,
               SYSDATE,
--cwl 7/30/12 --MT441078
                  g_posa_card_inv_rec.x_part_serial_no
               );
--cwl 7/30/12 --MT441078
            DELETE
            FROM table_x_posa_card_inv
            WHERE x_part_serial_no = ip_smp_num
            AND x_domain = 'REDEMPTION CARDS';
--cwl 7/30/12  --MT441078
                 update table_part_inst
                    set x_part_inst_status = '42'
                  where part_serial_no like ip_smp_num||'%'
                    and x_parent_part_serial_no = g_posa_card_inv_rec.x_part_serial_no
                    AND x_domain = 'REDEMPTION CARDS';
--cwl 7/30/12  --MT441078

            --CR53057
            IF v_mod_level_md IS NOT NULL AND v_mod_level_md <> g_posa_card_inv_rec.x_posa_inv2part_mod
            THEN
                INSERT INTO x_multiodenom_posa_log
                (
                 objid,
                 smp,
                 upc,
                 domain,
                 original_mod_level,
                 updated_mod_level,
                 action_type,
                 update_date ,
                 incident_id  --added for CR52985
                )
                VALUES
                (
                 seq_x_multiodenom_posa_log.nextval,
                 ip_smp_num,
                 ip_upc,
                 'REDEMPTION CARDS',
                 g_posa_card_inv_rec.x_posa_inv2part_mod,
                 v_mod_level_md,
                 'A',
                 SYSDATE,
                 g_incident_id  --added for CR52985
                );
            END IF;

            EXCEPTION
            WHEN OTHERS
            THEN
               RAISE failed_updating_status;
         END;
         IF insert_posa_swp_tab_fun ( ip_smp_num, 'REDEMPTION CARDS', 'SWIPE',
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, TO_DATE
         (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name,
         ip_access_code, ip_auth_code, ip_reg_no, ip_upc )
         THEN
            IF insert_pi_hist_fun ( ip_smp_num, 'REDEMPTION CARD',
            'POSA CARD ACTIVATED', v_procedure_name )
            THEN
               op_result := sucess;
               COMMIT;
               v_part_number := get_part_number (ip_smp_num, v_procedure_name);
               /* business requiremets needed to be hard coded */
               IF v_part_number = 'DB0104'
               THEN
                  op_num_units := 100;
               ELSIF v_part_number = 'DB0260'
               THEN
                  op_num_units := 260;
               ELSE
                  op_num_units := g_part_num_rec.x_redeem_units;
               END IF;
            ELSE
               RAISE failed_inserting_pi_hist;
            END IF;
         ELSE
            RAISE failed_inserting_swip_rec;
         END IF;
      ELSE
         RAISE invalid_status;
      END IF;
      EXCEPTION
      WHEN invalid_upc_code
      THEN
         ROLLBACK;
         op_result := upc_code_invalid;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD SWIPE', 'INVALID UPC CODE', v_procedure_name,
         V_LOG_RESULT,ip_upc ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD SWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT,ip_upc ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
         ROLLBACK;
         op_result := status_change_failed;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD SWIPE', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_swip_rec
      THEN
         ROLLBACK;
         op_result := swipe_rec_failed;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD SWIPE', 'SWIPE RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_pi_hist
      THEN
         ROLLBACK;
         op_result := pi_hist_rec_failed;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD SWIPE', 'INSERT PI_HIST FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
     WHEN invalid_md_upc
     THEN
         ROLLBACK;
         op_result := md_upc_look_up_failed;
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD SWIPE', 'MULTI DENOM UPC LOOKUP FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc) ;
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN OTHERS
      THEN
         ROLLBACK;
         op_result := insert_error_tab_fun ( 'Failed making card reedemable',
         ip_smp_num, v_procedure_name );
   END make_card_redeemable;
   /**************  Make Card UnRedeemable (Proc 3)  *****************/
   /*                                                                */
   /* Objective  : To change the status of an active/redeemable (42) */
   /*              card to Inactive (45)                             */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 42 (Active)      */
   /*                          2  if TABLE_PART_INST update failed   */
   /*                          3  if X_POSA_card insert failed       */
   /*                          4  if Insert into the PI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*              OP_NUM_UNITS = # units associated with card, if   */
   /*                                      OP_STATUS = 0             */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_card_unredeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_num_units OUT NUMBER,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   )
   IS
      v_part_number table_part_num.part_number%TYPE := NULL;
      v_redeemed_units table_part_num.x_redeem_units%TYPE := NULL;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      'MAKE_CARD_UNREDEEMABLE.()';
      --1.4
      v_card_status NUMBER;
      v_card_units VARCHAR2 (30);
      v_card_upc VARCHAR2 (30);
      --end 1.4
      V_LOG_RESULT NUMBER;
      --CR53057
      v_mod_level_md  NUMBER;
--cwl 7/30/12  --MT441078
      cursor check_redeemed_bundle_curs is
        select count(*) cnt
          from table_x_red_card
         where x_smp like ip_smp_num||'%'
           and (regexp_like(ip_smp_num,'.*[^0123456789]$') or x_smp = ip_smp_num)
	   and rownum <2;
      check_redeemed_bundle_rec check_redeemed_bundle_curs%rowtype;
--cwl 7/30/12 --MT441078
   BEGIN
      get_card_status (ip_smp_num, v_card_status, v_card_units, v_card_upc);
--cwl 7/30/12 --MT441078
      open check_redeemed_bundle_curs;
        fetch check_redeemed_bundle_curs into check_redeemed_bundle_rec;
      close check_redeemed_bundle_curs;
--cwl 7/30/12 --MT441078
--      IF ( ip_sourcesystem <> 'POSA'
--      AND ip_sourcesystem <> 'TOSSUTILITY')
      IF ip_sourcesystem not in ('POSA','TOSSUTILITY','BHN') THEN
         IF LTRIM (RTRIM (NVL (ip_upc, '99'))) <> LTRIM (RTRIM (NVL (v_card_upc
         , '88')))
         THEN
            RAISE invalid_upc_code;
         END IF;
      END IF;
      IF v_card_status = card_ready
--cwl 7/30/12 --MT441078
	and check_redeemed_bundle_rec.cnt = 0
--cwl 7/30/12 --MT441078
      THEN

         -- 1.4
         -- move card record back to table_x_posa_card_inv
         DECLARE
            v_step VARCHAR2 (100);
            v_err VARCHAR2 (1000);
         BEGIN
            v_step := 'insert into inv';

            --CR53057 Multidenom
            v_mod_level_md := get_mod_level_md( i_curr_mod_level => g_part_inst_rec.n_part_inst2part_mod,
                                                i_pn_upc         => ip_upc,
                                                i_action         => 'U',
                                                i_smp            => ip_smp_num);

            --CR53057
            dbms_output.put_line('g_posa_card_inv_rec.x_posa_inv2part_mod:'||g_part_inst_rec.n_part_inst2part_mod);
            dbms_output.put_line('v_mod_level_md:'||v_mod_level_md);
            IF v_mod_level_md IS NOT NULL AND v_mod_level_md <> g_part_inst_rec.n_part_inst2part_mod
            THEN
              IF v_mod_level_md = 0
              THEN
              -- INVALID UPC RETURNED. THIS IS WHERE THE UPC SENT IN UNSWIPE DIDNT MATCH WITH SWIPE
                dbms_output.put_line('Raising exception');
                RAISE unswipe_upc_mismatch;
              END IF;
              dbms_output.put_line('inserting into x_multiodenom_posa_log');
              INSERT INTO x_multiodenom_posa_log -- Add begin/end when other then null
              (
               objid,
               smp,
               upc,
               domain,
               original_mod_level,
               updated_mod_level,
               action_type,
               update_date,
               incident_id  --added for CR52985
              )
              VALUES
              (
               seq_x_multiodenom_posa_log.nextval,
               ip_smp_num,
               ip_upc,
               'REDEMPTION CARDS',
               g_part_inst_rec.n_part_inst2part_mod,
               v_mod_level_md,
               'U',
               SYSDATE,
               g_incident_id --added for CR52985
              );
            END IF;
            --END CR53057

            INSERT
            INTO table_x_posa_card_inv(
               objid,
               x_part_serial_no,
               x_domain,
               x_red_code,
               x_posa_inv_status,
               x_inv_insert_date,
               x_last_ship_date,
               x_tf_po_number,
               x_tf_order_number,
               x_created_by2user,
               x_posa_status2x_code_table,
               x_posa_inv2part_mod,
               x_posa_inv2inv_bin
            )VALUES(
               -- 04/10/03 seq_x_posa_card_inv.nextval + power(2,28),
               seq ('x_posa_card_inv'),
               g_part_inst_rec.part_serial_no,
               g_part_inst_rec.x_domain,
               g_part_inst_rec.x_red_code,
               card_inactive,
               g_part_inst_rec.x_insert_date,
               g_part_inst_rec.x_creation_date,
               g_part_inst_rec.x_po_num,
               g_part_inst_rec.x_order_number,
               g_part_inst_rec.created_by2user,
               268436700,
               nvl(v_mod_level_md,g_part_inst_rec.n_part_inst2part_mod),
               g_part_inst_rec.part_inst2inv_bin
            );
              dbms_output.put_line('AFTER inserting table_x_posa_card_inv');

            /*v_step := 'delete from table_part_inst';
            DELETE FROM table_part_inst
            WHERE part_serial_no = IP_SMP_NUM;*/
            EXCEPTION
            WHEN unswipe_upc_mismatch
            THEN
              RAISE unswipe_upc_mismatch;
            WHEN OTHERS
            THEN
            dbms_output.put_line('AFTER inserting OTHERS '||SQLERRM);
               v_err := SQLERRM;
               RAISE invalid_status;
         END;
         IF insert_posa_swp_tab_fun ( ip_smp_num, 'REDEMPTION CARDS', 'UNSWIPE'
         , ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
         TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name,
         ip_access_code, ip_auth_code, ip_reg_no, ip_upc )
         THEN
            IF insert_pi_hist_fun ( ip_smp_num, 'REDEMPTION CARD',
            'POSA CARD INACTIVATED', v_procedure_name )
            THEN
               DELETE
               FROM table_part_inst
               WHERE part_serial_no = ip_smp_num
                 AND x_domain = 'REDEMPTION CARDS';  -- CR55993 BHN POSA Fix SNP vs MIN;
--cwl 7/30/12 --MT441078
               update table_part_inst
                  set x_part_inst_status = '45'
                where part_serial_no like ip_smp_num||'%'
                  and x_parent_part_serial_no = ip_smp_num
                  AND x_domain = 'REDEMPTION CARDS';
--cwl 7/30/12 --MT441078
               op_result := sucess;
               COMMIT;
               v_part_number := get_part_number (ip_smp_num, v_procedure_name);
               /* business requiremets needed to be hard coded */
               IF v_part_number = 'DB0104'
               THEN
                  op_num_units := 100;
               ELSIF v_part_number = 'DB0260'
               THEN
                  op_num_units := 260;
               ELSE
                  op_num_units := g_part_num_rec.x_redeem_units;
               END IF;
            ELSE
               RAISE failed_inserting_pi_hist;
            END IF;
         ELSE
            RAISE failed_inserting_swip_rec;
         END IF;
      ELSE
         RAISE failed_updating_status;
      END IF;
      EXCEPTION
      WHEN invalid_upc_code
      THEN
         ROLLBACK;
         op_result := upc_code_invalid;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD UNSWIPE', 'INVALID UPC CODE', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD UNSWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
         ROLLBACK;
         op_result := status_change_failed;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD UNSWIPE', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_swip_rec
      THEN
         ROLLBACK;
         op_result := swipe_rec_failed;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD UNSWIPE', 'UNSWIPE RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_pi_hist
      THEN
         ROLLBACK;
         op_result := pi_hist_rec_failed;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD UNSWIPE', 'INSERT PI_HIST FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      --CR53057
      WHEN unswipe_upc_mismatch
      THEN
         ROLLBACK;
         dbms_output.put_line('unswipe_upc_mismatch');
         op_result := unswipe_upc_mismatch_err;

         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD UNSWIPE', 'UNSWIPE UPC DOESNT MATCH WITH SWIPE UPC', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
      WHEN OTHERS
      THEN
         ROLLBACK;
         op_result := insert_error_tab_fun ( 'Failed making card unreedemable',
         ip_smp_num, v_procedure_name );
   END make_card_unredeemable;
   /**********************  Get Phone Status   ********************/
   /*                                                             */
   /* Objective  : To obtain the phone status based on ESN        */
   /*                                                             */
   /* Returns:                                                    */
   /*              OP_STATUS =  0  if phone not found             */
   /*                          59  if phone is Inactive           */
   /*                          52  if phone is Actived/USED       */
   /*                                   /PAST_DUE                 */
   /*                          50  if phone is Ready (New)        */
   /*                                                         */
   /*              OP_MERCHANT_ID = Dealer Id, if OP_STATUS <> 0  */
   /*                               Undefined, if OP_STATUS == 0  */
   /*                                                             */
   /***************************************************************/
   PROCEDURE get_phone_status(
      ip_smp_num IN VARCHAR2,
      op_upc_code OUT VARCHAR2,
      op_merchant_id OUT VARCHAR2,
      op_status OUT NUMBER
   )
   IS
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.GET_PHONE_STATUS()';
      v_part_number VARCHAR2 (30);
      v_upc VARCHAR2 (30);
      V_LOG_RESULT NUMBER;
   BEGIN
      op_status := 0;
      op_status := TO_NUMBER ( get_pi_status_fun (ip_smp_num, v_procedure_name,
      v_upc) );
      IF op_status != 0
      THEN

         --OP_UPC_CODE := TOSS_UTIL_PKG.GET_UPC_CODE(IP_SMP_NUM, v_procedure_name);
         v_part_number := get_part_number (ip_smp_num, v_procedure_name);
         op_upc_code := g_part_num_rec.x_upc;
         /** TEMPORALLY FIXED.. as much as I hate to do this **/
         IF op_status = 51
         THEN
            op_status := 52;
         ELSIF op_status = 54
         THEN
            op_status := 52;
         END IF;
         op_merchant_id := get_vendor_fun (ip_smp_num, 'PHONES',
         v_procedure_name);

      --CR2970
      ELSE
         insert_posa_log_prc ( ip_smp_num, 'PHONES', NULL, NULL, NULL, NULL,
         'POSA', TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
         'FIND ESN STATUS', 'NOT FOUND', v_procedure_name, V_LOG_RESULT,null ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
      END IF;
      --
      EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ( 'Exception caught by WHEN OTHERS', ip_smp_num,
         v_procedure_name );
   END get_phone_status;
   /*************************  Make Phone Active  ************************/
   /*                                                                    */
   /* Objective  : To change the status of an Inactive (59) phone        */
   /*               to Active (50)                                       */
   /* Returns:                                                           */
   /*              OP_RESULT = -1...-99999 0RA sql error code            */
   /*                                                               */
   /*                           0  successful                            */
   /*                           1  phone not Inactive (status <> 59)     */
   /*                           2  update TABLE_PART_INST failed         */
   /*                           3  insert x_posa_phone failed            */
   /*                           4  insert into PI hist table failed      */
   /*                           5  update vendor change failed           */
   /*                           6  insert into the posa_exception fail   */
   /*                              ed                                    */
   /**********************************************************************/
   PROCEDURE make_phone_active(
      ip_esn_num IN VARCHAR2,
      ip_upc_code IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL
   )
   IS
      do_common_inserts BOOLEAN := FALSE;
      v_orig_site_id table_site.site_id%TYPE := NULL;
      v_current_site_id table_site.site_id%TYPE := NULL;
      is_a_walmart BOOLEAN := FALSE;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_PHONE_ACTIVE()';
      v_upc VARCHAR2 (30);
      v_esn_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
   BEGIN
      v_esn_status := get_pi_status_fun (ip_esn_num, v_procedure_name, v_upc);
      IF get_pi_status_fun (ip_esn_num, v_procedure_name, v_upc) =
      phone_inactive
      THEN

         /*IF (IP_SOURCESYSTEM <> 'POSA' AND IP_SOURCESYSTEM <> 'TOSSUTILITY') THEN
            IF LTRIM(RTRIM(NVL(IP_UPC_CODE,'99'))) <> LTRIM(RTRIM(NVL(v_upc,'88'))) THEN
               RAISE invalid_upc_code;
            END IF;
         END IF;*/
         IF set_pi_status_fun ( ip_esn_num, 'PHONES', phone_ready,
         v_procedure_name )
         THEN
            IF insert_posa_swp_tab_fun ( ip_esn_num, 'PHONES', 'SWIPE',
            ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name,
            ip_access_code, ip_auth_code, ip_reg_no, ip_upc_code )
            THEN
               IF insert_pi_hist_fun ( ip_esn_num, 'PHONES',
               'POSA PHONE ACTIVATED', v_procedure_name )
               THEN
                  op_result := sucess;
                  COMMIT;
               ELSE
                  RAISE failed_inserting_pi_hist;
               END IF;
            ELSE
               RAISE failed_inserting_swip_rec;
            END IF;

         --    do_common_inserts:= TRUE;
         ELSE
            RAISE failed_updating_status;
         END IF;
      ELSE
         RAISE invalid_status;
      END IF;
      EXCEPTION
      WHEN invalid_upc_code
      THEN
dbms_output.put_line('invalid_upc_code');
         ROLLBACK;
         op_result := upc_code_invalid;
         --CR2970
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'INVALID UPC CODE', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN invalid_status
      THEN
dbms_output.put_line('invalid_status');
         ROLLBACK;
         op_result := inv_status;
         --CR2970
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
dbms_output.put_line('failed_updating_status');
         ROLLBACK;
         op_result := status_change_failed;
         --CR2970
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_swip_rec
      THEN
dbms_output.put_line('failed_inserting_swip_rec');
         ROLLBACK;
         op_result := swipe_rec_failed;
         --CR2970
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'SWIPE RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_pi_hist
      THEN
dbms_output.put_line('failed_inserting_pi_hist');
         ROLLBACK;
         op_result := pi_hist_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'INSERT PI_HIST FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_vendor
      THEN
dbms_output.put_line('failed_updating_vendor');
         ROLLBACK;
         op_result := vendor_change_failed;
      WHEN failed_insert_posa_excp
      THEN
dbms_output.put_line('failed_insert_posa_exep');
         ROLLBACK;
         op_result := posa_excp_rec_failed;
      WHEN OTHERS
      THEN
dbms_output.put_line('others');
         ROLLBACK;
         op_result := insert_error_tab_fun ( 'Failed making phone active',
         ip_esn_num, v_procedure_name );
   END;
   /************************  Make Phone Inactive  ***********************/
   /*                                                                    */
   /* Objective  : To change the status of an Ready  (50) phone          */
   /*               to Inactive (59) (at regiter VOID)                   */
   /* Returns:                                                           */
   /*              OP_RESULT = -1...-99999 0RA sql error code            */
   /*                                                               */
   /*                           0  successful                            */
   /*                                                                    */
   /*                           1  phone not Active (status <> 50)       */
   /*                           2  update TABLE_PART_INST failed         */
   /*                           3  insert x_posa_phone failed            */
   /*                           4  insert into PI hist table failed      */
   /*                           7  Invalid Vendor (non walmart)          */
   /*                                                                    */
   /**********************************************************************/
   PROCEDURE make_phone_inactive(
      ip_esn_num IN VARCHAR2,
      ip_upc_code IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL
   )
   IS
      v_current_site_id table_site.site_id%TYPE := NULL;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_PHONE_INACTIVE()';
      v_upc VARCHAR2 (30);
      v_esn_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
   BEGIN
      --CR3176 Start
--	  IF  GET_PI_STATUS_FUN (IP_ESN_NUM, v_procedure_name, v_upc) = PHONE_READY THEN
    v_esn_status := GET_PI_STATUS_FUN(IP_ESN_NUM, v_procedure_name,v_upc);

   	  IF ((v_esn_status = PHONE_READY) OR
--cwl 3/19/12 CR15722
   	      (v_esn_status = PHONE_ACTIVE) OR
--cwl 3/19/12 CR15722
	      (v_esn_status = PHONE_SEQ_MISMATCH) ) THEN
      --CR3176 End


         /*IF (IP_SOURCESYSTEM <> 'POSA' AND IP_SOURCESYSTEM <> 'TOSSUTILITY') THEN
            IF LTRIM(RTRIM(NVL(IP_UPC_CODE,'99'))) <> LTRIM(RTRIM(NVL(v_upc,'88'))) THEN
               RAISE invalid_upc_code;
            END IF;
         END IF;
         */
         /** try to set the status **/
         IF set_pi_status_fun ( ip_esn_num, 'PHONES', phone_inactive,
         v_procedure_name )
         THEN

            /** now try to insert into the swp loc phone table **/
            IF insert_posa_swp_tab_fun ( ip_esn_num, 'PHONES', 'UNSWIPE',
            ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name,
            ip_access_code, ip_auth_code, ip_reg_no, ip_upc_code )
            THEN

               /** now try to insert into the pi hist table **/
               IF insert_pi_hist_fun ( ip_esn_num, 'PHONES',
               'POSA PHONE DEACTIVATED', v_procedure_name )
               THEN
                  op_result := sucess;
                  COMMIT;
               ELSE
                  RAISE failed_inserting_pi_hist;
               END IF;
            ELSE
               RAISE failed_inserting_swip_rec;
            END IF;
         ELSE
            RAISE failed_updating_status;
         END IF;
      ELSE
         RAISE invalid_status;
-- failure
      END IF;
      --      ELSE
      --            RAISE invalid_vendor;
      --      END IF;
      EXCEPTION
      WHEN invalid_upc_code
      THEN
         ROLLBACK;
         op_result := upc_code_invalid;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE UNSWIPE', 'INVALID UPC CODE', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE UNSWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
         ROLLBACK;
         op_result := status_change_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE UNSWIPE', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_swip_rec
      THEN
         ROLLBACK;
         op_result := swipe_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE UNSWIPE', 'UNSWIPE RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_pi_hist
      THEN
         ROLLBACK;
         op_result := pi_hist_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE UNSWIPE', 'INSERT PI_HIST FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ;  --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_vendor
      THEN
         ROLLBACK;
         op_result := vendor_change_failed;
      WHEN failed_insert_posa_excp
      THEN
         ROLLBACK;
         op_result := posa_excp_rec_failed;
      WHEN invalid_vendor
      THEN
         ROLLBACK;
         op_result := inv_vendor;
      WHEN OTHERS
      THEN
         op_result := insert_error_tab_fun ( 'Failed making phone inactive',
         ip_esn_num, v_procedure_name );
   END;
   /*************************  Make Phone Returned  **********************/
   /*                                                                    */
   /* Objective  : To change the status of an Active (59) or Ready (50)  */
   /*              or inactive (59) -very rare case-                     */
   /*               phone to Returned (64)                               */
   /* Returns:                                                           */
   /*              OP_RESULT = -1...-99999 0RA sql error code            */
   /*                                                               */
   /*                           0  successful                            */
   /*                                                                    */
   /*                           1  phone Inactive (status <> 52 or 50 or */
   /*                              59 (rare case) )                      */
   /*                           2  update TABLE_PART_INST failed         */
   /*                           3  insert posa_swp_loc_act_card failed   */
   /*                           4  insert into PI hist table failed      */
   /*                           7  Invalid Vendor (non walmart)          */
   /*                                                                    */
   /**********************************************************************/
   PROCEDURE make_phone_returned(
      ip_esn_num IN VARCHAR2,
      ip_upc_code IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL
   )
   IS
      v_current_site_id table_site.site_id%TYPE := NULL;
      table_site_rec table_site%ROWTYPE;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_PHONE_RETURNED()';
      v_do_common_tasks BOOLEAN := FALSE;
      v_upc VARCHAR2 (30);
      v_pi_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
   BEGIN

      /* for at register void this condition is a must otherwise reject request */
      v_pi_status := get_pi_status_fun (ip_esn_num, v_procedure_name, v_upc);
      /*IF (IP_SOURCESYSTEM <> 'POSA' AND IP_SOURCESYSTEM <> 'TOSSUTILITY') THEN
            IF LTRIM(RTRIM(NVL(IP_UPC_CODE,'99'))) <> LTRIM(RTRIM(NVL(v_upc,'88'))) THEN
               RAISE invalid_upc_code;
            END IF;
      END IF;
      */
      /* check statuses 50 or 59 */
      IF ((v_pi_status = phone_ready)
      OR (v_pi_status = phone_inactive))
      THEN

         /** try to set the status **/
         IF set_pi_status_fun ( ip_esn_num, 'PHONES', phone_inactive, --59
         v_procedure_name )
         THEN
            v_do_common_tasks := TRUE;
         ELSE

            /*failure */
            RAISE failed_updating_status;
         END IF;
      ELSIF ((v_pi_status = phone_past_due)
      OR (v_pi_status = phone_active)
      OR (v_pi_status = phone_used))
      THEN
         IF sa.reset_esn_fun ( ip_esn_num, SYSDATE + 1, NULL, 268435556, NULL,
         NULL, 'REFURBISHED', '59', v_procedure_name )
         THEN
            v_do_common_tasks := TRUE;
         ELSE

            /*failure */
            RAISE failed_updating_status;
         END IF;
      ELSE

         /*failure */
         RAISE invalid_status;
-- failure
      END IF;
      IF v_do_common_tasks
      THEN

         /** now try to insert into the swp loc phone table **/
         IF insert_posa_swp_tab_fun ( ip_esn_num, 'PHONES', 'RETURNED',
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, TO_DATE
         (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name,
         ip_access_code, ip_auth_code, ip_reg_no, ip_upc_code )
         THEN

            /** now try to insert into the pi hist table **/
            IF insert_pi_hist_fun ( ip_esn_num, 'PHONES', 'POSA PHONE RETURNED'
            , v_procedure_name )
            THEN
               op_result := sucess;
               COMMIT;
            ELSE
               RAISE failed_inserting_pi_hist;
            END IF;
         ELSE
            RAISE failed_inserting_swip_rec;
         END IF;
      END IF;
      EXCEPTION
      WHEN invalid_upc_code
      THEN
         ROLLBACK;
         op_result := upc_code_invalid;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_pi_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE RETURN', 'INVALID UPC CODE', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_pi_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE RETURN', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
         ROLLBACK;
         op_result := status_change_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_pi_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE RETURN', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_swip_rec
      THEN
         ROLLBACK;
         op_result := swipe_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_pi_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE RETURN', 'RETURN RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_pi_hist
      THEN
         ROLLBACK;
         op_result := pi_hist_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_pi_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE RETURN', 'INSERT PI_HIST FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc_code) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_vendor
      THEN
         ROLLBACK;
         op_result := vendor_change_failed;
      WHEN failed_insert_posa_excp
      THEN
         ROLLBACK;
         op_result := posa_excp_rec_failed;
      WHEN invalid_vendor
      THEN
         ROLLBACK;
         op_result := inv_vendor;
      WHEN OTHERS
      THEN
         ROLLBACK;
         op_result := insert_error_tab_fun ( 'Failed making phone RETURNED',
         ip_esn_num, v_procedure_name );
   END make_phone_returned;
   /*****************  Get RoadSide Card Status  *****************/
   /*                                                            */
   /* Objective  : To obtain the status of a card based on SMP   */
   /*                                                            */
   /* Returns:                                                   */
   /*              OP_STATUS =  0  if card not found             */
   /*                          40  if card is Reserved           */
   /*                          41  if card is Redeemed           */
   /*                          42  if card is Active/redeemable  */
   /*                          43  if card is Void               */
   /*                          44  if card is Suspended          */
   /*                          45  if card is Inactive           */
   /*                                                            */
   /*                             0  if OP_STATUS = 0 or 45      */
   /*                                                            */
   /*              OP_UPC_CODE = the UPC code associated w/card  */
   /*                                                            */
   /**************************************************************/
   PROCEDURE get_rs_card_status(
      ip_smp_num IN VARCHAR2,
      op_status OUT NUMBER,
      op_upc_code OUT VARCHAR2
   )
   IS
      v_upc_code table_part_num.x_upc%TYPE := NULL;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.GET_RS_CARD_STATUS()';
      V_LOG_RESULT NUMBER;
   BEGIN
      op_upc_code := NULL;
      op_status := 0;
      /* Get the card status from pi table */
      op_status := TO_NUMBER (get_ri_status_fun (ip_smp_num, v_procedure_name))
      ;
      /* set the status */
      /* found the a record with valid status */
      -- IF v_status is NOT NULL THEN
      IF op_status != 0
      THEN

         /* get the upc code */
         op_upc_code := get_rs_upc_code (ip_smp_num, v_procedure_name);

      --CR2970
      ELSE
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', NULL, NULL, NULL, NULL,
         'POSA', TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
         'FIND RS STATUS', 'NOT FOUND', v_procedure_name, V_LOG_RESULT,null ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      END IF;
      EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ( 'Exception caught by WHEN OTHERS', ip_smp_num,
         v_procedure_name );
   END get_rs_card_status;
   /***************  Make Card RS Redeemable        ******************/
   /*                                                                */
   /* Objective  : To change the status of an Inactive (45) card     */
   /*               to Active/redeemable (42)                        */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 45 (Inactive)    */
   /*                          2  if TABLE_X_ROAD_INST update failed */
   /*                          3  if X_POSA_card insert failed       */
   /*                          8 if Insert into the RI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_rs_redeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   )
   IS
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_RS_REDEEMABLE()';
      v_rs_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
   BEGIN
      v_rs_status := get_ri_status_fun (ip_smp_num, v_procedure_name);
      IF get_ri_status_fun (ip_smp_num, v_procedure_name) = card_inactive
      THEN
         IF set_ri_status_fun (ip_smp_num, card_ready, 1, v_procedure_name)
         THEN
            IF insert_posa_swp_tab_fun ( ip_smp_num, 'ROADSIDE', 'SWIPE',
            ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name,
            ip_access_code, ip_auth_code, ip_reg_no, ip_upc )
            THEN
               IF insert_ri_hist_fun ( ip_smp_num, 'ROADSIDE',
               'POSA CARD ACTIVATED', v_procedure_name )
               THEN
                  op_result := sucess;
                  COMMIT;
               ELSE
                  RAISE failed_insert_ri_excp;
               END IF;
            ELSE
               RAISE failed_inserting_swip_rec;
            END IF;
         ELSE
            RAISE failed_updating_status;
         END IF;
      ELSE
         RAISE invalid_status;
      END IF;
      EXCEPTION
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE SWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
         ROLLBACK;
         op_result := status_change_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE SWIPE', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_swip_rec
      THEN
         ROLLBACK;
         op_result := swipe_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE SWIPE', 'SWIPE RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--       END IF;
      --
      WHEN failed_insert_ri_excp
      THEN
         ROLLBACK;
         op_result := ri_hist_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE SWIPE', 'INSERT RI_HIST FAILED', v_procedure_name
         , V_LOG_RESULT,ip_upc ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN OTHERS
      THEN
         ROLLBACK;
         op_result := insert_error_tab_fun ( 'Failed making RS card reedemable'
         , ip_smp_num, v_procedure_name );
   END make_rs_redeemable;
   /**************  Make RS Card UnRedeemable        *****************/
   /*                                                                */
   /* Objective  : To change the status of an active/redeemable (42) */
   /*              card to Inactive (45)                             */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 42 (Active)      */
   /*                          2  if TABLE_PART_INST update failed   */
   /*                          3  if X_POSA_ROADSIDE insert failed   */
   /*                          8  if Insert into the RI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*                                      OP_STATUS = 0             */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_rs_unredeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   )
   IS
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_RS_UNREDEEMABLE()';
      v_rs_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
   BEGIN
      v_rs_status := get_ri_status_fun (ip_smp_num, v_procedure_name);
      IF get_ri_status_fun (ip_smp_num, v_procedure_name) = card_ready
      THEN
         IF set_ri_status_fun (ip_smp_num, card_inactive, 1, v_procedure_name)
         THEN
            IF insert_posa_swp_tab_fun ( ip_smp_num, 'ROADSIDE', 'UNSWIPE',
            ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name,
            ip_access_code, ip_auth_code, ip_reg_no, ip_upc )
            THEN
               IF insert_ri_hist_fun ( ip_smp_num, 'ROADSIDE',
               'POSA CARD INACTIVATED', v_procedure_name )
               THEN
                  op_result := sucess;
                  COMMIT;
               ELSE
                  RAISE failed_insert_ri_excp;
               END IF;
            ELSE
               RAISE failed_inserting_swip_rec;
            END IF;
         ELSE
            RAISE failed_updating_status;
         END IF;
      ELSE
         RAISE invalid_status;
      END IF;
      EXCEPTION
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE UNSWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
         ROLLBACK;
         op_result := status_change_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE UNSWIPE', 'STATUS CHANGE FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_inserting_swip_rec
      THEN
         ROLLBACK;
         op_result := swipe_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE UNSWIPE', 'UNSWIPE RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_insert_ri_excp
      THEN
         ROLLBACK;
         op_result := ri_hist_rec_failed;
         --CR2970 Changes
         insert_posa_log_prc ( ip_smp_num, 'ROADSIDE', v_rs_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'ROADSIDE UNSWIPE', 'INSERT RI_HIST FAILED',
         v_procedure_name, V_LOG_RESULT,ip_upc) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN OTHERS
      THEN
         ROLLBACK;
         op_result := insert_error_tab_fun ( 'Failed making rs unreedemable',
         ip_smp_num, v_procedure_name );
   END make_rs_unredeemable;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:       set_pi_status_fun                                             */
   /* Description : Available in the specification part of package              */
   /*                                                                           */
   /*****************************************************************************/
   FUNCTION set_posa_card_status(
      ip_part_serial_no IN VARCHAR2,
      ip_status IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      table_x_code_rec table_x_code_table%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.set_pi_status_fun()';
   BEGIN
      OPEN table_x_code_cur (ip_status);
      FETCH table_x_code_cur
      INTO table_x_code_rec;
      CLOSE table_x_code_cur;
      UPDATE table_part_inst SET x_part_inst_status = ip_status,
      status2x_code_table = table_x_code_rec.objid
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
         insert_error_tab_proc ( 'Failed updating record on table_part_inst',
         ip_part_serial_no, ip_prog_caller || v_function_name );
         RETURN FALSE;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:    insert_posa_swp_tab_fun                                          */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION insert_posa_swp_tab_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_action IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      ip_store_id IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_sourcesystem IN VARCHAR2,
      ip_trans_date IN DATE,
      ip_prog_caller IN VARCHAR2,
      ip_access_code IN VARCHAR2,
      ip_auth_code IN VARCHAR2,
      ip_reg_no IN VARCHAR2,
      ip_upc IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.insert_posa_swp_tab_fun()';
      table_part_rec table_part_num%ROWTYPE;
      table_site_rec table_site%ROWTYPE;
      table_part_inst_rec table_part_inst%ROWTYPE;
      table_road_inst_rec table_x_road_inst%ROWTYPE;
   BEGIN
      IF ip_domain = 'ROADSIDE'
      THEN
         OPEN table_part_num_road_cur (ip_part_serial_no);
         FETCH table_part_num_road_cur
         INTO table_part_rec;
         CLOSE table_part_num_road_cur;
         OPEN table_site_road_cur (ip_part_serial_no, ip_domain);
         FETCH table_site_road_cur
         INTO table_site_rec;
         CLOSE table_site_road_cur;
         OPEN table_road_inst_cur (ip_part_serial_no);
         FETCH table_road_inst_cur
         INTO table_road_inst_rec;
         CLOSE table_road_inst_cur;
      ELSE
         OPEN table_part_num_cur (ip_part_serial_no);
         FETCH table_part_num_cur
         INTO table_part_rec;
         CLOSE table_part_num_cur;
         OPEN table_site_cur (ip_part_serial_no, ip_domain);
         FETCH table_site_cur
         INTO table_site_rec;
         CLOSE table_site_cur;
         OPEN table_part_inst_cur (ip_part_serial_no);
         FETCH table_part_inst_cur
         INTO table_part_inst_rec;
         CLOSE table_part_inst_cur;
      END IF;
      IF ip_domain = 'REDEMPTION CARDS'
      THEN
         DECLARE
            v_err VARCHAR2 (100) := SQLERRM;
         BEGIN
            INSERT
            INTO x_posa_card(
               tf_part_num_parent,
               tf_serial_num,
               toss_att_customer,
               toss_att_location,
               toss_posa_code,
               toss_posa_date,
               tf_extract_flag,
               tf_extract_date,
               toss_site_id,
               toss_posa_action,
               --toss_att_id,
               objid,
               remote_trans_id,
               sourcesystem,
               toss_att_trans_date,
               access_code,
               auth_code,
               reg_no,
               upc
            )VALUES(
               table_part_rec.part_number,
               ip_part_serial_no,
               ip_store_id,
               ip_store_detail,
               DECODE ( ip_action, 'SWIPE', card_ready, 'UNSWIPE',
               card_inactive, NULL ),  --04/17/03
               SYSDATE,
               'N',
               NULL,
               table_site_rec.site_id,
               ip_action,
               seq_x_posa_card.nextval,
               ip_trans_id,
               ip_sourcesystem,
               ip_trans_date,
               ip_access_code,
               ip_auth_code,
               ip_reg_no,
               ip_upc
            );
            EXCEPTION
            WHEN OTHERS
            THEN
               RETURN FALSE;
         END;
      ELSIF ip_domain = 'PHONES'
      THEN
         INSERT
         INTO x_posa_phone(
            tf_part_num_parent,
            tf_serial_num,
            toss_att_customer,
            toss_att_location,
            toss_posa_code,
            toss_posa_date,
            tf_extract_flag,
            tf_extract_date,
            toss_site_id,
            toss_posa_action,
            --toss_att_id,
            objid,
            remote_trans_id,
            sourcesystem,
            toss_att_trans_date,
               upc --CR15722
         )VALUES(
            table_part_rec.part_number,
            ip_part_serial_no,
            ip_store_id,
            ip_store_detail,
            table_part_inst_rec.x_part_inst_status,
            SYSDATE,
            'N',
            NULL,
            table_site_rec.site_id,
            ip_action,
            seq_x_posa_phone.nextval,
            ip_trans_id,
            ip_sourcesystem,
            ip_trans_date,
               ip_upc  --CR15722
         );
      ELSE

         /* DOMAIN is ROADSIDE */
         INSERT
         INTO x_posa_road(
            tf_part_num_parent,
            tf_serial_num,
            toss_att_customer,
            toss_att_location,
            toss_posa_code,
            toss_posa_date,
            tf_extract_flag,
            tf_extract_date,
            toss_site_id,
            toss_posa_action,
            --toss_att_id,
            objid,
            remote_trans_id,
            sourcesystem,
            toss_att_trans_date
         )VALUES(
            table_part_rec.part_number,
            ip_part_serial_no,
            ip_store_id,
            ip_store_detail,
            table_road_inst_rec.x_part_inst_status,
            SYSDATE,
            'N',
            NULL,
            table_site_rec.site_id,
            ip_action,
            seq_x_posa_road.nextval,
            ip_trans_id,
            ip_sourcesystem,
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
         insert_error_tab_proc ( 'Failer inserting swipe', ip_part_serial_no,
         'POSA.INSERT_POSA_SWP_TAB_FUN' );
         RETURN FALSE;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:     insert_pi_hist_fun                                              */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION insert_pi_hist_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_action IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.insert_pi_hist_fun()';
      table_part_inst_rec table_part_inst%ROWTYPE;
   BEGIN
      OPEN table_part_inst_cur (ip_part_serial_no);
      FETCH table_part_inst_cur
      INTO table_part_inst_rec;
      CLOSE table_part_inst_cur;
      INSERT
      INTO table_x_pi_hist(
         objid,
         status_hist2x_code_table,
         x_change_date,
         x_change_reason,
         x_cool_end_date,
         x_creation_date,
         x_deactivation_flag,
         x_domain,
         x_ext,
         x_insert_date,
         x_npa,
         x_nxx,
         x_old_ext,
         x_old_npa,
         x_old_nxx,
         x_part_bin,
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
      )VALUES(
         -- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power (2, 28),
         seq ('x_pi_hist'),
         table_part_inst_rec.status2x_code_table,
         SYSDATE,
         ip_action,
         table_part_inst_rec.x_cool_end_date,
         table_part_inst_rec.x_creation_date,
         table_part_inst_rec.x_deactivation_flag,
         table_part_inst_rec.x_domain,
         table_part_inst_rec.x_ext,
         table_part_inst_rec.x_insert_date,
         table_part_inst_rec.x_npa,
         table_part_inst_rec.x_nxx,
         NULL,
         NULL,
         NULL,
         table_part_inst_rec.part_bin,
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
         insert_error_tab_proc ( 'Failer inserting swipe', ip_part_serial_no,
         'POSA.INSERT_PI_HIST_FUN' );
         RETURN FALSE;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:        get_part_number                                              */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION get_part_number(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      table_part_rec table_part_num%ROWTYPE;
      return_value VARCHAR2 (30) := NULL;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.get_part_number()';
   BEGIN
      OPEN table_part_num_cur (ip_part_serial_no);
      FETCH table_part_num_cur
      INTO g_part_num_rec;
      IF table_part_num_cur%FOUND
      THEN

         --RETURN table_site_rec.site_id;
         return_value := g_part_num_rec.part_number;
      ELSE

         --RETURN NULL;
         return_value := NULL;
      END IF;
      CLOSE table_part_num_cur;
      RETURN return_value;
      EXCEPTION
      WHEN OTHERS
      THEN
         IF table_part_num_cur%ISOPEN
         THEN
            CLOSE table_part_num_cur;
         END IF;
         insert_error_tab_proc ( 'Failed retrieving part_number',
         ip_part_serial_no, ip_prog_caller || v_function_name );
         RETURN NULL;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:      get_pi_status_fun                                              */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION get_pi_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2,
      op_upc_code OUT VARCHAR2
   )
   RETURN VARCHAR2
   IS
      return_value VARCHAR2 (80) := '0';
      table_part_inst_rec table_part_inst%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.get_pi_status_fun()';
      v_part_number VARCHAR2 (30);
      V_LOG_RESULT number;
   BEGIN
      v_part_number := get_part_number (ip_part_serial_no, v_function_name);
      op_upc_code := g_part_num_rec.x_upc;
      OPEN table_part_inst_cur (ip_part_serial_no);
      FETCH table_part_inst_cur
      INTO g_part_inst_rec;
      IF table_part_inst_cur%FOUND
      THEN

         --RETURN table_part_inst_rec.x_part_inst_status;
         return_value := g_part_inst_rec.x_part_inst_status;
      ELSE

         --RETURN NULL;
         --RETURN '0'; -- meaning not found
         return_value := '0';
         --CR2970
         insert_posa_log_prc ( ip_part_serial_no, 'PHONES', NULL, NULL, NULL,
         NULL, 'POSA', TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE,
         'HH24MISS'), 'FIND ESN STATUS', 'NOT FOUND', v_function_name,
         V_LOG_RESULT ,null) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;

      --
      END IF;
      CLOSE table_part_inst_cur;
      RETURN return_value;
      EXCEPTION
      WHEN OTHERS
      THEN
         IF table_part_inst_cur%ISOPEN
         THEN
            CLOSE table_part_inst_cur;
         END IF;
         insert_error_tab_proc ( 'Failed retrieving phone status',
         ip_part_serial_no, 'get_phone_status_fun' );
         --RETURN NULL;
         RETURN TO_CHAR ( insert_error_tab_fun (
         'Failed retrieving phone status', ip_part_serial_no, ip_prog_caller ||
         v_function_name ) );
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:     insert_error_tab_fun                                            */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION insert_error_tab_fun(
      ip_action IN VARCHAR2,
      ip_key IN VARCHAR2,
      ip_program_name IN VARCHAR2
   )
   RETURN NUMBER
   IS
      sql_code NUMBER;
      sql_err VARCHAR2 (300);
      v_error_text VARCHAR2 (1000);
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.insert_error_tab_fun()';
   BEGIN
      sql_code := SQLCODE;
      sql_err := SQLERRM;
      v_error_text := 'SQL Error Code : ' || TO_CHAR (sql_code) ||
      ' Error Message : ' || sql_err;
      INSERT
      INTO error_table(
         error_text,
         error_date,
         action,
         KEY,
         program_name
      )VALUES(
         v_error_text,
         SYSDATE,
         ip_action,
         ip_key,
         ip_program_name
      );
      COMMIT;
      RETURN sql_code;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:       set_ri_status_fun                                             */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION set_ri_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_status IN VARCHAR2,
      ip_hist_trg_flag IN NUMBER,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      table_x_code_rec table_x_code_table%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.set_ri_status_fun()';
   BEGIN
      OPEN table_x_code_cur (ip_status);
      FETCH table_x_code_cur
      INTO table_x_code_rec;
      CLOSE table_x_code_cur;
      UPDATE table_x_road_inst SET x_part_inst_status = ip_status,
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
         insert_error_tab_proc ( 'Failed updating record on table_x_road_inst',
         ip_part_serial_no, ip_prog_caller || v_function_name );
         RETURN FALSE;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:       set_pi_status_fun                                             */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION set_pi_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_status IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      table_x_code_rec table_x_code_table%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.set_pi_status_fun()';
   BEGIN
      OPEN table_x_code_cur (ip_status);
      FETCH table_x_code_cur
      INTO table_x_code_rec;
      CLOSE table_x_code_cur;
      UPDATE table_part_inst SET x_part_inst_status = ip_status,
      status2x_code_table = table_x_code_rec.objid
      WHERE part_serial_no = ip_part_serial_no
      AND x_domain = ip_domain;
      IF SQL%ROWCOUNT = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
      EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ( 'Failed updating record on table_part_inst',
         ip_part_serial_no, ip_prog_caller || v_function_name );
         RETURN FALSE;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:      get_ri_status_fun                                              */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION get_ri_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      return_value VARCHAR2 (80) := '0';
      table_road_inst_rec table_x_road_inst%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.get_ri_status_fun()';
      V_LOG_RESULT number;
   BEGIN
      OPEN table_road_inst_cur (ip_part_serial_no);
      FETCH table_road_inst_cur
      INTO table_road_inst_rec;
      IF table_road_inst_cur%FOUND
      THEN
         return_value := table_road_inst_rec.x_part_inst_status;
      ELSE
         return_value := '0';
         --CR2970
         insert_posa_log_prc ( ip_part_serial_no, 'ROADSIDE', NULL, NULL, NULL,
         NULL, 'POSA', TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE,
         'HH24MISS'), 'FIND RS STATUS', 'NOT FOUND', v_function_name,
         V_LOG_RESULT,null ) ; --CR15722
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;

      --
      END IF;
      CLOSE table_road_inst_cur;
      RETURN return_value;
      EXCEPTION
      WHEN OTHERS
      THEN
         IF table_road_inst_cur%ISOPEN
         THEN
            CLOSE table_road_inst_cur;
         END IF;
         insert_error_tab_proc ( 'Failed retrieving ri status',
         ip_part_serial_no, v_package_name || '.get_ri_status_fun' );
         --RETURN NULL;
         RETURN TO_CHAR ( insert_error_tab_fun ( 'Failed retrieving ri status',
         ip_part_serial_no, ip_prog_caller || v_function_name ) );
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:     insert_ri_hist_fun                                              */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION insert_ri_hist_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_action IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      table_road_inst_rec table_x_road_inst%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.insert_ri_hist_fun()';
   BEGIN
      OPEN table_road_inst_cur (ip_part_serial_no);
      FETCH table_road_inst_cur
      INTO table_road_inst_rec;
      CLOSE table_road_inst_cur;
      INSERT
      INTO table_x_road_hist(
         objid,
         road_hist2x_code_table,
         x_change_date,
         x_change_reason,
         x_creation_date,
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
      )VALUES(
         -- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power (2, 28),
         seq ('x_pi_hist'),
         table_road_inst_rec.rd_status2x_code_table,
         SYSDATE,
         ip_action,
         table_road_inst_rec.x_creation_date,
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
         insert_error_tab_proc ( 'Failed inserting swipe in Road Inst Hist',
         ip_part_serial_no, v_package_name || '.INSERT_RI_HIST_FUN' );
         RETURN FALSE;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:    get_rs_upc_code                                                  */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION get_rs_upc_code(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      table_part_rec table_part_num%ROWTYPE;
      table_road_inst_rec table_x_road_inst%ROWTYPE;
      table_mod_level_rec table_mod_level%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.get_rs_upc_code()';
      return_value VARCHAR2 (80) := NULL;
   BEGIN
      OPEN table_road_inst_cur (ip_part_serial_no);
      FETCH table_road_inst_cur
      INTO table_road_inst_rec;
      CLOSE table_road_inst_cur;
      OPEN table_mod_objid_cur (table_road_inst_rec.n_road_inst2part_mod);
      FETCH table_mod_objid_cur
      INTO table_mod_level_rec;
      CLOSE table_mod_objid_cur;
      OPEN table_part_number_cur (table_mod_level_rec.part_info2part_num);
      FETCH table_part_number_cur
      INTO table_part_rec;
      IF table_part_number_cur%FOUND
      THEN

         --RETURN table_site_rec.site_id;
         return_value := table_part_rec.x_upc;
      ELSE

         --RETURN NULL;
         return_value := NULL;
      END IF;
      CLOSE table_part_number_cur;
      RETURN return_value;
      EXCEPTION
      WHEN OTHERS
      THEN
         IF table_part_number_cur%ISOPEN
         THEN
            CLOSE table_part_number_cur;
         END IF;
         insert_error_tab_proc ( 'Failed retrieving upc code',
         ip_part_serial_no, ip_prog_caller || v_function_name );
         RETURN NULL;
   END;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:      get_vendor_fun                                                 */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   FUNCTION get_vendor_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      table_site_rec table_site%ROWTYPE;
      return_value VARCHAR2 (80) := NULL;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.get_vendor_fun()';
   BEGIN
      OPEN table_site_cur (ip_part_serial_no, ip_domain);
      FETCH table_site_cur
      INTO table_site_rec;
      IF table_site_cur%FOUND
      THEN

         --RETURN table_site_rec.site_id;
         return_value := table_site_rec.site_id;
      ELSE

         --RETURN NULL;
         return_value := NULL;
      END IF;
      CLOSE table_site_cur;
      RETURN return_value;
      EXCEPTION
      WHEN OTHERS
      THEN
         IF table_site_cur%ISOPEN
         THEN
            CLOSE table_site_cur;
         END IF;
         insert_error_tab_proc ( 'Failed retrieving phone vendor id',
         ip_part_serial_no, ip_prog_caller || v_function_name );
         RETURN NULL;
   END;
   --CR2970
   /*****************************************************************************/
   /*                                                                           */
   /* Name:    insert_posa_log_prc                                              */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   PROCEDURE insert_posa_log_prc(
      ip_serno IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_status IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      ip_store_id IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_sourcesystem IN VARCHAR2,
      ip_trans_date IN VARCHAR2,
      IP_TRANS_TIME IN VARCHAR2,
      ip_posa_action IN VARCHAR2,
      ip_reason IN VARCHAR2,
      ip_prog_caller IN VARCHAR2,
      OP_RESULT OUT NUMBER,
      ip_upc in  varchar2 --CR15722
   )
   IS
      CURSOR c_redeem_part
      IS
      SELECT pn.part_number
      FROM table_part_num pn, table_mod_level ml, table_x_red_card rc
      WHERE rc.x_red_card2part_mod = ml.objid
      AND ml.part_info2part_num = pn.objid
      AND rc.x_smp = ip_serno;
      r_redeem_part c_redeem_part%ROWTYPE;
      CURSOR c_redeem_site
      IS
      SELECT ts.site_id
      FROM table_site ts, table_inv_bin ib, table_x_red_card rc
      WHERE rc.x_red_card2inv_bin = ib.objid
      AND ib.bin_name = ts.site_id
      AND rc.x_smp = ip_serno;
      r_redeem_site c_redeem_site%ROWTYPE;
      v_part_number table_part_num.part_number%TYPE := NULL;
      V_SITE TABLE_SITE.SITE_ID%TYPE := NULL;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.INSERT_POSA_LOG_PRC';
      table_part_rec table_part_num%ROWTYPE;
      table_site_rec table_site%ROWTYPE;
   BEGIN
      IF ip_domain = 'ROADSIDE'
      THEN
         OPEN table_part_num_road_cur (ip_serno);
         FETCH table_part_num_road_cur
         INTO table_part_rec;
         CLOSE table_part_num_road_cur;
         OPEN table_site_road_cur (ip_serno, ip_domain);
         FETCH table_site_road_cur
         INTO table_site_rec;
         CLOSE table_site_road_cur;
      ELSE
         OPEN table_part_num_cur (ip_serno);
         FETCH table_part_num_cur
         INTO table_part_rec;
         CLOSE table_part_num_cur;
         OPEN table_site_cur (ip_serno, ip_domain);
         FETCH table_site_cur
         INTO table_site_rec;
         CLOSE table_site_cur;
      END IF;
      V_PART_NUMBER := table_part_rec.PART_NUMBER;
      V_SITE := table_site_rec.SITE_ID;
      IF v_part_number
      IS
      NULL
      AND ip_domain = 'REDEMPTION CARDS'
      THEN
         OPEN c_redeem_part ;
         FETCH c_redeem_part
         INTO r_redeem_part;
         IF c_redeem_part%found
         THEN
            v_part_number := r_redeem_part.part_number;
         ELSE
            v_part_number := NULL;
         END IF;
         CLOSE c_redeem_part;
      END IF;
      IF V_SITE
      IS
      NULL
      AND ip_domain = 'REDEMPTION CARDS'
      THEN
         OPEN c_redeem_site;
         FETCH c_redeem_site
         INTO r_redeem_site;
         IF c_redeem_site%found
         THEN
            v_site := r_redeem_site.site_id;
         ELSE
            v_site := NULL;
         END IF;
         CLOSE c_redeem_site;
      END IF;
      INSERT
      INTO x_posa_log(
         objid,
         x_serial_num,
         x_domain,
         x_part_number,
         x_toss_att_customer,
         x_toss_att_location,
         x_toss_posa_code,
         x_toss_posa_date,
         x_toss_site_id,
         x_toss_posa_action,
         x_remote_trans_id,
         x_sourcesystem,
         x_toss_att_trans_date,
         x_posa_log_reason,
         x_posa_update_flag,
         x_upc  --CR15722
      )VALUES(
         seq_x_posa_log.nextval,
         ip_serno,
         ip_domain,
         v_part_number,
         ip_store_id,
         ip_store_detail,
         ip_status,
         NULL,
         NULL,
         ip_posa_action,
         ip_trans_id,
         ip_sourcesystem,
         TO_DATE (ip_trans_date || ip_trans_time, 'MMDDYYYYHH24MISS'),
         ip_reason,
         'N',
         ip_upc --CR15722
      );
      IF SQL%ROWCOUNT = 1
      THEN
         OP_RESULT := 0;
      ELSE
         OP_RESULT := 1;
      END IF;
      EXCEPTION
      WHEN OTHERS
      THEN
         insert_error_tab_proc ( 'Failed logging posa transaction', ip_serno,
         ip_prog_caller || v_function_name );
         OP_RESULT := 1;
   END;
   --CR15722
   procedure posa_transaction_controller(ip_sourcesystem in  varchar2,
                                         ip_action_type  in  varchar2 default 'A',
                                         ip_serial_no    in  varchar2,
                                         ip_date         in  varchar2,
                                         ip_time         in  varchar2,
                                         ip_trans_id     IN  VARCHAR2,
                                         ip_trans_type   IN  VARCHAR2,
                                         ip_merchant_id  IN  VARCHAR2,
                                         ip_store_detail IN  VARCHAR2,
                                         ip_access_code  IN  VARCHAR2, -- we pass null
                                         ip_auth_code    IN  VARCHAR2, -- we pass null
                                         ip_reg_no       IN  VARCHAR2, -- terminal id (Comes from BHN)
                                         ip_upc          in  varchar2,
                                         op_out_units    out number,
                                         op_out_code     out varchar2,
                                         op_bhn_code     out varchar2) is
     l_converted_serial_number varchar2(30);
     l_status number;
     l_result number;
     l_num_units number;
     l_upc_code varchar2(30);
     l_merchant_id varchar2(30);
     l_action_type varchar2(30);
     v_log_result number;
     v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||'.POSA_TRANSACTION_CONTROLLER';
     cursor find_cdma_curs is
       select part_serial_no
         from table_part_inst
        where part_serial_no in (select x_prefix||(substr(ip_serial_no,9,11))
	                           from sa.x_bhn_meid_prefix)
       union  --CR15722
       select part_serial_no
         from table_part_inst
        where part_serial_no = (substr(ip_serial_no,9,11));
     find_cdma_rec find_cdma_curs%rowtype;
     cursor map_curs(c_domain in varchar2,
                     c_action in varchar2,
                     c_status in number) is
       select *
         from sa.x_RESPONSE_CODE_MAP
        where x_sourcesystem = 'BHN'
          and x_domain = c_domain
          and x_action = c_action
          and x_status = c_status;
     map_rec map_curs%rowtype;
   begin
     --  CR22828 12/10/12
     -- l_converted_serial_number  := ltrim(substr(ip_serial_no,10,9),'0');
      if substr(ip_serial_no,1,4) in ('2223','2220') then
      --dbms_output.put_line('FIRST IP_SERIAL_NO '||ip_serial_no) ;
         if substr(ip_serial_no,1,4) IN ('2223') then
        -- dbms_output.put_line('second IP_SERIAL_NO '||ip_serial_no) ;
            if substr(ip_serial_no,9,1) = '0' then
          --  dbms_output.put_line('third IP_SERIAL_NO ' ||ip_serial_no) ;
              l_converted_serial_number  := ltrim(substr(ip_serial_no,10,9),'0');
            --  dbms_output.put_line('forth IP_SERIAL_NO '||ip_serial_no) ;
            else
              l_converted_serial_number  := ltrim(substr(ip_serial_no,9,10),'0');
             -- dbms_output.put_line('fifth IP_SERIAL_NO '||ip_serial_no) ;
            end if ;
          end if ;

     if substr(ip_serial_no,1,4) IN ('2220') then
       l_converted_serial_number  := ltrim(substr(ip_serial_no,10,9),'0');
     end if ;
        dbms_output.put_line('l_converted_serial_number '||l_converted_serial_number);
       --  CR22828 12/10/12 end
       get_card_status(l_converted_serial_number, l_status, op_out_units, l_upc_code);
       dbms_output.put_line('l_status:'||l_status);
       dbms_output.put_line('op_out_units:'||op_out_units);
       dbms_output.put_line('l_upc_code:'||l_upc_code);
       open map_curs('CARDS',ip_action_type,l_status);
         fetch map_curs into map_rec;
         if map_curs%notfound then
           op_out_code := '-1';
           op_bhn_code := '08';
           if ip_action_type = 'A' then
             l_action_type := 'CARD SWIPE';
           else
             l_action_type := 'CARD UNSWIPE';
           end if;
           insert_posa_log_prc ( l_converted_serial_number, 'INVALID TRANSACTION', NULL, NULL, NULL,
                                 NULL, ip_sourcesystem, TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
                                 l_action_type,'NOT FOUND' ,
                                 v_function_name, v_log_result,ip_upc) ; --CR15722
           dbms_output.put_line('v_log_result:'||v_log_result);
           g_controller_response := 'INVALID TRANSACTION';
           return;
         end if;
         op_out_code := map_rec.x_tf_code;
         op_bhn_code := map_rec.x_bhn_code;
       close map_curs;
       if (l_status = 45 and ip_action_type = 'A') or
          (l_status = 42 and ip_action_type = 'U') then
         null;
       else
         if ip_action_type = 'A' then
           l_action_type := 'CARD SWIPE';
         else
           l_action_type := 'CARD UNSWIPE';
         end if;
         insert_posa_log_prc ( l_converted_serial_number, 'INVALID TRANSACTION', NULL, NULL, NULL,
                               NULL, ip_sourcesystem, TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
                               l_action_type, map_rec.x_status_description,
                               v_function_name, v_log_result,ip_upc) ; --CR15722
         dbms_output.put_line('v_log_result:'||v_log_result);
         g_controller_response := 'INVALID TRANSACTION';
         return;
       end if;
       dbms_output.put_line('op_out_code:'||op_out_code);
       dbms_output.put_line('op_bhn_code:'||op_bhn_code);
       if ip_action_type = 'U' then
       dbms_output.put_line('make card unredeemed');
       make_card_unredeemable( l_converted_serial_number,
                                  ip_date,
                                  ip_time,
                                  ip_trans_id,
                                  ip_trans_type, -- ( It does not have use in the logic, we don?t use it, we pass null)
                                  ip_merchant_id, --mechant_id (Comes from BHN)
                                  ip_store_detail, --store_id (Comes from BHN)
                                  op_out_units, --out number
                                  l_result, --out number
                                  ip_sourcesystem,    -- 'BHN',
                                  ip_access_code, -- we pass null
                                  ip_auth_code,   -- we pass null
                                  ip_reg_no,   -- terminal id (Comes from BHN)
                                  ip_upc);       --upc code (Comes from BHN)
       else
       dbms_output.put_line('make card redeemed');
       make_card_redeemable(l_converted_serial_number,
                                  ip_date,
                                  ip_time,
                                  ip_trans_id,
                                  ip_trans_type, -- ( It does not have use in the logic, we don?t use it, we pass null)
                                  ip_merchant_id, --mechant_id (Comes from BHN)
                                  ip_store_detail, --store_id (Comes from BHN)
                                  op_out_units, --out number
                                  l_result, --out number
                                  ip_sourcesystem,    -- 'BHN',
                                  ip_access_code, -- we pass null
                                  ip_auth_code,   -- we pass null
                                  ip_reg_no,   -- terminal id (Comes from BHN)
                                  ip_upc);       --upc code (Comes from BHN)
       end if;
       get_card_status(l_converted_serial_number,
                       l_status,
                       op_out_units,
                       l_upc_code);
       dbms_output.put_line('l_result:'||l_result);
       dbms_output.put_line('after l_status:'||l_status);
       if l_result != 0 or l_result is null then
         op_out_code := '-1';
         --CR53057
         IF l_result = unswipe_upc_mismatch_err
         THEN
           op_bhn_code := '13'; -- RETURNING INVALID AMOUNT
         ELSIF   l_result = md_upc_look_up_failed
         THEN
           op_bhn_code := '12'; -- ED confirmed
         ELSE
           op_bhn_code := '08';
         END IF;

         if ip_action_type = 'A' then
           l_action_type := 'CARD SWIPE';
         else
           l_action_type := 'CARD UNSWIPE';
         end if;
         insert_posa_log_prc ( l_converted_serial_number, 'INVALID TRANSACTION', NULL, NULL, NULL,
                               NULL, ip_sourcesystem, TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
                               l_action_type,  map_rec.x_status_description,
                               v_function_name, v_log_result,ip_upc) ; --CR15722
         dbms_output.put_line('v_log_result:'||v_log_result);
         g_controller_response := 'INVALID TRANSACTION';
         return;
       end if;
       g_controller_response := 'SUCCESS';
       return;
     elsif substr(ip_serial_no,1,4) =  '2221' then
       l_converted_serial_number  := substr(ip_serial_no,5,15);
     elsif substr(ip_serial_no,1,4) =  '2222' then
       open find_cdma_curs;
         fetch find_cdma_curs into l_converted_serial_number;
       close find_cdma_curs;
     else
       op_out_code := '-1';
       op_bhn_code := '08';
       insert_posa_log_prc ( l_converted_serial_number, 'INVALID TRANSACTION', NULL, NULL, NULL,
                             NULL, ip_sourcesystem, TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
                             'INVALID ACTION', 'INVALID TRANSACTION PREFIX '||substr(ip_serial_no,1,4),
                             v_function_name, v_log_result,ip_upc) ; --CR15722
       dbms_output.put_line('v_log_result:'||v_log_result);
       g_controller_response := 'INVALID TRANSACTION';
       return;
     end if;
     get_phone_status(l_converted_serial_number,
                      l_upc_code,
                      l_merchant_id,
                      l_status);
     dbms_output.put_line('l_converted_serial_number:'||l_converted_serial_number);
     dbms_output.put_line('l_upc_code:'||l_upc_code);
     dbms_output.put_line('l_merchant_id:'||l_merchant_id);
     dbms_output.put_line('l_status:'||l_status); --CR15722 l_result
     if ip_action_type = 'U' then
       op_out_code := '00';
       op_bhn_code := '00';
     else
       open map_curs('PHONES',ip_action_type,l_status);
         fetch map_curs into map_rec;
         if map_curs%notfound then
           dbms_output.put_line('Translation not found');
           op_out_code := '-1';
           op_bhn_code := '08';
           insert_posa_log_prc ( l_converted_serial_number, 'INVALID TRANSACTION', NULL, NULL, NULL,
                                 NULL, ip_sourcesystem, TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
                                 'PHONE SWIPE' , 'NOT FOUND',
                                 v_function_name, v_log_result,ip_upc) ; --CR15722
           dbms_output.put_line('v_log_result:'||v_log_result);
           g_controller_response := 'INVALID TRANSACTION';
           return;
         end if;
         op_out_code := map_rec.x_tf_code;
         op_bhn_code := map_rec.x_bhn_code;
         dbms_output.put_line('Translation found:'||op_bhn_code);
       close map_curs;
     end if;
     if ip_action_type = 'U' or l_status = 59 then --CR15722 l_result
       null;
     else
       insert_posa_log_prc ( l_converted_serial_number, 'INVALID TRANSACTION', NULL, NULL, NULL,
                             NULL, ip_sourcesystem, TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
                             'PHONE SWIPE' , map_rec.x_status_description,
                             v_function_name, v_log_result,ip_upc) ; --CR15722
       dbms_output.put_line('v_log_result:'||v_log_result);
       g_controller_response := 'INVALID TRANSACTION';
       return;
     end if;
     if ip_action_type = 'U' then
--CR15722
       if l_status = 52 or l_status = 51 or l_status = 54 then
         dbms_output.put_line('make phone retruned');
         make_phone_returned(l_converted_serial_number,
                             ip_upc,
                             ip_date,
                             ip_time,
                             ip_trans_id,
                             ip_trans_type,
                             ip_merchant_id,
                             ip_store_detail,
                             l_result,
                             ip_sourcesystem, --'BHN'
                             ip_access_code, --we pass null
                             ip_auth_code,   --we pass null
                             ip_reg_no);
         dbms_output.put_line('l_result:'||l_result);
         get_phone_status(l_converted_serial_number,
                      l_upc_code,
                      l_merchant_id,
                      l_status);
         dbms_output.put_line('l_converted_serial_number:'||l_converted_serial_number);
         dbms_output.put_line('l_upc_code:'||l_upc_code);
         dbms_output.put_line('l_merchant_id:'||l_merchant_id);
         dbms_output.put_line('l_status:'||l_status);
       end if;
--CR15722
       dbms_output.put_line('make phone unredeemed');
       make_phone_inactive(l_converted_serial_number,
                           ip_upc,
                           ip_date,
                           ip_time,
                           ip_trans_id,
                           ip_trans_type,
                           ip_merchant_id,
                           ip_store_detail,
                           l_result,
                           ip_sourcesystem, --'BHN'
                           ip_access_code, --we pass null
                           ip_auth_code,   --we pass null
                           ip_reg_no);
       dbms_output.put_line('l_result:'||l_result);
     else
       dbms_output.put_line('make phone redeemed');
       make_phone_active(l_converted_serial_number,
                         ip_upc,
                         ip_date,
                         ip_time,
                         ip_trans_id,
                         ip_trans_type,
                         ip_merchant_id,
                         ip_store_detail,
                         l_result,
                         ip_sourcesystem, --'BHN'
                         ip_access_code, --we pass null
                         ip_auth_code,   --we pass null
                         ip_reg_no);
       dbms_output.put_line('l_result:'||l_result);
     end if;
     if ip_action_type = 'U' then
       op_out_code := '00';
       op_bhn_code := '00';
     elsif l_result != 0 or l_result is null then
       op_out_code := '-1';
       op_bhn_code := '07';
       insert_posa_log_prc ( l_converted_serial_number, 'INVALID TRANSACTION', NULL, NULL, NULL,
                             NULL, ip_sourcesystem, TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE, 'HH24MISS'),
                             'SWIPE', 'UNABLE TO PROCESS',
                             v_function_name, v_log_result,ip_upc) ; --CR15722
       dbms_output.put_line('v_log_result:'||v_log_result);
     end if;
  --
  g_controller_response := 'SUCCESS';

end;
--

-- overloaded procedure to accommodate the response and incident id
PROCEDURE posa_transaction_controller (ip_sourcesystem   IN  VARCHAR2,
                                       ip_action_type    IN  VARCHAR2 DEFAULT 'A',
                                       ip_serial_no      IN  VARCHAR2,
                                       ip_date           IN  VARCHAR2,
                                       ip_time           IN  VARCHAR2,
                                       ip_trans_id       IN  VARCHAR2,
                                       ip_trans_type     IN  VARCHAR2,
                                       ip_merchant_id    IN  VARCHAR2,
                                       ip_store_detail   IN  VARCHAR2,
                                       ip_access_code    IN  VARCHAR2,
                                       ip_auth_code      IN  VARCHAR2,
                                       ip_reg_no         IN  VARCHAR2,
                                       ip_upc            IN  VARCHAR2,
                                       op_out_units      OUT NUMBER  ,
                                       op_out_code       OUT VARCHAR2,
                                       op_bhn_code       OUT VARCHAR2,
                                       i_incident_id     IN  VARCHAR2 DEFAULT NULL,
                                       o_response        OUT VARCHAR2) IS
BEGIN

  g_incident_id  := i_incident_id;--assigning incident id to global variable CR52985

  posa_transaction_controller ( ip_sourcesystem    => ip_sourcesystem,
                                ip_action_type     => ip_action_type,
                                ip_serial_no       => ip_serial_no,
                                ip_date            => ip_date,
                                ip_time            => ip_time,
                                ip_trans_id        => ip_trans_id,
                                ip_trans_type      => ip_trans_type,
                                ip_merchant_id     => ip_merchant_id,
                                ip_store_detail    => ip_store_detail,
                                ip_access_code     => ip_access_code,
                                ip_auth_code       => ip_auth_code,
                                ip_reg_no          => ip_reg_no,
                                ip_upc             => ip_upc,
                                op_out_units       => op_out_units,
                                op_out_code        => op_out_code,
                                op_bhn_code        => op_bhn_code );

  o_response := g_controller_response;

END posa_transaction_controller;

--CR53057 multidenom
  FUNCTION get_mod_level_md(
    i_curr_mod_level  IN  NUMBER
   ,i_pn_upc          IN  VARCHAR2
   ,i_action          IN  VARCHAR2
   ,i_smp             IN  VARCHAR2
  )
    RETURN NUMBER
  IS
    n_curr_pn_price               NUMBER;
    n_md_mod_level                NUMBER;
    c_upc                         VARCHAR2(50);
    c_source_system               table_part_num.x_sourcesystem%type;
  BEGIN
  dbms_output.put_line('get_mod_level_md :'||i_curr_mod_level);

    IF i_action = 'A'
    THEN
      BEGIN
        SELECT x_sourcesystem
        INTO   c_source_system
        FROM   table_part_num pn
        WHERE  pn.objid =  ( SELECT part_info2part_num
                             FROM   table_mod_level ml
                             WHERE  ml.objid = i_curr_mod_level );
      EXCEPTION
        WHEN OTHERS THEN
          RETURN i_curr_mod_level;
      END;

      IF c_source_system = 'MULTI DENOM RED CARD'
      THEN
        BEGIN
          SELECT ml.objid
          INTO   n_md_mod_level
          FROM   table_mod_level ml
          WHERE  ml.part_info2part_num = (SELECT objid
                                          FROM   table_part_num pn
                                          WHERE  pn.x_upc = i_pn_upc
                                          AND    s_domain = 'REDEMPTION CARDS'
                                          AND    active   = 'Active'
                                          AND    x_sourcesystem != 'MULTI DENOM RED CARD');
        EXCEPTION
          WHEN OTHERS THEN
            RETURN -99;
        END;

        RETURN n_md_mod_level;

      ELSE --IF c_source_system = 'MULTI DENOM RED CARD'
        RETURN i_curr_mod_level;
      END IF;  --IF c_source_system = 'MULTI DENOM RED CARD'
    ELSIF i_action = 'U' --IF i_action = 'A'
    THEN
      BEGIN
        SELECT original_mod_level,
               upc
        INTO   n_md_mod_level,
               c_upc
        FROM   x_multiodenom_posa_log pl1
        WHERE  smp = i_smp
        AND    domain = 'REDEMPTION CARDS'
        AND    action_type = 'A'
        AND    updated_mod_level = i_curr_mod_level
        AND    NOT EXISTS
              ( SELECT 1 FROM x_multiodenom_posa_log pl2
                WHERE  pl2.objid <> pl1.objid
                AND    pl2.smp = pl1.smp
                AND    pl2.action_type = 'U'
                AND    pl2.update_date > pl1.update_date );

        -- IF THE UPC IS SAME AS SWIPE REQUEST THEN ALL GOOD
        IF  c_upc =  i_pn_upc
        THEN
          RETURN n_md_mod_level;
        ELSE -- ELSE RETURN AN INVALID UPC (0)
          RETURN 0;
        END IF;

      EXCEPTION
      WHEN OTHERS THEN
        RETURN i_curr_mod_level;
      END;

    ELSE--INVALID ACTION (COULD BE 'U' OR 'A' ONLY)
     RETURN i_curr_mod_level;
    END IF;--IF i_action = 'A'
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN i_curr_mod_level;
  END get_mod_level_md;

  -- CR54843_Enhance_BHN_MultiDenom_Agent_TAS_Tool_to_Support_LookUp

  FUNCTION get_smp_details_tab (i_smp             IN       VARCHAR2)
                                RETURN smp_tab PIPELINED AS

  l_smp_row      smp_row;
  v_err_num      NUMBER;
  v_err_string   VARCHAR2(200);
  v_result       VARCHAR2(200);
  v_card_status  NUMBER;
  v_num_units    NUMBER;
  v_upc_code     table_part_num.x_upc%type;


  BEGIN


     --
     -- Get the UPC for the Parent smp
     --
     posa_lite.get_card_status(ip_smp_num    => i_smp,
                               op_status     => v_card_status,
                               op_num_units  => v_num_units,
                               op_upc_code   => v_upc_code);


     FOR a_rec IN (SELECT shell_part_num_objid shell_part_num_objid,
                          child_part_num_objid child_part_num_objid,
                          denom_description    denom_description,
                          vendor_upc           vendor_upc,
                          tf_filler            tf_filler,
                          tf_id                tf_id,
                          airtime_denomination airtime_denomination,
                          i_smp                smp,
                          vendor_upc||tf_filler ||tf_id||airtime_denomination||i_smp encode,
                          v_card_status        card_status,
                          (select max(tp.x_retail_price) x_retail_price
                            from table_x_pricing tp
                           where tp.x_pricing2part_num = tspn.child_part_num_objid
                             and SYSDATE BETWEEN tp.x_start_date and tp.x_end_date
                             and x_channel = 'CLIENT' ) x_retail_price
                     FROM sa.table_shell_part_num tspn
                    WHERE shell_part_num_objid IN (SELECT objid
                                                     FROM table_part_num tpn
                                                    WHERE tpn.x_upc = v_upc_code)
                    ORDER BY 1)

   --
    -- Check the status returned.
    --

         LOOP

              l_smp_row.shell_part_num_objid := a_rec.shell_part_num_objid;
              l_smp_row.child_part_num_objid := a_rec.child_part_num_objid;
              l_smp_row.denom_description := a_rec.denom_description;
              l_smp_row.vendor_upc := a_rec.vendor_upc;
              l_smp_row.tf_filler := a_rec.tf_filler;
              l_smp_row.tf_id := a_rec.tf_id;
              l_smp_row.airtime_denomination := a_rec.airtime_denomination;
              l_smp_row.smp := a_rec.smp;
              l_smp_row.encode := a_rec.encode;
              l_smp_row.card_status := a_rec.card_status;
              l_smp_row.x_retail_price := a_rec.x_retail_price;

              pipe row (l_smp_row);
          end loop;


  	  v_result     := 'SUCCESS';
  	  v_err_num    := 0;


  EXCEPTION WHEN OTHERS THEN


  	  v_result     := 'ERROR';
  	  v_err_num    := SQLCODE;
  	  v_err_string := SQLCODE || SUBSTR (SQLERRM, 1, 100);

        dbms_output.put_line('op_result '||v_result);
        dbms_output.put_line('op_err_num '||v_err_num);
        dbms_output.put_line('op_err_string '||v_err_string);


  END get_smp_details_tab;


END posa_lite;
/
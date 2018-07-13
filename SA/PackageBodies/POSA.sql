CREATE OR REPLACE PACKAGE BODY sa."POSA"
AS
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: POSA.sql,v $
  --$Revision: 1.19 $
  --$Author: tbaney $
  --$Date: 2018/03/12 20:41:16 $
  --$ $Log: POSA.sql,v $
  --$ Revision 1.19  2018/03/12 20:41:16  tbaney
  --$ Modified logic to force sort to find part number instead of lines.
  --$
  --$ Revision 1.14  2018/01/11 21:36:41  tbaney
  --$ CR_C91841_POSA_card_numbers_MINs_conflict
  --$
  --$ Revision 1.13  2015/08/18 18:10:11  pvenkata
  --$ CR35619: CPO_MANUFACTURER
  --$
  --$ Revision 1.11  2014/12/29 23:38:46  clinder
  --$ CR31489
  --$
  --$ Revision 1.10  2014/12/29 23:15:28  clinder
  --$ CR31524
  --$
  --$ Revision 1.9  2012/12/14 17:40:17  icanavan
  --$ modify get_part_number function
  --$
  --$ Revision 1.8  2012/11/13 22:17:14  icanavan
  --$ remove dbms outputs used in testing
  --$
  --$ Revision 1.7  2012/11/13 21:53:51  icanavan
  --$ modified 4 more procedures
  --$
  --$ Revision 1.6  2012/11/02 16:03:28  icanavan
  --$ ACMI ACME project
  --$
  --$ Revision 1.5  2012/08/06 12:59:45  icanavan
  --$ Family Plans - Cash Solutions Release
  --$
  --$ Revision 1.3  2012/04/03 14:39:10  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$ Revision 1.2  2012/01/18 16:22:01  kacosta
  --$ CR19627 POSA Response Code Update - Status 400  263
  --$
  --
  ---------------------------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------------------------
  --
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
   /* 1.14 03/17/03 SL             Clarify Upgrade                               */
   /*                              Replace all procedures call to toss_util_pkg  */
   /*                              Modified all posa redemption card related     */
   /*                              logic to reflect new data model               */
   /*                              Only posa ready card will be inserted inot    */
   /*                              table_part_inst                               */
   /*                                                                            */
   /* 1.15 04/10/03 SL             Clarify Upgrade - sequence                    */
   /*                                                                            */
   /* 1.16 04/20/04  MH            a)Modified Make_Card_Unredeemable,so it can   */
   /*                                return actual units intead of null          */
   /*                                (CR2778/Magic Ticket # 46774)               */
   /*                              b)Modified insert_pi_hist_fun, Zero out pin   */
   /*                                code when writing into  table_x_pi_hist     */
   /* 1.17 09/27/04 VA             CR3176 - Make Phone Inactive for '55' status  */
   /*                                       esns                                 */
   /* 1.18 10/18/04  VAdapa        CR2970 - Insert queued-in transaction data    */
   /*                              in X_POSA_LOG table                           */
   /* 1.19 12/07/04  VAdapa        CR3443 - Fix for : POSA Aircash: invalid trans*/
   /*                              are failing to insert in the POSA Log         */
   /* 1.20 03/01/05  VAdapa        CR3477 - POSA Flag Alerts                     */
   /******************************************************************************/
   /* CVS
   /* 1.4-5 08/06/2012 CLindner    CR21541 Family Plans - Cash Solutions Release */
   /*  1.9  12/13/12   ICanavan    CR22911 ACME changes
   /******************************************************************************/

   v_package_name CONSTANT VARCHAR2 (80) := '.POSA_PKG';
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
   ORDER BY CASE WHEN UPPER(PN.PART_NUMBER) = 'LINES' -- CR56437_New_folderCorrect_Part_Under_this_Field_Instsead_of_Word_Line  NVL will allow query to work BAU.
                 THEN 9999
                 ELSE 1
                  END ;
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
   -- CALL THE HEX2DEC USE IT HERE AS THE IP_PART_SERIAL_NO
   CURSOR table_part_inst_cur(
      ip_part_serial_no VARCHAR2

   )
   RETURN table_part_inst%ROWTYPE
   IS
   SELECT
OBJID,PART_GOOD_QTY,PART_BAD_QTY,PART_SERIAL_NO,PART_MOD,PART_BIN,LAST_PI_DATE,
PI_TAG_NO,LAST_CYCLE_CT,NEXT_CYCLE_CT,LAST_MOD_TIME,LAST_TRANS_TIME,TRANSACTION_ID,DATE_IN_SERV,
WARR_END_DATE,REPAIR_DATE,PART_STATUS,PICK_REQUEST,GOOD_RES_QTY,BAD_RES_QTY,DEV,X_INSERT_DATE,
X_SEQUENCE,X_CREATION_DATE,X_PO_NUM,X_RED_CODE,X_DOMAIN,X_DEACTIVATION_FLAG,X_REACTIVATION_FLAG,X_COOL_END_DATE,
DECODE(X_PART_INST_STATUS,'400','41','263','41',X_PART_INST_STATUS),
X_NPA,X_NXX,X_EXT,X_ORDER_NUMBER,PART_INST2INV_BIN,N_PART_INST2PART_MOD,
FULFILL2DEMAND_DTL,PART_INST2X_PERS,PART_INST2X_NEW_PERS,PART_INST2CARRIER_MKT,CREATED_BY2USER,
STATUS2X_CODE_TABLE,PART_TO_ESN2PART_INST,X_PART_INST2SITE_PART,X_LD_PROCESSED,DTL2PART_INST,ECO_NEW2PART_INST,
HDR_IND,X_MSID,X_PART_INST2CONTACT,X_ICCID,X_CLEAR_TANK,X_PORT_IN,X_HEX_SERIAL_NO ,x_parent_part_serial_no,X_WF_MAC_ID,CPO_MANUFACTURER
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
      op_upc_code OUT VARCHAR2,
      op_part_promo OUT VARCHAR2 --CR3477
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
      SELECT
OBJID,PART_GOOD_QTY,PART_BAD_QTY,PART_SERIAL_NO,PART_MOD,PART_BIN,LAST_PI_DATE,
PI_TAG_NO,LAST_CYCLE_CT,NEXT_CYCLE_CT,LAST_MOD_TIME,LAST_TRANS_TIME,TRANSACTION_ID,DATE_IN_SERV,
WARR_END_DATE,REPAIR_DATE,PART_STATUS,PICK_REQUEST,GOOD_RES_QTY,BAD_RES_QTY,DEV,X_INSERT_DATE,
X_SEQUENCE,X_CREATION_DATE,X_PO_NUM,X_RED_CODE,X_DOMAIN,X_DEACTIVATION_FLAG,X_REACTIVATION_FLAG,X_COOL_END_DATE,
DECODE(X_PART_INST_STATUS,'400','41','263','41',X_PART_INST_STATUS),
X_NPA,X_NXX,X_EXT,X_ORDER_NUMBER,PART_INST2INV_BIN,N_PART_INST2PART_MOD,
FULFILL2DEMAND_DTL,PART_INST2X_PERS,PART_INST2X_NEW_PERS,PART_INST2CARRIER_MKT,CREATED_BY2USER,
STATUS2X_CODE_TABLE,PART_TO_ESN2PART_INST,X_PART_INST2SITE_PART,X_LD_PROCESSED,DTL2PART_INST,ECO_NEW2PART_INST,
HDR_IND,X_MSID,X_PART_INST2CONTACT,X_ICCID,X_CLEAR_TANK,X_PORT_IN,X_HEX_SERIAL_NO ,x_parent_part_serial_no,X_WF_MAC_ID,CPO_MANUFACTURER
      FROM table_part_inst
      WHERE part_serial_no = c_smp
        AND x_domain = 'REDEMPTION CARDS';  -- CR_C91841_POSA_card_numbers_MINs_conflict
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
      WHERE x_smp = c_smp
      AND x_result ||'' = 'Completed'; --CR3443
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
      --CR3477 Starts
      CURSOR c_promo(
         c_objid IN NUMBER
      )
      IS
      SELECT *
      FROM table_x_promotion
      WHERE objid = c_objid
      AND SYSDATE BETWEEN x_start_date
      AND x_end_date;
      c_promo_rec c_promo%ROWTYPE;
      --CR3477 Ends
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
               v_procedure_name, V_LOG_RESULT ) ;
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
         --CR3443 Starts
         --           insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', NULL, NULL, NULL
         --          , NULL, 'POSA', TO_CHAR(SYSDATE, 'mm/dd/yy'), TO_CHAR(SYSDATE,
         --          'hh:mi:ss'), 'FIND SMP PART', 'NOT FOUND', v_procedure_name,
         --          V_LOG_RESULT ) ;
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', NULL, NULL, NULL
         , NULL, 'POSA', TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE,
         'HH24MISS'), 'FIND SMP PART', 'NOT FOUND', v_procedure_name,
         V_LOG_RESULT ) ;
         --CR3443 Ends
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
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
         --CR3477 Starts
         IF c_part_num_rec.part_num2x_promotion
         IS
         NOT NULL
         THEN
            OPEN c_promo(c_part_num_rec.part_num2x_promotion);
            FETCH c_promo
            INTO c_promo_rec;
            IF c_promo%found
            THEN
               op_part_promo := c_promo_rec.x_promo_code;
            ELSE
               op_part_promo := NULL;
            END IF;
            CLOSE c_promo;
         END IF;

      --CR3477 Ends
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
      ip_sourcesystem IN VARCHAR2 := 'POSA'
   )
   IS
      v_part_number table_part_num.part_number%TYPE := NULL;
      v_redeemed_units table_part_num.x_redeem_units%TYPE := NULL;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name || '.MAKE_CARD_REDEEMABLE()';
      --1.4
      v_card_status NUMBER;
      v_card_units VARCHAR2 (30);
      v_card_upc VARCHAR2 (30);
      V_LOG_RESULT NUMBER;
      --end 1.4
      v_part_promo VARCHAR2(30);
--CR3477
   BEGIN

      --1.4
      --IF TOSS_UTIL_PKG.GET_PI_STATUS_FUN(IP_SMP_NUM,v_procedure_name) = TOSS_UTIL_PKG.CARD_INACTIVE THEN
      --CR3477 Starts
      --      get_card_status (ip_smp_num, v_card_status, v_card_units, v_card_upc);
      get_card_status (ip_smp_num, v_card_status, v_card_units, v_card_upc,v_part_promo);
      --CR3477 Ends
      IF v_card_status = card_inactive
      THEN
--CR3477 Starts
         IF ip_sourcesystem = 'POSA_FLAG_ON'
         AND (v_card_units >= 400
         -- CR16379 Start kacosta 03/12/2012
         OR v_part_promo = 'RTX3X000'
         -- CR16379 End kacosta 03/12/2012
         OR v_part_promo = 'RTDBL000' )
         THEN
            RAISE invalid_units;
         ELSE

            --CR3477 Ends
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
--cwl 7/30/12
                  x_parent_part_serial_no
--cwl 7/30/12
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
                  g_posa_card_inv_rec.x_posa_inv2part_mod,
                  g_posa_card_inv_rec.x_posa_inv2inv_bin,
                  SYSDATE,
--cwl 7/30/12
                  g_posa_card_inv_rec.x_part_serial_no
               );
--cwl 7/30/12
               DELETE
               FROM table_x_posa_card_inv
               WHERE x_part_serial_no = ip_smp_num
               AND x_domain = 'REDEMPTION CARDS';
--cwl 7/30/12
                 update table_part_inst
                    set x_part_inst_status = '42'
                  where part_serial_no like ip_smp_num||'%'
                    and x_parent_part_serial_no = g_posa_card_inv_rec.x_part_serial_no
                    AND x_domain = 'REDEMPTION CARDS';
--cwl 7/30/12
               EXCEPTION
               WHEN OTHERS
               THEN
                  RAISE failed_updating_status;
            END;
            IF insert_posa_swp_tab_fun ( ip_smp_num, 'REDEMPTION CARDS',
            'SWIPE', ip_store_detail, ip_merchant_id, ip_trans_id,
            ip_sourcesystem, TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'),
            v_procedure_name )
            THEN
               IF insert_pi_hist_fun ( ip_smp_num, 'REDEMPTION CARD',
               'POSA CARD ACTIVATED', v_procedure_name )
               THEN
                  op_result := sucess;
                  COMMIT;
                  v_part_number := get_part_number (ip_smp_num,
                  v_procedure_name);
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
         END IF;
----End POSA stand_in flag check
      ELSE
         RAISE invalid_status;
      END IF;
      EXCEPTION
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD SWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT ) ;
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
         V_LOG_RESULT ) ;
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
         v_procedure_name, V_LOG_RESULT ) ;
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
         V_LOG_RESULT) ;
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      --CR3477 Starts
      WHEN invalid_units
      THEN
         ROLLBACK;
         op_result := insert_error_tab_fun ( 'Invalid Units when POSA Flag On',
         ip_smp_num, v_procedure_name );

      --CR3477 Ends
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
      ip_sourcesystem IN VARCHAR2 := 'POSA'
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
      v_part_promo VARCHAR2(30);
--cwl 7/30/12
      cursor check_redeemed_bundle_curs is
        select count(*) cnt
          from table_x_red_card
         where x_smp like ip_smp_num||'%'
           and (regexp_like(ip_smp_num,'.*[^0123456789]$') or x_smp = ip_smp_num)
	   and rownum <2;
      check_redeemed_bundle_rec check_redeemed_bundle_curs%rowtype;
--cwl 7/30/12
--CR3477
   BEGIN
--CR3477 Starts
      --      get_card_status (ip_smp_num, v_card_status, v_card_units, v_card_upc);
      get_card_status (ip_smp_num, v_card_status, v_card_units, v_card_upc, v_part_promo);
      --CR3477 Ends
--cwl 7/30/12
      open check_redeemed_bundle_curs;
        fetch check_redeemed_bundle_curs into check_redeemed_bundle_rec;
      close check_redeemed_bundle_curs;
--cwl 7/30/12
      IF v_card_status = card_ready
--cwl 7/30/12
	and check_redeemed_bundle_rec.cnt = 0
--cwl 7/30/12
      THEN

         -- 1.4
         -- move card record back to table_x_posa_card_inv
         DECLARE
            v_step VARCHAR2 (100);
            v_err VARCHAR2 (1000);
         BEGIN
            v_step := 'insert into inv';
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
               g_part_inst_rec.n_part_inst2part_mod,
               g_part_inst_rec.part_inst2inv_bin
            );
            /*v_step := 'delete from table_part_inst';
            DELETE FROM table_part_inst
            WHERE part_serial_no = IP_SMP_NUM;*/
            EXCEPTION
            WHEN OTHERS
            THEN
               v_err := SQLERRM;
               RAISE invalid_status;
         END;
         IF insert_posa_swp_tab_fun ( ip_smp_num, 'REDEMPTION CARDS', 'UNSWIPE'
         , ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
         TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name )
         THEN
            IF insert_pi_hist_fun ( ip_smp_num, 'REDEMPTION CARD',
            'POSA CARD INACTIVATED', v_procedure_name )
            THEN
--added on 04/20/04 by MH
               v_part_number := get_part_number (ip_smp_num, v_procedure_name);
               DELETE
               FROM table_part_inst
               WHERE part_serial_no = ip_smp_num
                 AND x_domain = 'REDEMPTION CARDS'; -- CR_C91841_POSA_card_numbers_MINs_conflict
--cwl 7/30/12
               update table_part_inst
                  set x_part_inst_status = '45'
                where part_serial_no like ip_smp_num||'%'
                  and x_parent_part_serial_no = ip_smp_num
                  AND x_domain = 'REDEMPTION CARDS';
--cwl 7/30/12
               op_result := sucess;
               COMMIT;
               --stop on 04/20/04 by MH   v_part_number := GET_PART_NUMBER(IP_SMP_NUM, v_procedure_name);
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
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970
         insert_posa_log_prc ( ip_smp_num, 'REDEMPTION CARDS', v_card_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'CARD UNSWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT) ;
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
         V_LOG_RESULT) ;
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
         v_procedure_name, V_LOG_RESULT) ;
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
         V_LOG_RESULT) ;
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
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
      V_LOG_RESULT NUMBER;
   BEGIN
      op_status := 0;
      op_status := TO_NUMBER (get_pi_status_fun (ip_smp_num, v_procedure_name))
      ;
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
         'FIND ESN STATUS', 'NOT FOUND', v_procedure_name, V_LOG_RESULT ) ;
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
      ip_sourcesystem IN VARCHAR2 := 'POSA'
   )
   IS
      do_common_inserts BOOLEAN := FALSE;
      v_orig_site_id table_site.site_id%TYPE := NULL;
      v_current_site_id table_site.site_id%TYPE := NULL;
      is_a_walmart BOOLEAN := FALSE;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_PHONE_ACTIVE()';
      v_esn_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
      -- CR22277 ACME Launch
      V_ESN_LENGTH NUMBER ;
      clarify_esn VARCHAR2(30) ;
   BEGIN

      clarify_esn := ip_esn_num ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_esn_num) ;
      end if ;
      -- v_esn_status := get_pi_status_fun (ip_esn_num, v_procedure_name); -- CR22277 ACME Launch
      v_esn_status := get_pi_status_fun (clarify_esn, v_procedure_name);
      -- dbms_output.put_line ('v_esn_status '||v_esn_status);
      -- IF get_pi_status_fun (ip_esn_num, v_procedure_name) = phone_inactive -- CR22277 ACME Launch
      IF get_pi_status_fun (clarify_esn, v_procedure_name) = phone_inactive
      THEN
      -- IF set_pi_status_fun ( ip_esn_num, 'PHONES', phone_ready, v_procedure_name ) -- CR22277 ACME Launch
         IF set_pi_status_fun ( clarify_esn, 'PHONES', phone_ready, v_procedure_name )
         THEN
      --   dbms_output.put_line ('set_pi_status_fun good ' || ip_esn_num); -- CR22277 ACME Launch
      --      dbms_output.put_line ('set_pi_status_fun good ' || clarify_esn);
            IF insert_posa_swp_tab_fun ( ip_esn_num, 'PHONES', 'SWIPE',
            ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name
            )
            THEN
       --     dbms_output.put_line ('insert_posa_swp_tab_fun good ');
               -- IF insert_pi_hist_fun ( ip_esn_num, 'PHONES','POSA PHONE ACTIVATED', v_procedure_name ) -- CR22277 ACME Launch
               IF insert_pi_hist_fun ( clarify_esn, 'PHONES','POSA PHONE ACTIVATED', v_procedure_name )
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
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT) ;
         IF V_LOG_RESULT = 0
         THEN
            COMMIT;
         END IF;
--
      WHEN failed_updating_status
      THEN
         ROLLBACK;
         op_result := status_change_failed;
         -- dbms_output.put_line('status_change_failed '||status_change_failed);
         --CR2970
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT) ;
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
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE SWIPE', 'SWIPE RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT) ;
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
         , ip_time, 'PHONE SWIPE', 'INSERT PI_HIST FAILED', v_procedure_name,
         V_LOG_RESULT) ;
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
      WHEN OTHERS
      THEN
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
      ip_sourcesystem IN VARCHAR2 := 'POSA'
   )
   IS
      v_current_site_id table_site.site_id%TYPE := NULL;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_PHONE_INACTIVE()';
      v_esn_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
      -- CR22277 ACME Launch
      V_ESN_LENGTH NUMBER ;
      clarify_esn VARCHAR2(30) ;
   BEGIN
      clarify_esn := ip_esn_num ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_esn_num) ;
      end if ;
      -- v_esn_status := get_pi_status_fun (ip_esn_num, v_procedure_name); -- -- CR22277 ACME Launch
      v_esn_status := get_pi_status_fun (clarify_esn, v_procedure_name);
      --CR3176 Start
      --IF get_pi_status_fun (ip_esn_num, v_procedure_name) = phone_ready THEN
      IF ((v_esn_status = PHONE_READY)
      OR (v_esn_status = PHONE_SEQ_MISMATCH) )
      THEN

         --CR3176 End
         /** try to set the status **/
         -- IF set_pi_status_fun ( ip_esn_num, 'PHONES', phone_inactive,v_procedure_name ) -- CR22277 ACME Launch
         IF set_pi_status_fun ( clarify_esn, 'PHONES', phone_inactive,v_procedure_name )
         THEN

            /** now try to insert into the swp loc phone table **/
            IF insert_posa_swp_tab_fun ( ip_esn_num, 'PHONES', 'UNSWIPE',
            ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem,
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name
            )
            THEN

               /** now try to insert into the pi hist table **/
               -- IF insert_pi_hist_fun ( ip_esn_num, 'PHONES','POSA PHONE DEACTIVATED', v_procedure_name ) -- CR22277 ACME Launch
               IF insert_pi_hist_fun ( clarify_esn, 'PHONES','POSA PHONE DEACTIVATED', v_procedure_name )
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
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE UNSWIPE', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT) ;
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
         V_LOG_RESULT) ;
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
         v_procedure_name, V_LOG_RESULT) ;
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
         V_LOG_RESULT) ;
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
      ip_sourcesystem IN VARCHAR2 := 'POSA'
   )
   IS
      v_current_site_id table_site.site_id%TYPE := NULL;
      table_site_rec table_site%ROWTYPE;
      v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.MAKE_PHONE_RETURNED()';
      v_do_common_tasks BOOLEAN := FALSE;
      v_esn_status VARCHAR2 (10);
      V_LOG_RESULT NUMBER;
      -- CR22277 ACME Launch
      V_ESN_LENGTH NUMBER ;
      clarify_esn VARCHAR2(30) ;
   BEGIN
      clarify_esn := ip_esn_num ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_esn_num) ;
      end if ;
      -- v_esn_status := get_pi_status_fun (ip_esn_num, v_procedure_name); -- CR22277 ACME Launch
         v_esn_status := get_pi_status_fun (clarify_esn, v_procedure_name);
      /* for at register void this condition is a must otherwise reject request */
      /* check statuses 50 or 59 */
      --IF ((get_pi_status_fun (ip_esn_num, v_procedure_name) = phone_ready) -- CR22277 ACME Launch
      --OR (get_pi_status_fun (ip_esn_num, v_procedure_name) = phone_inactive)) -- CR22277 ACME Launch
      IF ((get_pi_status_fun (clarify_esn, v_procedure_name) = phone_ready)
      OR (get_pi_status_fun (clarify_esn, v_procedure_name) = phone_inactive))
      THEN

         /** try to set the status **/
         --IF set_pi_status_fun ( ip_esn_num, 'PHONES', phone_inactive, --59
         --v_procedure_name )
         IF set_pi_status_fun ( clarify_esn, 'PHONES', phone_inactive, --59 -- CR22277 ACME Launch
           v_procedure_name )
         THEN
            v_do_common_tasks := TRUE;
         ELSE

            /*failure */
            RAISE failed_updating_status;
         END IF;
      ELSIF
      --((get_pi_status_fun (ip_esn_num, v_procedure_name) = phone_past_due ) -- CR22277 ACME Launch
      --OR (get_pi_status_fun (ip_esn_num, v_procedure_name) = phone_active) -- CR22277 ACME Launch
      --OR (get_pi_status_fun (ip_esn_num, v_procedure_name) = phone_used)) -- CR22277 ACME Launch
      ((get_pi_status_fun (clarify_esn, v_procedure_name) = phone_past_due )
      OR (get_pi_status_fun (clarify_esn, v_procedure_name) = phone_active)
      OR (get_pi_status_fun (clarify_esn, v_procedure_name) = phone_used))

      THEN
         -- IF sa.reset_esn_fun ( ip_esn_num, SYSDATE + 1, NULL,268435556,NULL,NULL,'REFURBISHED','59',v_procedure_name ) -- CR22277 ACME Launch
         IF sa.reset_esn_fun ( clarify_esn, SYSDATE + 1, NULL,268435556,NULL,NULL,'REFURBISHED','59',v_procedure_name )
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
         (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name )
         THEN

            /** now try to insert into the pi hist table **/
            -- IF insert_pi_hist_fun ( ip_esn_num, 'PHONES', 'POSA PHONE RETURNED' , v_procedure_name ) -- CR22277 ACME Launch
            IF insert_pi_hist_fun ( clarify_esn,'PHONES','POSA PHONE RETURNED',v_procedure_name )
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
      WHEN invalid_status
      THEN
         ROLLBACK;
         op_result := inv_status;
         --CR2970 Changes
         insert_posa_log_prc ( ip_esn_num, 'PHONES', v_esn_status,
         ip_store_detail, ip_merchant_id, ip_trans_id, ip_sourcesystem, ip_date
         , ip_time, 'PHONE RETURN', 'INVALID STATUS', v_procedure_name,
         V_LOG_RESULT) ;
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
         , ip_time, 'PHONE RETURN', 'STATUS CHANGE FAILED', v_procedure_name,
         V_LOG_RESULT) ;
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
         , ip_time, 'PHONE RETURN', 'RETURN RECORD INSERT FAILED',
         v_procedure_name, V_LOG_RESULT) ;
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
         , ip_time, 'PHONE RETURN', 'INSERT PI_HIST FAILED', v_procedure_name,
         V_LOG_RESULT) ;
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
         'FIND RS STATUS', 'NOT FOUND', v_procedure_name, V_LOG_RESULT ) ;
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
      ip_sourcesystem IN VARCHAR2 := 'POSA'
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
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name
            )
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
         V_LOG_RESULT) ;
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
         V_LOG_RESULT) ;
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
         v_procedure_name, V_LOG_RESULT) ;
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
         , ip_time, 'ROADSIDE SWIPE', 'INSERT RI_HIST FAILED', v_procedure_name
         , V_LOG_RESULT ) ;
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
      ip_sourcesystem IN VARCHAR2 := 'POSA'
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
            TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'), v_procedure_name
            )
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
         V_LOG_RESULT) ;
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
         v_procedure_name, V_LOG_RESULT) ;
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
         v_procedure_name, V_LOG_RESULT) ;
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
         v_procedure_name, V_LOG_RESULT) ;
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
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.insert_posa_swp_tab_fun()';
      table_part_rec table_part_num%ROWTYPE;
      table_site_rec table_site%ROWTYPE;
      table_part_inst_rec table_part_inst%ROWTYPE;
      table_road_inst_rec table_x_road_inst%ROWTYPE;
      -- CR22277 ACME Launch
      V_ESN_LENGTH NUMBER ;
      clarify_esn VARCHAR2(30) ;
   BEGIN
      clarify_esn := ip_part_serial_no ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_part_serial_no) ;
      end if ;
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
         -- OPEN table_part_num_cur (ip_part_serial_no); -- CR22277 ACME Launch
         OPEN table_part_num_cur (clarify_esn);
         FETCH table_part_num_cur
         INTO table_part_rec;
         CLOSE table_part_num_cur;
         -- OPEN table_site_cur (ip_part_serial_no, ip_domain); -- CR22277 ACME Launch
         OPEN table_site_cur (clarify_esn, ip_domain);
         FETCH table_site_cur
         INTO table_site_rec;
         CLOSE table_site_cur;
         --OPEN table_part_inst_cur (ip_part_serial_no); -- CR22277 ACME Launch
         OPEN table_part_inst_cur (clarify_esn);
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
               toss_att_trans_date
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
               ip_trans_date
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
            toss_att_trans_date
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
            ip_trans_date
         );

         dbms_output.put_line(' 3 inserted ');
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
         --stop on 04/20/04              table_part_inst_rec.x_red_code,
         '0',  -- zero out the pin code field
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
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||'.get_part_number()';
      v_esn_length NUMBER ;
      clarify_esn VARCHAR2(30) ;
   BEGIN
    -- CR22911 ACME changes 12/13/12
      clarify_esn := ip_part_serial_no ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_part_serial_no) ;
      end if ;

      OPEN table_part_num_cur (clarify_esn);
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

         -- which esn do we want in here?  converted CLFY or inbound.  stay with the inbound
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
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      return_value VARCHAR2 (80) := '0';
      table_part_inst_rec table_part_inst%ROWTYPE;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.get_pi_status_fun()';
      V_LOG_RESULT NUMBER;
      v_esn_length NUMBER ; -- CR22277 ACME Launch
      clarify_esn VARCHAR2(30) ; -- CR22277 ACME Launch

   BEGIN

      -- CR22277 ACME Launch
      clarify_esn := ip_part_serial_no ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_part_serial_no) ;
      end if ;
      -- CR22277 ACME Launch

      --OPEN table_part_inst_cur (ip_part_serial_no);  -- CR22277 ACME Launch
      OPEN table_part_inst_cur (clarify_esn);
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
         insert_posa_log_prc
          ( ip_part_serial_no,
          'PHONES', NULL, NULL, NULL,
         NULL, 'POSA', TO_CHAR(SYSDATE, 'MMDDYYYY'), TO_CHAR(SYSDATE,
         'HH24MISS'), 'FIND ESN STATUS', 'NOT FOUND', v_function_name,
         V_LOG_RESULT ) ;
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
         clarify_esn,  -- CR22277 ACME Launch ip_part_serial_no,
         'get_phone_status_fun' );
         --RETURN NULL;
         RETURN TO_CHAR ( insert_error_tab_fun (
         'Failed retrieving phone status',
         clarify_esn, -- CR22277 ACME Launch ip_part_serial_no,
         ip_prog_caller ||
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

      v_esn_length NUMBER ; -- CR22277 ACME Launch
      clarify_esn VARCHAR2(30) ; -- CR22277 ACME Launch

   BEGIN

      -- CR22277 ACME Launch
      clarify_esn := ip_part_serial_no ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_part_serial_no) ;
      end if ;
      -- CR22277 ACME Launch

      OPEN table_x_code_cur (ip_status);
      FETCH table_x_code_cur
      INTO table_x_code_rec;
      CLOSE table_x_code_cur;

      UPDATE table_part_inst SET x_part_inst_status = ip_status,
        status2x_code_table = table_x_code_rec.objid
       WHERE part_serial_no = clarify_esn  -- ip_part_serial_no  -- CR22277 ACME Launch
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
         clarify_esn, -- ip_part_serial_no, -- CR22277 ACME Launch
         ip_prog_caller || v_function_name );
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
      V_LOG_RESULT NUMBER;

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
         V_LOG_RESULT ) ;
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
      -- CR22277 ACME Launch
      V_ESN_LENGTH NUMBER ;
      clarify_esn VARCHAR2(30) ;
   BEGIN
      clarify_esn := ip_part_serial_no ;
      v_esn_length := length(trim(clarify_esn)) ;
      if v_esn_length = 14
      then
        clarify_esn := sa.hex2dec(ip_part_serial_no) ;
      end if ;
      --OPEN table_site_cur (ip_part_serial_no, ip_domain); -- CR22277 ACME Launch
      OPEN table_site_cur (clarify_esn, ip_domain);
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
         --insert_error_tab_proc ( 'Failed retrieving phone vendor id',ip_part_serial_no, ip_prog_caller || v_function_name ); -- CR22277 ACME Launch
         insert_error_tab_proc ( 'Failed retrieving phone vendor id',clarify_esn, ip_prog_caller || v_function_name );
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
      OP_RESULT OUT NUMBER
   )
   IS
      CURSOR c_redeem_part
      IS
      SELECT pn.part_number
      FROM table_part_num pn, table_mod_level ml, table_x_red_card rc
      WHERE rc.x_red_card2part_mod = ml.objid
      AND ml.part_info2part_num = pn.objid
      AND rc.x_smp = ip_serno
      AND rc.x_result ||'' = 'Completed';
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
         x_posa_log_date
      )VALUES(
         seq_x_posa_log.nextval,
         ip_serno,
         ip_domain,
         v_part_number,
         ip_store_id,
         ip_store_detail,
         ip_status,
         SYSDATE,
         V_SITE,
         ip_posa_action,
         ip_trans_id,
         ip_sourcesystem,
         TO_DATE (ip_trans_date || ip_trans_time, 'MMDDYYYYHH24MISS'),
         ip_reason,
         'N',
         SYSDATE
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
END posa;
/